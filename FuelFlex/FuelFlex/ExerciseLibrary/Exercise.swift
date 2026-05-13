import Foundation

// MARK: - Exercise Model

struct Exercise: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: ExerciseCategory
    let equipment: [Equipment]
    let primaryMuscles: [MuscleGroup]
    let secondaryMuscles: [MuscleGroup]
    let difficulty: Difficulty
    let instructions: String
    let alternatives: [String]
    let defaultSets: Int
    let defaultRepRange: [Int] // [low, high]
    let defaultRest: Int // seconds
}

// MARK: - Enums

enum ExerciseCategory: String, Codable, CaseIterable {
    case compound, isolation, cardio, stretch, bodyweight
    var displayName: String { rawValue.capitalized }
}

enum Equipment: String, Codable, CaseIterable {
    case barbell, dumbbell, cable, machine, bodyweight
    case kettlebell, resistanceBand, bench, pullUpBar, ezBar
    case smithMachine, trapBar, foam_roller = "foam_roller"
    var displayName: String { rawValue.replacingOccurrences(of: "_", with: " ").capitalized }
}

enum Difficulty: String, Codable, CaseIterable {
    case beginner, intermediate, advanced
    var displayName: String { rawValue.capitalized }
}
