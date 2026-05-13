//
//  WorkoutActiveScreen.swift
//  FuelFlex
//
//  Complete Workout Active Exercise Screen with all features
//

import SwiftUI
import AVKit

// MARK: - Exercise Replacement Data

struct ReplacementExercise: Identifiable {
    let id = UUID()
    let name: String
    let muscles: [String]
}

// MARK: - Main Screen

struct WorkoutActiveScreen: View {

    @EnvironmentObject var planManager: WorkoutPlanManager
    let workoutDay: WorkoutDay?
    var onWorkoutComplete: (() -> Void)? = nil

    // MARK: - Session State
    @State private var session: WorkoutSession
    
    init(workoutDay: WorkoutDay? = nil, onWorkoutComplete: (() -> Void)? = nil) {
        self.workoutDay = workoutDay
        self.onWorkoutComplete = onWorkoutComplete
        if let day = workoutDay {
            _session = State(initialValue: WorkoutSession.from(day))
        } else {
            // Fallback for preview / legacy usage
            _session = State(initialValue: WorkoutSession(exercises: [
                WorkoutExercise(name: "Dumbbell Bench Press", targetMuscles: ["Chest", "Triceps"],
                    sets: [
                        WorkoutSet(weight: 45, reps: 10, status: .active),
                        WorkoutSet(weight: 45, reps: 10),
                        WorkoutSet(weight: 45, reps: 10)
                    ])
            ]))
        }
    }

    // MARK: - UI State
    @Environment(\.dismiss) private var dismiss
    @State private var pulsing = false
    @State private var editingSetID: UUID? = nil
    @State private var editReps = ""
    @State private var editWeight = ""
    @State private var showNotes = false
    @State private var showPlateCalc = false
    @State private var showReplaceSheet = false
    @State private var showCompletion = false
    @State private var prCelebrationSetID: UUID? = nil
    @State private var workoutPaused = false
    @State private var showVideo = false
    @State private var editingStatReps = ""
    @State private var editingStatWeight = ""
    @State private var isEditingStats = false
    @State private var elapsedSeconds: Int = 0
    @State private var durationTimer: Timer? = nil

    // MARK: - Replacement Options (built from planned alternatives)
    private var replacements: [ReplacementExercise] {
        currentExercise.alternatives.map {
            ReplacementExercise(name: $0, muscles: currentExercise.targetMuscles)
        }
    }

    // MARK: - Computed
    private var currentExercise: WorkoutExercise {
        session.exercises[session.currentExerciseIndex]
    }

    private var totalVolume: Int {
        session.exercises.flatMap(\.sets)
            .filter { $0.status == .done }
            .reduce(0) { $0 + Int($1.weight) * $1.reps }
    }

    private var prCount: Int {
        session.exercises.flatMap(\.sets).filter(\.isPR).count
    }

    private var durationString: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            ColorTheme.background.ignoresSafeArea()

            if showCompletion {
                WorkoutCompletionView(
                    totalDuration: TimeInterval(elapsedSeconds),
                    totalVolume: totalVolume,
                    prCount: prCount,
                    exerciseCount: session.exercises.count,
                    onDone: {
                        if let day = workoutDay {
                            var log = planManager.startWorkout(for: day)
                            log.endTime = Date()
                            planManager.completeWorkout(log)
                        }
                        onWorkoutComplete?()
                    }
                )
            } else {
                mainContent
            }

