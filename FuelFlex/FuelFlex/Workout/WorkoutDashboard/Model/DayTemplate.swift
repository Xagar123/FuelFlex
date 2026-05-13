import Foundation

// MARK: - Day Templates

enum DayTemplate: String, CaseIterable, Identifiable {
    case push = "Push (Chest/Shoulders/Triceps)"
    case pull = "Pull (Back/Biceps)"
    case legs = "Legs (Quads/Hams/Glutes)"
    case upperBody = "Upper Body"
    case lowerBody = "Lower Body"
    case fullBody = "Full Body"
    case chestTriceps = "Chest & Triceps"
    case backBiceps = "Back & Biceps"
    case shoulders = "Shoulders & Arms"
    case core = "Core & Conditioning"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
    
    var icon: String {
        switch self {
        case .push: return "arrow.right.circle.fill"
        case .pull: return "arrow.left.circle.fill"
        case .legs: return "figure.walk"
        case .upperBody: return "figure.arms.open"
        case .lowerBody: return "figure.run"
        case .fullBody: return "figure.strengthtraining.traditional"
        case .chestTriceps: return "dumbbell.fill"
        case .backBiceps: return "figure.rowing"
        case .shoulders: return "figure.boxing"
        case .core: return "figure.core.training"
        }
    }
    
