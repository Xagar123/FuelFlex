//
//  WorkoutPlanManager.swift
//  FuelFlex
//

import Foundation

@MainActor
class WorkoutPlanManager: ObservableObject {
    
    @Published var currentPlan: WorkoutPlan?
    @Published var workoutLogs: [WorkoutLog] = []
    @Published var isGenerating: Bool = false
    @Published var isLoaded: Bool = false
    
    private let service: WorkoutPlanService
    
    init(service: WorkoutPlanService = FirestoreWorkoutPlanService()) {
        self.service = service
    }
    
    // MARK: - Persistence
    
    func loadPlan(userId: String) async {
        do {
            currentPlan = try await service.fetchPlan(userId: userId)
            workoutLogs = try await service.fetchWorkoutLogs(userId: userId)
        } catch {
            print("Error loading plan: \(error)")
        }
        isLoaded = true
    }
    
    private func persistPlan() {
        guard let plan = currentPlan else { return }
        Task {
            try? await service.savePlan(plan)
        }
    }
    
    // MARK: - Plan Generation
    
    func generatePlan(for profile: UserProfile, userId: String) async {
        isGenerating = true
        
        // Simulate AI generation delay — replace with real API later
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        
        let schedule = buildWeeklySchedule(profile: profile)
        currentPlan = WorkoutPlan(
            userId: userId,
            goal: profile.id,
            fitnessLevel: profile.fitnessLevel,
            daysPerWeek: profile.daysPerWeek,
            weeklySchedule: schedule
        )
        
        persistPlan()
        isGenerating = false
    }
    
    // MARK: - Today's Workout
    
    var todayWorkout: WorkoutDay? {
        guard let plan = currentPlan else { return nil }
        let weekday = Calendar.current.component(.weekday, from: Date())
        // Convert Calendar weekday (1=Sun) to our DayOfWeek (1=Mon)
        let mapped = weekday == 1 ? 7 : weekday - 1
        return plan.weeklySchedule.first { $0.dayOfWeek.rawValue == mapped }
    }
    
    // MARK: - Workout Logging
    
    func startWorkout(for day: WorkoutDay) -> WorkoutLog {
        WorkoutLog(from: day)
    }
    
    func completeWorkout(_ log: WorkoutLog) {
        var finalLog = log
        finalLog.endTime = Date()
        workoutLogs.append(finalLog)
        
        // Mark day as completed
        if let planIdx = currentPlan?.weeklySchedule.firstIndex(where: { $0.id == log.workoutDayId }) {
            currentPlan?.weeklySchedule[planIdx].isCompleted = true
        }
        
        persistPlan()
        if let userId = currentPlan?.userId {
            Task { try? await service.saveWorkoutLog(finalLog, userId: userId) }
        }
    }
    
    // MARK: - Stats
    
    var completedDaysThisWeek: Int {
        currentPlan?.weeklySchedule.filter(\.isCompleted).count ?? 0
    }
    
    var trainingDaysThisWeek: Int {
        currentPlan?.weeklySchedule.filter { $0.dayType == .training }.count ?? 0
    }
    
    var totalCaloriesBurned: Int {
        currentPlan?.weeklySchedule
            .filter(\.isCompleted)
            .reduce(0) { $0 + $1.estimatedCalories } ?? 0
    }
    
    // MARK: - Plan Editing (Day-Level)
    
    func changeDayType(dayId: UUID, to type: DayType) {
        guard let idx = currentPlan?.weeklySchedule.firstIndex(where: { $0.id == dayId }) else { return }
        currentPlan?.weeklySchedule[idx].dayType = type
        if type == .rest || type == .activeRecovery {
            currentPlan?.weeklySchedule[idx].phases = []
            currentPlan?.weeklySchedule[idx].focusMuscles = []
            currentPlan?.weeklySchedule[idx].estimatedDuration = type == .activeRecovery ? 30 : 0
            currentPlan?.weeklySchedule[idx].estimatedCalories = type == .activeRecovery ? 150 : 0
            currentPlan?.weeklySchedule[idx].title = type == .rest ? "Rest Day" : "Active Recovery"
        }
        persistPlan()
    }
    
