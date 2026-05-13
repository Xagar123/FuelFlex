//
//  WorkoutPlanModels.swift
//  FuelFlex
//

import Foundation

// MARK: - Enums

enum MuscleGroup: String, Codable, CaseIterable {
    case chest, back, shoulders, biceps, triceps
    case quads, hamstrings, glutes, calves, core, fullBody
    
    var displayName: String { rawValue.capitalized }
}

enum DayOfWeek: Int, Codable, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var shortName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }
    
    var letter: String {
        String(shortName.prefix(1))
    }
}

enum FitnessLevel: String, Codable, CaseIterable {
    case beginner, intermediate, advanced
    
    var displayName: String { rawValue.capitalized }
    
    var icon: String {
        switch self {
        case .beginner: return "figure.walk"
        case .intermediate: return "figure.run"
        case .advanced: return "figure.strengthtraining.traditional"
        }
    }
    
    var description: String {
        switch self {
        case .beginner: return "New to training or returning after a long break"
        case .intermediate: return "1-3 years of consistent training"
        case .advanced: return "3+ years with solid strength base"
        }
    }
}

enum DayType: String, Codable {
    case training, rest, activeRecovery
}

enum WorkoutPhaseType: String, Codable, CaseIterable {
    case warmup, main, finisher, cooldown
    
    var displayName: String { rawValue.capitalized }
    
    var icon: String {
        switch self {
        case .warmup: return "figure.walk"
        case .main: return "dumbbell.fill"
        case .finisher: return "bolt.fill"
        case .cooldown: return "snowflake"
        }
    }
}

// MARK: - Plan Models (AI-generated blueprint)

struct PlannedExercise: Identifiable, Codable {
    let id: UUID
    var name: String
    var targetMuscles: [MuscleGroup]
    var sets: Int
    var repRangeLow: Int
    var repRangeHigh: Int
    var restSeconds: Int
    var notes: String?
    var supersetGroupId: String?
    var alternatives: [String]
    var order: Int
    
    var repRangeText: String { "\(repRangeLow)-\(repRangeHigh)" }
    
    init(name: String, targetMuscles: [MuscleGroup], sets: Int,
         repRangeLow: Int, repRangeHigh: Int, restSeconds: Int = 90,
         notes: String? = nil, supersetGroupId: String? = nil,
         alternatives: [String] = [], order: Int = 0) {
        self.id = UUID()
        self.name = name
        self.targetMuscles = targetMuscles
        self.sets = sets
        self.repRangeLow = repRangeLow
        self.repRangeHigh = repRangeHigh
        self.restSeconds = restSeconds
        self.notes = notes
        self.supersetGroupId = supersetGroupId
        self.alternatives = alternatives
        self.order = order
    }
}

struct WorkoutPhaseData: Identifiable, Codable {
    let id: UUID
    var type: WorkoutPhaseType
    var exercises: [PlannedExercise]
    
    init(type: WorkoutPhaseType, exercises: [PlannedExercise]) {
        self.id = UUID()
        self.type = type
        self.exercises = exercises
    }
}

struct WorkoutDay: Identifiable, Codable {
    let id: UUID
    var dayOfWeek: DayOfWeek
    var dayType: DayType
    var title: String                   // "Push Day"
    var focusMuscles: [MuscleGroup]     // [.chest, .shoulders, .triceps]
    var estimatedDuration: Int          // minutes
    var estimatedCalories: Int
    var phases: [WorkoutPhaseData]
    var isCompleted: Bool
    
    init(dayOfWeek: DayOfWeek, dayType: DayType, title: String,
         focusMuscles: [MuscleGroup] = [], estimatedDuration: Int = 0,
         estimatedCalories: Int = 0, phases: [WorkoutPhaseData] = [],
         isCompleted: Bool = false) {
        self.id = UUID()
        self.dayOfWeek = dayOfWeek
        self.dayType = dayType
        self.title = title
        self.focusMuscles = focusMuscles
        self.estimatedDuration = estimatedDuration
        self.estimatedCalories = estimatedCalories
        self.phases = phases
        self.isCompleted = isCompleted
    }
    
    var mainExercises: [PlannedExercise] {
        phases.first(where: { $0.type == .main })?.exercises ?? []
    }
}

struct WorkoutPlan: Identifiable, Codable {
    let id: UUID
    var userId: String
    var goal: GoalID
    var fitnessLevel: FitnessLevel
    var daysPerWeek: Int
    var createdAt: Date
    var weeklySchedule: [WorkoutDay]
    
    init(userId: String, goal: GoalID, fitnessLevel: FitnessLevel,
         daysPerWeek: Int, weeklySchedule: [WorkoutDay]) {
        self.id = UUID()
        self.userId = userId
        self.goal = goal
        self.fitnessLevel = fitnessLevel
        self.daysPerWeek = daysPerWeek
        self.createdAt = Date()
        self.weeklySchedule = weeklySchedule
    }
}

// MARK: - Log Models (runtime tracking)

struct SetLog: Identifiable, Codable {
    let id: UUID
    var setNumber: Int
    var weight: Double
    var reps: Int
    var isCompleted: Bool
    var isPR: Bool
    var timestamp: Date?
    
    init(setNumber: Int, weight: Double = 0, reps: Int = 0,
         isCompleted: Bool = false, isPR: Bool = false) {
        self.id = UUID()
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
        self.isPR = isPR
    }
}

struct ExerciseLog: Identifiable, Codable {
    let id: UUID
    var plannedExerciseId: UUID
    var name: String
    var targetMuscles: [MuscleGroup]
    var setLogs: [SetLog]
    
    init(from planned: PlannedExercise) {
        self.id = UUID()
        self.plannedExerciseId = planned.id
        self.name = planned.name
        self.targetMuscles = planned.targetMuscles
        self.setLogs = (1...planned.sets).map { SetLog(setNumber: $0) }
    }
}

struct WorkoutLog: Identifiable, Codable {
    let id: UUID
    var workoutDayId: UUID
    var startTime: Date
    var endTime: Date?
    var exerciseLogs: [ExerciseLog]
    
    init(from day: WorkoutDay) {
        self.id = UUID()
        self.workoutDayId = day.id
        self.startTime = Date()
        let allExercises = day.phases.flatMap(\.exercises)
        self.exerciseLogs = allExercises.map { ExerciseLog(from: $0) }
    }
    
    var totalVolume: Int {
        exerciseLogs.flatMap(\.setLogs)
            .filter(\.isCompleted)
            .reduce(0) { $0 + Int($1.weight) * $1.reps }
    }
    
    var prCount: Int {
        exerciseLogs.flatMap(\.setLogs).filter(\.isPR).count
    }
    
    var duration: TimeInterval {
        (endTime ?? Date()).timeIntervalSince(startTime)
    }
}