    func buildDay(dayOfWeek: DayOfWeek) -> WorkoutDay {
        switch self {
        case .push:
            return WorkoutDay(
                dayOfWeek: dayOfWeek, dayType: .training, title: "Push Day",
                focusMuscles: [.chest, .shoulders, .triceps],
                estimatedDuration: 50, estimatedCalories: 480,
                phases: [WorkoutPhaseData(type: .main, exercises: [
                    PlannedExercise(name: "Barbell Bench Press", targetMuscles: [.chest, .triceps], sets: 4, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 0),
                    PlannedExercise(name: "Overhead Press", targetMuscles: [.shoulders, .triceps], sets: 3, repRangeLow: 8, repRangeHigh: 12, restSeconds: 90, order: 1),
                    PlannedExercise(name: "Incline Dumbbell Press", targetMuscles: [.chest, .shoulders], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 2),
                    PlannedExercise(name: "Cable Lateral Raises", targetMuscles: [.shoulders], sets: 3, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 3),
                    PlannedExercise(name: "Tricep Pushdowns", targetMuscles: [.triceps], sets: 3, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 4),
                ])]
            )
        case .pull:
            return WorkoutDay(
                dayOfWeek: dayOfWeek, dayType: .training, title: "Pull Day",
                focusMuscles: [.back, .biceps],
                estimatedDuration: 50, estimatedCalories: 460,
                phases: [WorkoutPhaseData(type: .main, exercises: [
                    PlannedExercise(name: "Barbell Row", targetMuscles: [.back, .biceps], sets: 4, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 0),
                    PlannedExercise(name: "Pull-ups", targetMuscles: [.back, .biceps], sets: 3, repRangeLow: 6, repRangeHigh: 10, restSeconds: 120, order: 1),
                    PlannedExercise(name: "Face Pulls", targetMuscles: [.shoulders, .back], sets: 3, repRangeLow: 15, repRangeHigh: 20, restSeconds: 60, order: 2),
                    PlannedExercise(name: "Barbell Curl", targetMuscles: [.biceps], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 60, order: 3),
                    PlannedExercise(name: "Hammer Curls", targetMuscles: [.biceps], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 60, order: 4),
                ])]
            )
        case .legs:
            return WorkoutDay(
                dayOfWeek: dayOfWeek, dayType: .training, title: "Leg Day",
                focusMuscles: [.quads, .hamstrings, .glutes, .calves],
                estimatedDuration: 55, estimatedCalories: 540,
                phases: [WorkoutPhaseData(type: .main, exercises: [
                    PlannedExercise(name: "Barbell Back Squat", targetMuscles: [.quads, .glutes], sets: 4, repRangeLow: 6, repRangeHigh: 8, restSeconds: 150, order: 0),
                    PlannedExercise(name: "Romanian Deadlift", targetMuscles: [.hamstrings, .glutes], sets: 3, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 1),
                    PlannedExercise(name: "Leg Press", targetMuscles: [.quads], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 2),
                    PlannedExercise(name: "Leg Curl", targetMuscles: [.hamstrings], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 60, order: 3),
                    PlannedExercise(name: "Calf Raises", targetMuscles: [.calves], sets: 4, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 4),
                ])]
            )
        case .upperBody:
            return WorkoutDay(
                dayOfWeek: dayOfWeek, dayType: .training, title: "Upper Body",
                focusMuscles: [.chest, .back, .shoulders],
                estimatedDuration: 55, estimatedCalories: 500,
                phases: [WorkoutPhaseData(type: .main, exercises: [
                    PlannedExercise(name: "Barbell Bench Press", targetMuscles: [.chest, .triceps], sets: 4, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 0),
                    PlannedExercise(name: "Barbell Row", targetMuscles: [.back, .biceps], sets: 4, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 1),
                    PlannedExercise(name: "Overhead Press", targetMuscles: [.shoulders], sets: 3, repRangeLow: 8, repRangeHigh: 12, restSeconds: 90, order: 2),
                    PlannedExercise(name: "Lat Pulldown", targetMuscles: [.back], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 3),
                    PlannedExercise(name: "Dumbbell Lateral Raises", targetMuscles: [.shoulders], sets: 3, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 4),
                ])]
            )
        case .lowerBody:
            return WorkoutDay(
                dayOfWeek: dayOfWeek, dayType: .training, title: "Lower Body",
                focusMuscles: [.quads, .hamstrings, .glutes],
                estimatedDuration: 55, estimatedCalories: 520,
                phases: [WorkoutPhaseData(type: .main, exercises: [
                    PlannedExercise(name: "Barbell Back Squat", targetMuscles: [.quads, .glutes], sets: 4, repRangeLow: 6, repRangeHigh: 8, restSeconds: 150, order: 0),
                    PlannedExercise(name: "Romanian Deadlift", targetMuscles: [.hamstrings, .glutes], sets: 3, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 1),
                    PlannedExercise(name: "Bulgarian Split Squat", targetMuscles: [.quads, .glutes], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 2),
                    PlannedExercise(name: "Hip Thrust", targetMuscles: [.glutes, .hamstrings], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 3),
                    PlannedExercise(name: "Calf Raises", targetMuscles: [.calves], sets: 4, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 4),
                ])]
            )
        case .fullBody:
            return WorkoutDay(
                dayOfWeek: dayOfWeek, dayType: .training, title: "Full Body",
                focusMuscles: [.chest, .back, .quads, .core],
                estimatedDuration: 50, estimatedCalories: 500,
                phases: [WorkoutPhaseData(type: .main, exercises: [
                    PlannedExercise(name: "Barbell Bench Press", targetMuscles: [.chest, .triceps], sets: 3, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 0),
                    PlannedExercise(name: "Barbell Row", targetMuscles: [.back, .biceps], sets: 3, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 1),
                    PlannedExercise(name: "Barbell Back Squat", targetMuscles: [.quads, .glutes], sets: 3, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 2),
                    PlannedExercise(name: "Overhead Press", targetMuscles: [.shoulders], sets: 3, repRangeLow: 8, repRangeHigh: 12, restSeconds: 90, order: 3),
                    PlannedExercise(name: "Plank", targetMuscles: [.core], sets: 3, repRangeLow: 30, repRangeHigh: 60, restSeconds: 60, notes: "Hold in seconds", order: 4),
                ])]
            )
        case .chestTriceps:
            return WorkoutDay(
                dayOfWeek: dayOfWeek, dayType: .training, title: "Chest & Triceps",
                focusMuscles: [.chest, .triceps],
                estimatedDuration: 45, estimatedCalories: 420,
                phases: [WorkoutPhaseData(type: .main, exercises: [
                    PlannedExercise(name: "Barbell Bench Press", targetMuscles: [.chest, .triceps], sets: 4, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 0),
                    PlannedExercise(name: "Incline Dumbbell Press", targetMuscles: [.chest, .shoulders], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 1),
                    PlannedExercise(name: "Cable Flyes", targetMuscles: [.chest], sets: 3, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 2),
                    PlannedExercise(name: "Close Grip Bench Press", targetMuscles: [.triceps, .chest], sets: 3, repRangeLow: 8, repRangeHigh: 10, restSeconds: 90, order: 3),
                    PlannedExercise(name: "Tricep Pushdowns", targetMuscles: [.triceps], sets: 3, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 4),
                ])]
            )
        case .backBiceps:
            return WorkoutDay(
                dayOfWeek: dayOfWeek, dayType: .training, title: "Back & Biceps",
                focusMuscles: [.back, .biceps],
                estimatedDuration: 50, estimatedCalories: 450,
                phases: [WorkoutPhaseData(type: .main, exercises: [
                    PlannedExercise(name: "Deadlift", targetMuscles: [.back, .hamstrings], sets: 4, repRangeLow: 5, repRangeHigh: 8, restSeconds: 180, order: 0),
                    PlannedExercise(name: "Pull-ups", targetMuscles: [.back, .biceps], sets: 3, repRangeLow: 6, repRangeHigh: 10, restSeconds: 120, order: 1),
                    PlannedExercise(name: "Seated Cable Row", targetMuscles: [.back], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 90, order: 2),
                    PlannedExercise(name: "Barbell Curl", targetMuscles: [.biceps], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 60, order: 3),
                    PlannedExercise(name: "Incline Dumbbell Curl", targetMuscles: [.biceps], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 60, order: 4),
                ])]
            )
        case .shoulders:
            return WorkoutDay(
                dayOfWeek: dayOfWeek, dayType: .training, title: "Shoulders & Arms",
                focusMuscles: [.shoulders, .biceps, .triceps],
                estimatedDuration: 45, estimatedCalories: 400,
                phases: [WorkoutPhaseData(type: .main, exercises: [
                    PlannedExercise(name: "Overhead Press", targetMuscles: [.shoulders, .triceps], sets: 4, repRangeLow: 8, repRangeHigh: 10, restSeconds: 120, order: 0),
                    PlannedExercise(name: "Dumbbell Lateral Raises", targetMuscles: [.shoulders], sets: 3, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 1),
                    PlannedExercise(name: "Face Pulls", targetMuscles: [.shoulders, .back], sets: 3, repRangeLow: 15, repRangeHigh: 20, restSeconds: 60, order: 2),
                    PlannedExercise(name: "Barbell Curl", targetMuscles: [.biceps], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 60, order: 3),
                    PlannedExercise(name: "Skull Crushers", targetMuscles: [.triceps], sets: 3, repRangeLow: 10, repRangeHigh: 12, restSeconds: 60, order: 4),
                ])]
            )
        case .core:
            return WorkoutDay(
                dayOfWeek: dayOfWeek, dayType: .training, title: "Core & Conditioning",
                focusMuscles: [.core, .fullBody],
                estimatedDuration: 35, estimatedCalories: 350,
                phases: [WorkoutPhaseData(type: .main, exercises: [
                    PlannedExercise(name: "Hanging Leg Raises", targetMuscles: [.core], sets: 3, repRangeLow: 10, repRangeHigh: 15, restSeconds: 60, order: 0),
                    PlannedExercise(name: "Cable Woodchops", targetMuscles: [.core], sets: 3, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 1),
                    PlannedExercise(name: "Plank", targetMuscles: [.core], sets: 3, repRangeLow: 30, repRangeHigh: 60, restSeconds: 60, notes: "Hold in seconds", order: 2),
                    PlannedExercise(name: "Russian Twist", targetMuscles: [.core], sets: 3, repRangeLow: 15, repRangeHigh: 20, restSeconds: 60, order: 3),
                    PlannedExercise(name: "Kettlebell Swing", targetMuscles: [.fullBody, .glutes], sets: 3, repRangeLow: 12, repRangeHigh: 15, restSeconds: 60, order: 4),
                ])]
            )
        }
    }
}
