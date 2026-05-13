import SwiftUI

struct ExercisePickerView: View {
    
    @EnvironmentObject var library: ExerciseLibraryManager
    @Environment(\.dismiss) private var dismiss
    
    let onSelect: (Exercise) -> Void
    var preselectedMuscle: MuscleGroup? = nil
    
    @State private var searchText = ""
    @State private var selectedMuscle: MuscleGroup? = nil
    
    private var filteredExercises: [Exercise] {
        var results = library.exercises
        if let muscle = selectedMuscle {
            results = results.filter { $0.primaryMuscles.contains(muscle) }
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            results = results.filter { $0.name.lowercased().contains(q) }
        }
        return results
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    muscleFilter
                    
                    List(filteredExercises) { exercise in
                        Button {
                            onSelect(exercise)
                            dismiss()
                        } label: {
                            exerciseRow(exercise)
                        }
                        .listRowBackground(ColorTheme.surface)
                        .listRowSeparatorTint(Color.white.opacity(0.06))
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Exercise Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(ColorTheme.secondary)
                }
            }
            .onAppear {
                selectedMuscle = preselectedMuscle
            }
        }
    }
    
    // MARK: - Muscle Filter
    
    private var muscleFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip("All", isSelected: selectedMuscle == nil) {
                    selectedMuscle = nil
                }
                ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                    filterChip(muscle.displayName, isSelected: selectedMuscle == muscle) {
                        selectedMuscle = muscle
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
    
    private func filterChip(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isSelected ? ColorTheme.background : ColorTheme.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isSelected ? ColorTheme.primary : ColorTheme.surface)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(isSelected ? Color.clear : Color.white.opacity(0.1), lineWidth: 1))
        }
    }
    
    // MARK: - Row
    
    private func exerciseRow(_ exercise: Exercise) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(ColorTheme.primary.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: iconForCategory(exercise.category))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ColorTheme.primary)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                HStack(spacing: 6) {
                    Text(exercise.primaryMuscles.map(\.displayName).joined(separator: ", "))
                        .font(.system(size: 11))
                        .foregroundColor(ColorTheme.primary)
                    Text("•")
                        .foregroundColor(ColorTheme.textSecondary)
                    Text(exercise.equipment.first?.displayName ?? "")
                        .font(.system(size: 11))
                        .foregroundColor(ColorTheme.textSecondary)
                }
                Text("\(exercise.defaultSets) × \(exercise.defaultRepRange.first ?? 0)-\(exercise.defaultRepRange.last ?? 0) reps")
                    .font(.system(size: 11))
                    .foregroundColor(ColorTheme.textSecondary.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(ColorTheme.primary)
        }
        .padding(.vertical, 4)
    }
    
    private func iconForCategory(_ cat: ExerciseCategory) -> String {
        switch cat {
        case .compound: return "figure.strengthtraining.traditional"
        case .isolation: return "scope"
        case .cardio: return "figure.run"
        case .stretch: return "figure.flexibility"
        case .bodyweight: return "figure.core.training"
        }
    }
}
