import SwiftUI

struct PlanEditorView: View {
    
    @EnvironmentObject var planManager: WorkoutPlanManager
    @EnvironmentObject var library: ExerciseLibraryManager
    @Environment(\.dismiss) private var dismiss
    
    let dayId: UUID
    
    @State private var selectedPhaseIndex: Int = 0
    @State private var editingExerciseId: UUID? = nil
    @State private var showAddSheet = false
    @State private var swapTargetId: UUID? = nil
    
    private var day: WorkoutDay? {
        planManager.currentPlan?.weeklySchedule.first { $0.id == dayId }
    }
    
    private var phases: [WorkoutPhaseData] {
        day?.phases ?? []
    }
    
    private var currentPhase: WorkoutPhaseData? {
        guard selectedPhaseIndex < phases.count else { return nil }
        return phases[selectedPhaseIndex]
    }
    
    var body: some View {
        ZStack {
            ColorTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                phaseSelector
                exerciseList
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddSheet) {
            ExercisePickerView(onSelect: addExercise, preselectedMuscle: day?.focusMuscles.first)
                .environmentObject(library)
        }
        .sheet(item: $swapTargetId) { targetId in
            ExercisePickerView(onSelect: { ex in swapExercise(targetId: targetId, with: ex) },
                               preselectedMuscle: day?.focusMuscles.first)
                .environmentObject(library)
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(ColorTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Edit Workout")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text(day?.title ?? "")
                    .font(.system(size: 13))
                    .foregroundColor(ColorTheme.secondary)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Button { showAddSheet = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(ColorTheme.background)
                    .frame(width: 38, height: 38)
                    .background(ColorTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }
    
    // MARK: - Phase Selector
    
    private var phaseSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(phases.enumerated()), id: \.element.id) { index, phase in
                    Button {
                        withAnimation(.spring(response: 0.3)) { selectedPhaseIndex = index }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: phase.type.icon)
                                .font(.system(size: 11, weight: .semibold))
                            Text(phase.type.displayName)
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(selectedPhaseIndex == index ? ColorTheme.background : ColorTheme.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selectedPhaseIndex == index ? ColorTheme.primary : ColorTheme.surface)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 12)
    }
    
    // MARK: - Exercise List
    
    private var exerciseList: some View {
        List {
            if let phase = currentPhase {
                ForEach(phase.exercises) { exercise in
                    editorRow(exercise, phaseId: phase.id)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    planManager.removeExercise(dayId: dayId, phaseId: phase.id, exerciseId: exercise.id)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                swapTargetId = exercise.id
                            } label: {
                                Label("Swap", systemImage: "arrow.left.arrow.right")
                            }
                            .tint(ColorTheme.secondary)
                        }
                }
                .onMove { source, dest in
                    planManager.moveExercise(dayId: dayId, phaseId: phase.id, from: source, to: dest)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, .constant(.active))
    }
    
    // MARK: - Editor Row
    
    private func editorRow(_ exercise: PlannedExercise, phaseId: UUID) -> some View {
        let isEditing = editingExerciseId == exercise.id
        
        return VStack(spacing: 0) {
            // Main row
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(exercise.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text(exercise.targetMuscles.map(\.displayName).joined(separator: ", "))
                        .font(.system(size: 11))
                        .foregroundColor(ColorTheme.textSecondary)
                }
                
                Spacer()
                
                Text("\(exercise.sets)×\(exercise.repRangeText)")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(ColorTheme.primary)
                
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        editingExerciseId = isEditing ? nil : exercise.id
                    }
                } label: {
                    Image(systemName: isEditing ? "chevron.up" : "slider.horizontal.3")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isEditing ? ColorTheme.primary : ColorTheme.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(isEditing ? ColorTheme.primary.opacity(0.12) : Color.white.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(14)
            .contentShape(Rectangle())
            
            // Inline editor
            if isEditing {
                inlineEditor(exercise: exercise, phaseId: phaseId)
            }
        }
        .background(ColorTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isEditing ? ColorTheme.primary.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
        )
    }
    
    // MARK: - Inline Editor
    
    private func inlineEditor(exercise: PlannedExercise, phaseId: UUID) -> some View {
        VStack(spacing: 12) {
            Divider().background(Color.white.opacity(0.08))
            
            HStack(spacing: 12) {
                stepperField("Sets", value: exercise.sets, range: 1...10) { newVal in
                    planManager.updateExercise(dayId: dayId, phaseId: phaseId, exerciseId: exercise.id, sets: newVal)
                }
                stepperField("Rep Low", value: exercise.repRangeLow, range: 1...50) { newVal in
                    planManager.updateExercise(dayId: dayId, phaseId: phaseId, exerciseId: exercise.id, repLow: newVal)
                }
                stepperField("Rep High", value: exercise.repRangeHigh, range: 1...50) { newVal in
                    planManager.updateExercise(dayId: dayId, phaseId: phaseId, exerciseId: exercise.id, repHigh: newVal)
                }
            }
            
            HStack(spacing: 12) {
                stepperField("Rest (s)", value: exercise.restSeconds, range: 0...300, step: 15) { newVal in
                    planManager.updateExercise(dayId: dayId, phaseId: phaseId, exerciseId: exercise.id, rest: newVal)
                }
                Spacer()
            }
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 14)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    private func stepperField(_ label: String, value: Int, range: ClosedRange<Int>, step: Int = 1, onChange: @escaping (Int) -> Void) -> some View {
        VStack(spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundColor(ColorTheme.textSecondary)
            
            HStack(spacing: 0) {
                Button {
                    let newVal = max(range.lowerBound, value - step)
                    onChange(newVal)
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 28, height: 28)
                        .foregroundColor(ColorTheme.textSecondary)
                }
                
                Text("\(value)")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .frame(minWidth: 32)
                
                Button {
                    let newVal = min(range.upperBound, value + step)
                    onChange(newVal)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 28, height: 28)
                        .foregroundColor(ColorTheme.primary)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(ColorTheme.background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    // MARK: - Actions
    
    private func addExercise(_ exercise: Exercise) {
        guard let phase = currentPhase else { return }
        let planned = PlannedExercise(
            name: exercise.name,
            targetMuscles: exercise.primaryMuscles,
            sets: exercise.defaultSets,
            repRangeLow: exercise.defaultRepRange.first ?? 8,
            repRangeHigh: exercise.defaultRepRange.last ?? 12,
            restSeconds: exercise.defaultRest,
            alternatives: exercise.alternatives
        )
        planManager.addExercise(dayId: dayId, phaseId: phase.id, exercise: planned)
    }
    
    private func swapExercise(targetId: UUID, with exercise: Exercise) {
        guard let phase = currentPhase else { return }
        let planned = PlannedExercise(
            name: exercise.name,
            targetMuscles: exercise.primaryMuscles,
            sets: exercise.defaultSets,
            repRangeLow: exercise.defaultRepRange.first ?? 8,
            repRangeHigh: exercise.defaultRepRange.last ?? 12,
            restSeconds: exercise.defaultRest,
            alternatives: exercise.alternatives
        )
        planManager.swapExercise(dayId: dayId, phaseId: phase.id, oldExerciseId: targetId, newExercise: planned)
    }
}

// Make UUID work with .sheet(item:)
extension UUID: @retroactive Identifiable {
    public var id: UUID { self }
}