    func updateDayTitle(dayId: UUID, title: String) {
        guard let idx = currentPlan?.weeklySchedule.firstIndex(where: { $0.id == dayId }) else { return }
        currentPlan?.weeklySchedule[idx].title = title
    }
    
    func applyDayTemplate(dayId: UUID, template: DayTemplate) {
        guard let idx = currentPlan?.weeklySchedule.firstIndex(where: { $0.id == dayId }) else { return }
        let dayOfWeek = currentPlan!.weeklySchedule[idx].dayOfWeek
        currentPlan?.weeklySchedule[idx] = template.buildDay(dayOfWeek: dayOfWeek)
        persistPlan()
    }
    
    func swapDays(dayId1: UUID, dayId2: UUID) {
        guard let idx1 = currentPlan?.weeklySchedule.firstIndex(where: { $0.id == dayId1 }),
              let idx2 = currentPlan?.weeklySchedule.firstIndex(where: { $0.id == dayId2 }) else { return }
        let dow1 = currentPlan!.weeklySchedule[idx1].dayOfWeek
        let dow2 = currentPlan!.weeklySchedule[idx2].dayOfWeek
        currentPlan?.weeklySchedule.swapAt(idx1, idx2)
        currentPlan?.weeklySchedule[idx1].dayOfWeek = dow1
        currentPlan?.weeklySchedule[idx2].dayOfWeek = dow2
        persistPlan()
    }
    
    // MARK: - Plan Editing (Exercise-Level)
    
    func removeExercise(dayId: UUID, phaseId: UUID, exerciseId: UUID) {
        guard let dayIdx = currentPlan?.weeklySchedule.firstIndex(where: { $0.id == dayId }),
              let phaseIdx = currentPlan?.weeklySchedule[dayIdx].phases.firstIndex(where: { $0.id == phaseId }) else { return }
        currentPlan?.weeklySchedule[dayIdx].phases[phaseIdx].exercises.removeAll { $0.id == exerciseId }
        reorderExercises(dayIdx: dayIdx, phaseIdx: phaseIdx)
    }
    
    func addExercise(dayId: UUID, phaseId: UUID, exercise: PlannedExercise) {
        guard let dayIdx = currentPlan?.weeklySchedule.firstIndex(where: { $0.id == dayId }),
              let phaseIdx = currentPlan?.weeklySchedule[dayIdx].phases.firstIndex(where: { $0.id == phaseId }) else { return }
        var newExercise = exercise
        newExercise.order = currentPlan?.weeklySchedule[dayIdx].phases[phaseIdx].exercises.count ?? 0
        currentPlan?.weeklySchedule[dayIdx].phases[phaseIdx].exercises.append(newExercise)
    }
    
    func swapExercise(dayId: UUID, phaseId: UUID, oldExerciseId: UUID, newExercise: PlannedExercise) {
        guard let dayIdx = currentPlan?.weeklySchedule.firstIndex(where: { $0.id == dayId }),
              let phaseIdx = currentPlan?.weeklySchedule[dayIdx].phases.firstIndex(where: { $0.id == phaseId }),
              let exIdx = currentPlan?.weeklySchedule[dayIdx].phases[phaseIdx].exercises.firstIndex(where: { $0.id == oldExerciseId }) else { return }
        var replacement = newExercise
        replacement.order = currentPlan?.weeklySchedule[dayIdx].phases[phaseIdx].exercises[exIdx].order ?? exIdx
        currentPlan?.weeklySchedule[dayIdx].phases[phaseIdx].exercises[exIdx] = replacement
    }
    
