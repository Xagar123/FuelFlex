import Foundation

// MARK: - SetStatus

enum SetStatus {
    case done, active, upcoming
}

// MARK: - WorkoutSet

struct WorkoutSet: Identifiable {
    let id = UUID()
    var weight: Double
    var reps: Int
    var status: SetStatus = .upcoming
    var isPR: Bool = false
    var previousWeight: Double?
    var previousReps: Int?
}

// MARK: - WorkoutExercise

struct WorkoutExercise: Identifiable {
    let id = UUID()
    var plannedExerciseId: UUID?
    var name: String
    var targetMuscles: [String]
    var sets: [WorkoutSet]
    var notes: String = ""
    var isSuperset: Bool = false
    var supersetGroupId: String?
    var alternatives: [String] = []
    var restSeconds: Int = 90
}

// MARK: - WorkoutSession

struct WorkoutSession {
    var workoutDayId: UUID?
    var title: String = ""
    var exercises: [WorkoutExercise]
    var startTime: Date = Date()
    var currentExerciseIndex: Int = 0
    var isComplete: Bool = false
    
    /// Build a live session from a WorkoutDay's plan data
    static func from(_ day: WorkoutDay) -> WorkoutSession {
        let allExercises = day.phases.flatMap(\.exercises)
        let exercises = allExercises.map { planned -> WorkoutExercise in
            let sets = (0..<planned.sets).map { i -> WorkoutSet in
                WorkoutSet(
                    weight: 0,
                    reps: planned.repRangeHigh,
                    status: i == 0 ? .active : .upcoming
                )
            }
            return WorkoutExercise(
                plannedExerciseId: planned.id,
                name: planned.name,
                targetMuscles: planned.targetMuscles.map(\.displayName),
                sets: sets,
                notes: planned.notes ?? "",
                isSuperset: planned.supersetGroupId != nil,
                supersetGroupId: planned.supersetGroupId,
                alternatives: planned.alternatives,
                restSeconds: planned.restSeconds
            )
        }
        
        return WorkoutSession(
            workoutDayId: day.id,
            title: day.title,
            exercises: exercises
        )
    }
}

// MARK: - PlateCalculator

struct PlateCalculator {
    private static let barWeight: Double = 45
    private static let availablePlates: [Double] = [45, 35, 25, 10, 5, 2.5]

    static func platesPerSide(for totalWeight: Double) -> [Double] {
        var remaining = (totalWeight - barWeight) / 2
        guard remaining > 0 else { return [] }
        var plates: [Double] = []
        for plate in availablePlates {
            while remaining >= plate {
                plates.append(plate)
                remaining -= plate
            }
        }
        return plates
    }
}
