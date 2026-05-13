import Foundation

@MainActor
class ExerciseLibraryManager: ObservableObject {
    
    @Published private(set) var exercises: [Exercise] = []
    
    init() { load() }
    
    // MARK: - Load
    
    private func load() {
        guard let url = Bundle.main.url(forResource: "ExerciseLibrary", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Exercise].self, from: data) else {
            print("⚠️ Failed to load ExerciseLibrary.json")
            return
        }
        exercises = decoded
    }
    
    // MARK: - Filter
    
    func exercises(for muscle: MuscleGroup) -> [Exercise] {
        exercises.filter { $0.primaryMuscles.contains(muscle) || $0.secondaryMuscles.contains(muscle) }
    }
    
    func exercises(primaryMuscle muscle: MuscleGroup) -> [Exercise] {
        exercises.filter { $0.primaryMuscles.contains(muscle) }
    }
    
    func exercises(category: ExerciseCategory) -> [Exercise] {
        exercises.filter { $0.category == category }
    }
    
    func exercises(equipment: Equipment) -> [Exercise] {
        exercises.filter { $0.equipment.contains(equipment) }
    }
    
    func exercises(difficulty: Difficulty) -> [Exercise] {
        exercises.filter { $0.difficulty == difficulty }
    }
    
    // MARK: - Search
    
    func search(_ query: String) -> [Exercise] {
        guard !query.isEmpty else { return exercises }
        let q = query.lowercased()
        return exercises.filter {
            $0.name.lowercased().contains(q) ||
            $0.primaryMuscles.contains(where: { $0.rawValue.contains(q) }) ||
            $0.equipment.contains(where: { $0.rawValue.contains(q) })
        }
    }
    
    // MARK: - Lookup
    
    func exercise(byId id: String) -> Exercise? {
        exercises.first { $0.id == id }
    }
    
    func alternatives(for exercise: Exercise) -> [Exercise] {
        exercise.alternatives.compactMap { self.exercise(byId: $0) }
    }
}