    func moveExercise(dayId: UUID, phaseId: UUID, from source: IndexSet, to destination: Int) {
        guard let dayIdx = currentPlan?.weeklySchedule.firstIndex(where: { $0.id == dayId }),
              let phaseIdx = currentPlan?.weeklySchedule[dayIdx].phases.firstIndex(where: { $0.id == phaseId }) else { return }
        currentPlan?.weeklySchedule[dayIdx].phases[phaseIdx].exercises.move(fromOffsets: source, toOffset: destination)
        reorderExercises(dayIdx: dayIdx, phaseIdx: phaseIdx)
    }
    
    func updateExercise(dayId: UUID, phaseId: UUID, exerciseId: UUID, sets: Int? = nil, repLow: Int? = nil, repHigh: Int? = nil, rest: Int? = nil) {
        guard let dayIdx = currentPlan?.weeklySchedule.firstIndex(where: { $0.id == dayId }),
              let phaseIdx = currentPlan?.weeklySchedule[dayIdx].phases.firstIndex(where: { $0.id == phaseId }),
              let exIdx = currentPlan?.weeklySchedule[dayIdx].phases[phaseIdx].exercises.firstIndex(where: { $0.id == exerciseId }) else { return }
        if let sets { currentPlan?.weeklySchedule[dayIdx].phases[phaseIdx].exercises[exIdx].sets = sets }
        if let repLow { currentPlan?.weeklySchedule[dayIdx].phases[phaseIdx].exercises[exIdx].repRangeLow = repLow }
        if let repHigh { currentPlan?.weeklySchedule[dayIdx].phases[phaseIdx].exercises[exIdx].repRangeHigh = repHigh }
        if let rest { currentPlan?.weeklySchedule[dayIdx].phases[phaseIdx].exercises[exIdx].restSeconds = rest }
    }
    
    private func reorderExercises(dayIdx: Int, phaseIdx: Int) {
        guard var exercises = currentPlan?.weeklySchedule[dayIdx].phases[phaseIdx].exercises else { return }
        for i in exercises.indices { exercises[i].order = i }
        currentPlan?.weeklySchedule[dayIdx].phases[phaseIdx].exercises = exercises
    }
    
    // MARK: - Override Rest Day
    
    func overrideRestDay(_ day: WorkoutDay) {
        guard let idx = currentPlan?.weeklySchedule.firstIndex(where: { $0.id == day.id }),
              day.dayType == .rest || day.dayType == .activeRecovery else { return }
        
        let trainingDay = WorkoutDay(
            dayOfWeek: day.dayOfWeek, dayType: .training,
            title: "Extra Session",
            focusMuscles: [.chest, .back, .quads, .core],
            estimatedDuration: 40, estimatedCalories: 400,
            phases: [
                WorkoutPhaseData(type: .main, exercises: [
                    PlannedExercise(name: "Dumbbell Bench Press", targetMuscles: [.chest, .triceps], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 0),
                    PlannedExercise(name: "Cable Row", targetMuscles: [.back], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 1),
                    PlannedExercise(name: "Goblet Squat", targetMuscles: [.quads, .glutes], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 2),
                    PlannedExercise(name: "Plank", targetMuscles: [.core], sets: 3, repRangeLow: 30, repRangeHigh: 60, restSeconds: 60, notes: "Hold in seconds", order: 3),
                ])
            ]
        )
        currentPlan?.weeklySchedule[idx] = trainingDay
        persistPlan()
    }
    
    // MARK: - Static Plan Builder (hardcoded for now, replace with AI later)
    
    private func buildWeeklySchedule(profile: UserProfile) -> [WorkoutDay] {
        switch profile.daysPerWeek {
        case 3: return buildFullBodySplit(profile: profile)
        case 4: return buildUpperLowerSplit(profile: profile)
        default: return buildPushPullLegsSplit(profile: profile)
        }
    }
    
    // MARK: - 4-Day Upper/Lower Split
    