            overlayViews
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showVideo) {
            if let url = Bundle.main.url(forResource: "ChestFly", withExtension: "mp4") {
                let player = AVPlayer(url: url)
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .preferredColorScheme(.dark)
                    .onAppear {
//                        player.play()
                    }
            }
        }
    }

    // MARK: - Overlays (extracted to break cycle)
    @ViewBuilder
    private var overlayViews: some View {
        let showAny = showNotes || showPlateCalc || showReplaceSheet || prCelebrationSetID != nil
        if showAny {
            if showNotes {
                overlayBackground
                ExerciseNotesView(
                    notes: Binding(
                        get: { session.exercises[session.currentExerciseIndex].notes },
                        set: { session.exercises[session.currentExerciseIndex].notes = $0 }
                    ),
                    onDismiss: { withAnimation(.spring(response: 0.4)) { showNotes = false } }
                )
            } else if showPlateCalc {
                overlayBackground
                PlateCalculatorView(
                    targetWeight: Int(currentExercise.sets.first(where: { $0.status == .active })?.weight ?? currentExercise.sets.first?.weight ?? 0),
                    onDismiss: { withAnimation(.spring(response: 0.4)) { showPlateCalc = false } }
                )
            } else if showReplaceSheet {
                overlayBackground
                replaceExerciseSheet
            }

            if prCelebrationSetID != nil {
                prCelebrationOverlay
            }
        }
    }

    private var overlayBackground: some View {
        Color.black.opacity(0.6).ignoresSafeArea()
            .onTapGesture {
                withAnimation(.spring(response: 0.4)) {
                    showNotes = false
                    showPlateCalc = false
                    showReplaceSheet = false
                }
            }
    }

    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            topBar
                .background(ColorTheme.background)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    progressSegments
                    supersetBadge
                    exerciseHero
                    actionButtonsRow
                    statsRow
                    progressiveOverloadHint
                    setsSection
                    addRemoveSetButtons
                    notesPreview
                    restTimerCard
                    nextExerciseCard
                    Spacer(minLength: 100)
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulsing = true
            }
        }
    }

    // MARK: - Grid Overlay
    var gridOverlay: some View {
        EmptyView()
    }

    // MARK: - Top Bar
    var topBar: some View {
        HStack {
            iconButton(icon: "xmark") { dismiss() }
            Spacer()
            VStack(spacing: 3) {
                Text(session.title.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .tracking(2.5)
                    .foregroundStyle(
                        LinearGradient(colors: [ColorTheme.primary, ColorTheme.secondary],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                Text("Exercise \(session.currentExerciseIndex + 1) of \(session.exercises.count)")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1)
                    .foregroundColor(ColorTheme.textSecondary)
            }
            Spacer()
            // Live duration badge
            HStack(spacing: 4) {
                Circle()
                    .fill(workoutPaused ? ColorTheme.textSecondary : ColorTheme.primary)
                    .frame(width: 6, height: 6)
                Text(durationString)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(ColorTheme.surface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(ColorTheme.primary.opacity(0.25), lineWidth: 1))
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .onAppear {
            durationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if !workoutPaused && !showCompletion {
                    DispatchQueue.main.async { elapsedSeconds += 1 }
                }
            }
        }
        .onDisappear {
            durationTimer?.invalidate()
            durationTimer = nil
        }
    }

    func iconButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(ColorTheme.secondary)
                .frame(width: 38, height: 38)
                .background(ColorTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(ColorTheme.secondary.opacity(0.2), lineWidth: 1)
                )
        }
    }

    // MARK: - Progress Segments
    var progressSegments: some View {
        HStack(spacing: 5) {
            ForEach(0..<session.exercises.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        i < session.currentExerciseIndex ? AnyShapeStyle(ColorTheme.primary) :
                        i == session.currentExerciseIndex ? AnyShapeStyle(LinearGradient(colors: [ColorTheme.primary, ColorTheme.secondary],
                                                               startPoint: .leading, endPoint: .trailing)) :
                        AnyShapeStyle(Color.white.opacity(0.1))
                    )
                    .frame(height: 3)
                    .shadow(color: i <= session.currentExerciseIndex ? ColorTheme.primary.opacity(0.6) : .clear, radius: 4)
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 14)
    }

    // MARK: - Superset Badge
    @ViewBuilder
    var supersetBadge: some View {
        if currentExercise.isSuperset, let groupId = currentExercise.supersetGroupId {
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 10, weight: .bold))
                Text("SUPERSET \(groupId)")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
            }
            .foregroundColor(ColorTheme.accent)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(ColorTheme.accent.opacity(0.1))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(ColorTheme.accent.opacity(0.3), lineWidth: 1))
            .padding(.bottom, 8)
        }
    }

    // MARK: - Exercise Hero
    var exerciseHero: some View {
        ZStack(alignment: .bottomLeading) {
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#0c1220"), Color(hex: "#182540"), Color(hex: "#0c1220")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 320)

                RadialGradient(
                    colors: [ColorTheme.secondary.opacity(0.08), .clear],
                    center: .center, startRadius: 0, endRadius: 160
                )
            }

            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                LinearGradient(
                    colors: [ColorTheme.background.opacity(0.98), .clear],
                    startPoint: .bottom, endPoint: .top
                )
                .frame(height: 90)
                .overlay(
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(currentExercise.name)
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(.white)
                            HStack(spacing: 8) {
                                ForEach(currentExercise.targetMuscles, id: \.self) { muscle in
                                    muscleTag(muscle, color: currentExercise.targetMuscles.firstIndex(of: muscle) == 0 ? ColorTheme.primary : ColorTheme.secondary)
                                }
                            }
                        }
                        .padding(.leading, 16)
                        .padding(.bottom, 14)
                        Spacer()
                        Button(action: { showVideo = true }) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(
                                    LinearGradient(colors: [ColorTheme.primary, ColorTheme.secondary],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .shadow(color: ColorTheme.secondary.opacity(0.5), radius: 8)
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 14)
                    },
                    alignment: .bottom
                )
            }
        }
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(colors: [ColorTheme.primary.opacity(0.4), ColorTheme.secondary.opacity(0.3)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1.5
                )
        )
        .shadow(color: ColorTheme.primary.opacity(0.1), radius: 20, x: 0, y: 8)
        .padding(.horizontal, 16)
    }

    func muscleTag(_ text: String, color: Color) -> some View {
        Text(text.uppercased())
            .font(.system(size: 9, weight: .bold))
            .tracking(1.5)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.4), lineWidth: 1))
    }

    // MARK: - Action Buttons Row
    var actionButtonsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                actionChip(icon: workoutPaused ? "play.fill" : "pause.fill",
                           label: workoutPaused ? "Resume" : "Pause",
                           color: ColorTheme.textSecondary) { workoutPaused.toggle() }
                actionChip(icon: "stop.fill", label: "End", color: ColorTheme.danger) {
                    withAnimation { showCompletion = true }
                }
                actionChip(icon: "note.text", label: "Notes", color: ColorTheme.secondary) { withAnimation(.spring(response: 0.4)) { showNotes = true } }
                if currentExercise.sets.first(where: { $0.status == .active })?.weight ?? 0 >= 45 {
                    actionChip(icon: "circle.grid.2x1.fill", label: "Plates", color: ColorTheme.secondary) { withAnimation(.spring(response: 0.4)) { showPlateCalc = true } }
                }
                actionChip(icon: "arrow.left.arrow.right", label: "Replace", color: ColorTheme.secondary) { withAnimation(.spring(response: 0.4)) { showReplaceSheet = true } }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 12)
    }

    func actionChip(icon: String, label: String, color: Color = ColorTheme.secondary, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(label)
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(0.08))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.2), lineWidth: 1))
        }
    }

    // MARK: - Stats Row
    @ViewBuilder
    var statsRow: some View {
        let activeSet = currentExercise.sets.first(where: { $0.status == .active }) ?? currentExercise.sets.first

        VStack(spacing: 0) {
            if isEditingStats {
                // Editing mode
                HStack(spacing: 12) {
                    editableStatField(label: "REPS", value: $editingStatReps, color: ColorTheme.primary)
                    editableStatField(label: "WEIGHT (LB)", value: $editingStatWeight, color: ColorTheme.secondary)
                }
                .padding(14)

                Button {
                    if let setIdx = currentExercise.sets.firstIndex(where: { $0.status == .active }) {
                        let exIdx = session.currentExerciseIndex
                        session.exercises[exIdx].sets[setIdx].reps = Int(editingStatReps) ?? activeSet?.reps ?? 0
                        session.exercises[exIdx].sets[setIdx].weight = Double(Int(editingStatWeight) ?? Int(activeSet?.weight ?? 0))
                    }
                    withAnimation { isEditingStats = false }
                } label: {
                    Text("Apply")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(ColorTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(ColorTheme.buttonGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
            } else {
                // Display mode
                HStack(spacing: 0) {
                    statBlock(label: "TARGET REPS", value: "\(activeSet?.reps ?? 0)", unit: "reps")
                    Divider().frame(height: 40).background(Color.white.opacity(0.08))
                    statBlock(label: "WEIGHT (LB)", value: "\(Int(activeSet?.weight ?? 0))", unit: "lbs")
                }
                .overlay(alignment: .topTrailing) {
                    Button {
                        editingStatReps = "\(activeSet?.reps ?? 0)"
                        editingStatWeight = "\(Int(activeSet?.weight ?? 0))"
                        withAnimation { isEditingStats = true }
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(ColorTheme.textSecondary.opacity(0.5))
                            .frame(width: 28, height: 28)
                            .background(Color.white.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    .padding(8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(ColorTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(
            isEditingStats ? ColorTheme.secondary.opacity(0.3) : ColorTheme.secondary.opacity(0.12), lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .animation(.spring(response: 0.35), value: isEditingStats)
    }

    func editableStatField(label: String, value: Binding<String>, color: Color) -> some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(1.5)
                .foregroundColor(ColorTheme.textSecondary)
            TextField("0", text: value)
                .keyboardType(.numberPad)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(LinearGradient(colors: [.white, color.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                .multilineTextAlignment(.center)
                .padding(.vertical, 8)
                .background(color.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.25), lineWidth: 1))
        }
        .frame(maxWidth: .infinity)
    }

    func statBlock(label: String, value: String, unit: String) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(2)
                .foregroundColor(ColorTheme.textSecondary)
            Text(value)
                .font(.system(size: 36, weight: .black))
                .foregroundStyle(
                    LinearGradient(colors: [ColorTheme.primary, ColorTheme.secondary],
                                   startPoint: .leading, endPoint: .trailing)
                )
            Text(unit)
                .font(.system(size: 10))
                .foregroundColor(ColorTheme.textSecondary.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }

    // MARK: - Progressive Overload Hint
    @ViewBuilder
    var progressiveOverloadHint: some View {
        if let activeSet = currentExercise.sets.first(where: { $0.status == .active }),
           let prevW = activeSet.previousWeight, let prevR = activeSet.previousReps {
            HStack(spacing: 6) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(ColorTheme.golden)
                Text("Last time: \(Int(prevW)) lb × \(prevR) reps")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(ColorTheme.golden)
                if activeSet.weight > prevW || activeSet.reps > prevR {
                    Text("↑")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(ColorTheme.primary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(ColorTheme.golden.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(ColorTheme.golden.opacity(0.2), lineWidth: 1))
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    // MARK: - Sets Section
    var setsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SETS")
                .font(.system(size: 10, weight: .bold))
                .tracking(2.5)
                .foregroundColor(ColorTheme.textSecondary)
                .padding(.leading, 2)

            ForEach(currentExercise.sets) { set in
                setRow(set)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
    }

    // MARK: - Add/Remove Set Buttons
    var addRemoveSetButtons: some View {
        HStack(spacing: 10) {
            Button {
                withAnimation(.spring(response: 0.4)) {
                    let newNumber = currentExercise.sets.count + 1
                    let lastSet = currentExercise.sets.last
                    let newSet = WorkoutSet(weight: lastSet?.weight ?? 0, reps: lastSet?.reps ?? 10)
                    session.exercises[session.currentExerciseIndex].sets.append(newSet)
                    _ = newNumber // suppress warning
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                    Text("Add Set")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(ColorTheme.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(ColorTheme.primary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(ColorTheme.primary.opacity(0.2), lineWidth: 1))
            }

            if currentExercise.sets.count > 1 {
                Button {
                    withAnimation(.spring(response: 0.4)) {
                        if let last = currentExercise.sets.last, last.status == .upcoming {
                            session.exercises[session.currentExerciseIndex].sets.removeLast()
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "minus")
                            .font(.system(size: 11, weight: .bold))
                        Text("Remove")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(ColorTheme.danger)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(ColorTheme.danger.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(ColorTheme.danger.opacity(0.2), lineWidth: 1))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    // MARK: - Notes Preview
    @ViewBuilder
    var notesPreview: some View {
        if !currentExercise.notes.isEmpty {
            HStack(spacing: 8) {
                Image(systemName: "note.text")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(ColorTheme.secondary)
                Text(currentExercise.notes)
                    .font(.system(size: 12))
                    .foregroundColor(ColorTheme.textSecondary)
                    .lineLimit(2)
                Spacer()
                Button { showNotes = true } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(ColorTheme.textSecondary.opacity(0.5))
                }
            }
            .padding(12)
            .background(ColorTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.06), lineWidth: 1))
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
    }

    // MARK: - Set Row
    @ViewBuilder
    func setRow(_ set: WorkoutSet) -> some View {
        let isEditing = editingSetID == set.id
        let isActive = set.status == .active

        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Circle indicator
                ZStack {
                    Circle()
                        .fill(setCircleFill(set.status))
                        .frame(width: 36, height: 36)
                        .overlay(Circle().stroke(setCircleBorder(set.status), lineWidth: 1.5))
                        .shadow(color: setCircleShadow(set.status), radius: 6)

                    if set.status == .done {
                        if set.isPR {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(ColorTheme.golden)
                        } else {
                            Image(systemName: isEditing ? "pencil" : "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(isEditing ? ColorTheme.secondary : ColorTheme.primary)
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(response: 0.3), value: isEditing)
                        }
                    } else {
                        let idx = currentExercise.sets.firstIndex(where: { $0.id == set.id }) ?? 0
                        Text("\(idx + 1)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(isActive ? ColorTheme.secondary : ColorTheme.textSecondary)
                    }
                }

                // Labels
                VStack(alignment: .leading, spacing: 3) {
                    let idx = currentExercise.sets.firstIndex(where: { $0.id == set.id }) ?? 0
                    HStack(spacing: 6) {
                        Text("Set \(idx + 1)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(set.status == .upcoming ? ColorTheme.textSecondary : .white)
                        if set.isPR {
                            Text("PR!")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(ColorTheme.golden)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(ColorTheme.golden.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }

                    if isActive {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(ColorTheme.secondary)
                                .frame(width: 5, height: 5)
                                .opacity(pulsing ? 1 : 0.3)
                            Text("Active Target")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(ColorTheme.secondary)
                        }
                    } else if isEditing {
                        Text("Editing...")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(colors: [ColorTheme.primary, ColorTheme.secondary],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                    } else {
                        Text("\(set.reps) Reps · \(Int(set.weight)) lb")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.35))
                    }
                }

                Spacer()

                // Right action
                if isActive {
                    Button(action: { handleDone(set: set) }) {
                        Text("Done")
                            .font(.system(size: 14, weight: .bold))
                            .tracking(1)
                            .foregroundColor(ColorTheme.background)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 9)
                            .background(ColorTheme.buttonGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: ColorTheme.primary.opacity(0.4), radius: 10)
                    }
                } else if set.status == .done {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            if isEditing { editingSetID = nil }
                            else {
                                editReps = "\(set.reps)"
                                editWeight = "\(Int(set.weight))"
                                editingSetID = set.id
                            }
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isEditing ? ColorTheme.secondary.opacity(0.15) : Color.white.opacity(0.04))
                                .frame(width: 34, height: 34)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isEditing ? ColorTheme.secondary.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1)
                                )
                            Image(systemName: isEditing ? "xmark" : "pencil")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(isEditing ? ColorTheme.secondary : ColorTheme.textSecondary.opacity(0.5))
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)

            // Edit Panel
            if isEditing {
                VStack(spacing: 12) {
                    Divider().background(ColorTheme.secondary.opacity(0.2)).padding(.horizontal, 4)

                    HStack(spacing: 12) {
                        editField(icon: "repeat", label: "REPS", value: $editReps, color: ColorTheme.primary, keyboard: .numberPad)
                        editField(icon: "scalemass.fill", label: "WEIGHT (LB)", value: $editWeight, color: ColorTheme.secondary, keyboard: .decimalPad)
                    }
                    .padding(.horizontal, 4)

                    Button(action: { saveEdit(set: set) }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 15))
                            Text("Save Changes")
                                .font(.system(size: 14, weight: .bold))
                                .tracking(0.8)
                        }
                        .foregroundColor(ColorTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(ColorTheme.buttonGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: ColorTheme.primary.opacity(0.35), radius: 10)
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 4)
                }
                .transition(.asymmetric(
                    insertion: .push(from: .top).combined(with: .opacity),
                    removal: .push(from: .bottom).combined(with: .opacity)
                ))
            }
        }
        .background(setBackground(set.status))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isEditing
                        ? LinearGradient(colors: [ColorTheme.primary.opacity(0.5), ColorTheme.secondary.opacity(0.4)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [setStroke(set.status), setStroke(set.status)],
                                         startPoint: .leading, endPoint: .trailing),
                    lineWidth: isEditing || isActive ? 1.5 : 1
                )
        )
        .shadow(
            color: isEditing ? ColorTheme.primary.opacity(0.12) :
                   isActive ? ColorTheme.secondary.opacity(pulsing ? 0.18 : 0.06) : .clear,
            radius: isEditing ? 20 : (pulsing ? 16 : 8)
        )
    }

    // MARK: - Edit Field
    func editField(icon: String, label: String, value: Binding<String>, color: Color, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 9, weight: .bold)).foregroundColor(color)
                Text(label).font(.system(size: 9, weight: .bold)).tracking(1.5).foregroundColor(ColorTheme.textSecondary)
            }
            HStack {
                TextField("0", text: value)
                    .keyboardType(keyboard)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [.white, color.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 10)
            .background(color.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.25), lineWidth: 1))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Rest Timer
    var restTimerCard: some View {
        RestTimerView(initialSeconds: currentExercise.restSeconds) {
            moveToNextSet()
        } onSkip: {
            moveToNextSet()
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
    }

    // MARK: - Next Exercise Card
    @ViewBuilder
    var nextExerciseCard: some View {
        let nextIdx = session.currentExerciseIndex + 1
        if nextIdx < session.exercises.count {
            let next = session.exercises[nextIdx]
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: [Color(hex: "#162035"), Color(hex: "#0c1828")],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 52, height: 52)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(ColorTheme.primary.opacity(0.25), lineWidth: 1))
                    Text(next.isSuperset ? "🔄" : "💪").font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("NEXT UP")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(2)
                        .foregroundColor(ColorTheme.textSecondary)
                    Text(next.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(next.sets.count) × \(next.sets.first?.reps ?? 0) reps")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(ColorTheme.primary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.2))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(ColorTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
    }

    // MARK: - Replace Exercise Sheet
    var replaceExerciseSheet: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Replace Exercise")
                    .font(.headline).foregroundColor(.white)
                Spacer()
                Button { showReplaceSheet = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ColorTheme.textSecondary).font(.title3)
                }
            }

            Text("Replacing: \(currentExercise.name)")
                .font(.caption).foregroundColor(ColorTheme.textSecondary)

            ForEach(replacements) { r in
                Button {
                    withAnimation(.spring(response: 0.4)) {
                        session.exercises[session.currentExerciseIndex].name = r.name
                        session.exercises[session.currentExerciseIndex].targetMuscles = r.muscles
                        showReplaceSheet = false
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(r.name).font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                            Text(r.muscles.joined(separator: ", "))
                                .font(.system(size: 11)).foregroundColor(ColorTheme.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.2))
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(20)
        .background(ColorTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(24)
    }

    // MARK: - PR Celebration Overlay
    var prCelebrationOverlay: some View {
        VStack(spacing: 12) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 48))
                .foregroundStyle(LinearGradient(colors: [ColorTheme.golden, ColorTheme.accent], startPoint: .top, endPoint: .bottom))
                .shadow(color: ColorTheme.golden.opacity(0.6), radius: 16)
            Text("NEW PR!")
                .font(.system(size: 20, weight: .black))
                .tracking(3)
                .foregroundColor(ColorTheme.golden)
        }
        .transition(.scale.combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { prCelebrationSetID = nil }
            }
        }
    }

    // MARK: - Actions

    func handleDone(set: WorkoutSet) {
        let exIdx = session.currentExerciseIndex
        guard let setIdx = session.exercises[exIdx].sets.firstIndex(where: { $0.id == set.id }) else { return }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            session.exercises[exIdx].sets[setIdx].status = .done

            // PR Detection
            if let prevW = set.previousWeight, let prevR = set.previousReps {
                if set.weight > prevW || (set.weight == prevW && set.reps > prevR) {
                    session.exercises[exIdx].sets[setIdx].isPR = true
                    prCelebrationSetID = set.id
                }
            }

            // Advance to next set or next exercise
            if setIdx + 1 < session.exercises[exIdx].sets.count {
                session.exercises[exIdx].sets[setIdx + 1].status = .active
            } else {
                // All sets done — move to next exercise
                advanceToNextExercise()
            }
        }
    }

    func advanceToNextExercise() {
        if session.currentExerciseIndex + 1 < session.exercises.count {
            session.currentExerciseIndex += 1
            // Activate first set of new exercise
            if !session.exercises[session.currentExerciseIndex].sets.isEmpty {
                session.exercises[session.currentExerciseIndex].sets[0].status = .active
            }
        } else {
            session.isComplete = true
            withAnimation { showCompletion = true }
        }
    }

    func moveToNextSet() {
        let exIdx = session.currentExerciseIndex
        guard let activeSet = session.exercises[exIdx].sets.first(where: { $0.status == .active }) else { return }
        handleDone(set: activeSet)
    }

    func saveEdit(set: WorkoutSet) {
        let exIdx = session.currentExerciseIndex
        guard let setIdx = session.exercises[exIdx].sets.firstIndex(where: { $0.id == set.id }) else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            session.exercises[exIdx].sets[setIdx].reps = Int(editReps) ?? set.reps
            session.exercises[exIdx].sets[setIdx].weight = Double(Int(editWeight) ?? Int(set.weight))
            editingSetID = nil
        }
    }

    // MARK: - Style Helpers

    func setBackground(_ status: SetStatus) -> Color {
        switch status {
        case .done: return ColorTheme.primary.opacity(0.04)
        case .active: return ColorTheme.secondary.opacity(0.08)
        case .upcoming: return Color.white.opacity(0.02)
        }
    }

    func setStroke(_ status: SetStatus) -> Color {
        switch status {
        case .done: return ColorTheme.primary.opacity(0.15)
        case .active: return ColorTheme.secondary.opacity(0.4)
        case .upcoming: return Color.white.opacity(0.06)
        }
    }

    func setCircleFill(_ status: SetStatus) -> Color {
        switch status {
        case .done: return ColorTheme.primary.opacity(0.12)
        case .active: return ColorTheme.secondary.opacity(0.15)
        case .upcoming: return Color.white.opacity(0.04)
        }
    }

    func setCircleBorder(_ status: SetStatus) -> Color {
        switch status {
        case .done: return ColorTheme.primary.opacity(0.6)
        case .active: return ColorTheme.secondary
        case .upcoming: return Color.white.opacity(0.12)
        }
    }

    func setCircleShadow(_ status: SetStatus) -> Color {
        switch status {
        case .active: return ColorTheme.secondary.opacity(0.4)
        default: return .clear
        }
    }
}

// MARK: - Barbell Illustration

struct BarbellIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4).fill(Color(hex: "#2a3a54")).frame(width: 240, height: 8)
            RoundedRectangle(cornerRadius: 5).fill(Color(hex: "#1d2d45")).frame(width: 22, height: 46).offset(x: -95)
            RoundedRectangle(cornerRadius: 5).fill(Color(hex: "#1d2d45")).frame(width: 22, height: 46).offset(x: 95)
            RoundedRectangle(cornerRadius: 4).fill(Color(hex: "#253650")).frame(width: 130, height: 10).offset(y: 42)
            RoundedRectangle(cornerRadius: 4).fill(Color(hex: "#1e2e45")).frame(width: 120, height: 14).offset(y: 52)
            RoundedRectangle(cornerRadius: 2).fill(Color(hex: "#1a2840")).frame(width: 9, height: 18).offset(x: -46, y: 66)
            RoundedRectangle(cornerRadius: 2).fill(Color(hex: "#1a2840")).frame(width: 9, height: 18).offset(x: 46, y: 66)
            Ellipse().stroke(ColorTheme.secondary.opacity(0.15), lineWidth: 1).frame(width: 200, height: 10).offset(y: 2)
        }
        .frame(width: 280, height: 180)
    }
}

// MARK: - Preview

#Preview {
    WorkoutActiveScreen(workoutDay: nil)
        .preferredColorScheme(.dark)
        .environmentObject(WorkoutPlanManager())
}