    private func buildUpperLowerSplit(profile: UserProfile) -> [WorkoutDay] {
        [
            WorkoutDay(
                dayOfWeek: .monday, dayType: .training,
                title: "Upper Body Push",
                focusMuscles: [.chest, .shoulders, .triceps],
                estimatedDuration: 50, estimatedCalories: 480,
                phases: [
                    WorkoutPhaseData(type: .warmup, exercises: [
                        PlannedExercise(name: "Arm Circles", targetMuscles: [.shoulders], sets: 2, repRangeLow: 15, repRangeHigh: 20, restSeconds: 30, order: 0),
                        PlannedExercise(name: "Band Pull-Aparts", targetMuscles: [.shoulders, .back], sets: 2, repRangeLow: 12, repRangeHigh: 15, restSeconds: 30, order: 1),
                    ]),
                    WorkoutPhaseData(type: .main, exercises: [
                        PlannedExercise(name: "Barbell Bench Press", targetMuscles: [.chest, .triceps], sets: 4, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, alternatives: ["Dumbbell Bench Press", "Machine Chest Press"], order: 0),
                        PlannedExercise(name: "Overhead Press", targetMuscles: [.shoulders, .triceps], sets: 3, repRangeLow: 8, repRangeHigh: 12, restSeconds: 90, alternatives: ["Dumbbell Shoulder Press"], order: 1),
                        PlannedExercise(name: "Incline Dumbbell Press", targetMuscles: [.chest, .shoulders], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, alternatives: ["Incline Machine Press"], order: 2),
                        PlannedExercise(name: "Cable Lateral Raises", targetMuscles: [.shoulders], sets: 3, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, alternatives: ["Dumbbell Lateral Raises"], order: 3),
                        PlannedExercise(name: "Tricep Pushdowns", targetMuscles: [.triceps], sets: 3, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, alternatives: ["Overhead Tricep Extension"], order: 4),
                    ]),
                    WorkoutPhaseData(type: .cooldown, exercises: [
                        PlannedExercise(name: "Chest Doorway Stretch", targetMuscles: [.chest], sets: 2, repRangeLow: 30, repRangeHigh: 30, restSeconds: 0, notes: "Hold 30 seconds each side", order: 0),
                    ]),
                ]
            ),
            WorkoutDay(
                dayOfWeek: .tuesday, dayType: .training,
                title: "Lower Body Strength",
                focusMuscles: [.quads, .hamstrings, .glutes, .calves],
                estimatedDuration: 55, estimatedCalories: 520,
                phases: [
                    WorkoutPhaseData(type: .warmup, exercises: [
                        PlannedExercise(name: "Bodyweight Squats", targetMuscles: [.quads, .glutes], sets: 2, repRangeLow: 12, repRangeHigh: 15, restSeconds: 30, order: 0),
                    ]),
                    WorkoutPhaseData(type: .main, exercises: [
                        PlannedExercise(name: "Barbell Back Squat", targetMuscles: [.quads, .glutes], sets: 4, repRangeLow: 6, repRangeHigh: 8, restSeconds: 150, alternatives: ["Leg Press", "Goblet Squat"], order: 0),
                        PlannedExercise(name: "Romanian Deadlift", targetMuscles: [.hamstrings, .glutes], sets: 3, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, alternatives: ["Stiff-Leg Deadlift"], order: 1),
                        PlannedExercise(name: "Bulgarian Split Squat", targetMuscles: [.quads, .glutes], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, alternatives: ["Walking Lunges"], order: 2),
                        PlannedExercise(name: "Leg Curl", targetMuscles: [.hamstrings], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 60, order: 3),
                        PlannedExercise(name: "Calf Raises", targetMuscles: [.calves], sets: 4, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 4),
                    ]),
                ]
            ),
            WorkoutDay(
                dayOfWeek: .wednesday, dayType: .rest,
                title: "Rest & Recovery",
                estimatedDuration: 0, estimatedCalories: 0
            ),
            WorkoutDay(
                dayOfWeek: .thursday, dayType: .training,
                title: "Upper Body Pull",
                focusMuscles: [.back, .biceps, .shoulders],
                estimatedDuration: 50, estimatedCalories: 460,
                phases: [
                    WorkoutPhaseData(type: .warmup, exercises: [
                        PlannedExercise(name: "Band Pull-Aparts", targetMuscles: [.back, .shoulders], sets: 2, repRangeLow: 15, repRangeHigh: 20, restSeconds: 30, order: 0),
                    ]),
                    WorkoutPhaseData(type: .main, exercises: [
                        PlannedExercise(name: "Barbell Row", targetMuscles: [.back, .biceps], sets: 4, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, alternatives: ["Dumbbell Row", "Cable Row"], order: 0),
                        PlannedExercise(name: "Pull-ups", targetMuscles: [.back, .biceps], sets: 3, repRangeLow: 6, repRangeHigh: 10, restSeconds: 120, alternatives: ["Lat Pulldown"], order: 1),
                        PlannedExercise(name: "Face Pulls", targetMuscles: [.shoulders, .back], sets: 3, repRangeLow: 15, repRangeHigh: 20, restSeconds: 60, order: 2),
                        PlannedExercise(name: "Barbell Curl", targetMuscles: [.biceps], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 60, alternatives: ["Dumbbell Curl"], order: 3),
                        PlannedExercise(name: "Hammer Curls", targetMuscles: [.biceps], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 60, order: 4),
                    ]),
                ]
            ),
            WorkoutDay(
                dayOfWeek: .friday, dayType: .training,
                title: "Lower Body Power",
                focusMuscles: [.quads, .hamstrings, .glutes, .core],
                estimatedDuration: 50, estimatedCalories: 500,
                phases: [
                    WorkoutPhaseData(type: .warmup, exercises: [
                        PlannedExercise(name: "Hip Circles", targetMuscles: [.glutes], sets: 2, repRangeLow: 10, repRangeHigh: 10, restSeconds: 30, order: 0),
                    ]),
                    WorkoutPhaseData(type: .main, exercises: [
                        PlannedExercise(name: "Deadlift", targetMuscles: [.hamstrings, .glutes, .back], sets: 4, repRangeLow: 5, repRangeHigh: 8, restSeconds: 180, alternatives: ["Trap Bar Deadlift"], order: 0),
                        PlannedExercise(name: "Leg Press", targetMuscles: [.quads, .glutes], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 1),
                        PlannedExercise(name: "Hip Thrust", targetMuscles: [.glutes, .hamstrings], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, alternatives: ["Glute Bridge"], order: 2),
                        PlannedExercise(name: "Hanging Leg Raises", targetMuscles: [.core], sets: 3, repRangeLow: 10, repRangeHigh: 15, restSeconds: 60, order: 3),
                    ]),
                ]
            ),
            WorkoutDay(
                dayOfWeek: .saturday, dayType: .activeRecovery,
                title: "Active Recovery",
                estimatedDuration: 30, estimatedCalories: 150
            ),
            WorkoutDay(
                dayOfWeek: .sunday, dayType: .rest,
                title: "Full Rest",
                estimatedDuration: 0, estimatedCalories: 0
            ),
        ]
    }
    
    // MARK: - 3-Day Full Body
    
    private func buildFullBodySplit(profile: UserProfile) -> [WorkoutDay] {
        [
            WorkoutDay(
                dayOfWeek: .monday, dayType: .training,
                title: "Full Body A",
                focusMuscles: [.chest, .back, .quads, .core],
                estimatedDuration: 50, estimatedCalories: 500,
                phases: [
                    WorkoutPhaseData(type: .main, exercises: [
                        PlannedExercise(name: "Barbell Bench Press", targetMuscles: [.chest, .triceps], sets: 3, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 0),
                        PlannedExercise(name: "Barbell Row", targetMuscles: [.back, .biceps], sets: 3, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 1),
                        PlannedExercise(name: "Barbell Back Squat", targetMuscles: [.quads, .glutes], sets: 3, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 2),
                        PlannedExercise(name: "Plank", targetMuscles: [.core], sets: 3, repRangeLow: 30, repRangeHigh: 60, restSeconds: 60, notes: "Hold in seconds", order: 3),
                    ]),
                ]
            ),
            WorkoutDay(dayOfWeek: .tuesday, dayType: .rest, title: "Rest"),
            WorkoutDay(
                dayOfWeek: .wednesday, dayType: .training,
                title: "Full Body B",
                focusMuscles: [.shoulders, .hamstrings, .back, .biceps],
                estimatedDuration: 50, estimatedCalories: 480,
                phases: [
                    WorkoutPhaseData(type: .main, exercises: [
                        PlannedExercise(name: "Overhead Press", targetMuscles: [.shoulders, .triceps], sets: 3, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 0),
                        PlannedExercise(name: "Romanian Deadlift", targetMuscles: [.hamstrings, .glutes], sets: 3, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 1),
                        PlannedExercise(name: "Pull-ups", targetMuscles: [.back, .biceps], sets: 3, repRangeLow: 6, repRangeHigh: 10, restSeconds: 120, order: 2),
                        PlannedExercise(name: "Dumbbell Curl", targetMuscles: [.biceps], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 60, order: 3),
                    ]),
                ]
            ),
            WorkoutDay(dayOfWeek: .thursday, dayType: .rest, title: "Rest"),
            WorkoutDay(
                dayOfWeek: .friday, dayType: .training,
                title: "Full Body C",
                focusMuscles: [.chest, .quads, .glutes, .triceps],
                estimatedDuration: 50, estimatedCalories: 490,
                phases: [
                    WorkoutPhaseData(type: .main, exercises: [
                        PlannedExercise(name: "Incline Dumbbell Press", targetMuscles: [.chest, .shoulders], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 0),
                        PlannedExercise(name: "Bulgarian Split Squat", targetMuscles: [.quads, .glutes], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 1),
                        PlannedExercise(name: "Hip Thrust", targetMuscles: [.glutes], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 2),
                        PlannedExercise(name: "Tricep Pushdowns", targetMuscles: [.triceps], sets: 3, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 3),
                    ]),
                ]
            ),
            WorkoutDay(dayOfWeek: .saturday, dayType: .activeRecovery, title: "Active Recovery", estimatedDuration: 30, estimatedCalories: 150),
            WorkoutDay(dayOfWeek: .sunday, dayType: .rest, title: "Full Rest"),
        ]
    }
    
    // MARK: - 5/6-Day Push/Pull/Legs
    
    private func buildPushPullLegsSplit(profile: UserProfile) -> [WorkoutDay] {
        [
            WorkoutDay(
                dayOfWeek: .monday, dayType: .training,
                title: "Push Day",
                focusMuscles: [.chest, .shoulders, .triceps],
                estimatedDuration: 55, estimatedCalories: 500,
                phases: [
                    WorkoutPhaseData(type: .main, exercises: [
                        PlannedExercise(name: "Barbell Bench Press", targetMuscles: [.chest, .triceps], sets: 4, repRangeLow: 6, repRangeHigh: 8, restSeconds: 150, order: 0),
                        PlannedExercise(name: "Overhead Press", targetMuscles: [.shoulders], sets: 3, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 1),
                        PlannedExercise(name: "Incline Dumbbell Press", targetMuscles: [.chest], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 2),
                        PlannedExercise(name: "Cable Lateral Raises", targetMuscles: [.shoulders], sets: 3, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 3),
                        PlannedExercise(name: "Tricep Pushdowns", targetMuscles: [.triceps], sets: 3, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 4),
                    ]),
                ]
            ),
            WorkoutDay(
                dayOfWeek: .tuesday, dayType: .training,
                title: "Pull Day",
                focusMuscles: [.back, .biceps],
                estimatedDuration: 50, estimatedCalories: 460,
                phases: [
                    WorkoutPhaseData(type: .main, exercises: [
                        PlannedExercise(name: "Deadlift", targetMuscles: [.back, .hamstrings], sets: 4, repRangeLow: 5, repRangeHigh: 8, restSeconds: 180, order: 0),
                        PlannedExercise(name: "Pull-ups", targetMuscles: [.back, .biceps], sets: 3, repRangeLow: 6, repRangeHigh: 10, restSeconds: 120, order: 1),
                        PlannedExercise(name: "Cable Row", targetMuscles: [.back], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 2),
                        PlannedExercise(name: "Face Pulls", targetMuscles: [.shoulders], sets: 3, repRangeLow: 15, repRangeHigh: 20, restSeconds: 60, order: 3),
                        PlannedExercise(name: "Barbell Curl", targetMuscles: [.biceps], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 60, order: 4),
                    ]),
                ]
            ),
            WorkoutDay(
                dayOfWeek: .wednesday, dayType: .training,
                title: "Leg Day",
                focusMuscles: [.quads, .hamstrings, .glutes, .calves],
                estimatedDuration: 55, estimatedCalories: 540,
                phases: [
                    WorkoutPhaseData(type: .main, exercises: [
                        PlannedExercise(name: "Barbell Back Squat", targetMuscles: [.quads, .glutes], sets: 4, repRangeLow: 6, repRangeHigh: 8, restSeconds: 150, order: 0),
                        PlannedExercise(name: "Romanian Deadlift", targetMuscles: [.hamstrings, .glutes], sets: 3, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 1),
                        PlannedExercise(name: "Leg Press", targetMuscles: [.quads], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 2),
                        PlannedExercise(name: "Leg Curl", targetMuscles: [.hamstrings], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 60, order: 3),
                        PlannedExercise(name: "Calf Raises", targetMuscles: [.calves], sets: 4, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 4),
                    ]),
                ]
            ),
            WorkoutDay(dayOfWeek: .thursday, dayType: .rest, title: "Rest & Recovery"),
            WorkoutDay(
                dayOfWeek: .friday, dayType: .training,
                title: "Push Day (Volume)",
                focusMuscles: [.chest, .shoulders, .triceps],
                estimatedDuration: 50, estimatedCalories: 470,
                phases: [
                    WorkoutPhaseData(type: .main, exercises: [
                        PlannedExercise(name: "Dumbbell Bench Press", targetMuscles: [.chest], sets: 4, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 0),
                        PlannedExercise(name: "Arnold Press", targetMuscles: [.shoulders], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 1),
                        PlannedExercise(name: "Cable Flyes", targetMuscles: [.chest], sets: 3, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 2),
                        PlannedExercise(name: "Lateral Raises", targetMuscles: [.shoulders], sets: 3, repRangeLow: 15, repRangeHigh: 20, restSeconds: 60, order: 3),
                        PlannedExercise(name: "Overhead Tricep Extension", targetMuscles: [.triceps], sets: 3, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 4),
                    ]),
                ]
            ),
            WorkoutDay(
                dayOfWeek: .saturday, dayType: .training,
                title: "Pull Day (Volume)",
                focusMuscles: [.back, .biceps],
                estimatedDuration: 50, estimatedCalories: 440,
                phases: [
                    WorkoutPhaseData(type: .main, exercises: [
                        PlannedExercise(name: "Lat Pulldown", targetMuscles: [.back], sets: 4, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 0),
                        PlannedExercise(name: "Dumbbell Row", targetMuscles: [.back], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 1),
                        PlannedExercise(name: "Reverse Flyes", targetMuscles: [.shoulders, .back], sets: 3, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 2),
                        PlannedExercise(name: "Hammer Curls", targetMuscles: [.biceps], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 60, order: 3),
                        PlannedExercise(name: "Incline Dumbbell Curl", targetMuscles: [.biceps], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 60, order: 4),
                    ]),
                ]
            ),
            WorkoutDay(dayOfWeek: .sunday, dayType: .rest, title: "Full Rest"),
        ]
    }
}
