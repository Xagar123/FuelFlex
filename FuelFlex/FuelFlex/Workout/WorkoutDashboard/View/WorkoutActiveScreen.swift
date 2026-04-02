//
//  WorkoutActiveScreen.swift
//  FuelFlex
//
//  Complete Upper Body Strength - Active Exercise Screen
//

import SwiftUI


// MARK: - Data Models

enum SetStatus { case done, active, upcoming }

struct WorkoutSet: Identifiable {
    let id = UUID()
    let number: Int
    var reps: Int
    var weight: Int
    var status: SetStatus
}

// MARK: - Main Screen

struct WorkoutActiveScreen: View {
    @State private var timeRemaining: Int = 59
    @State private var totalTime: Int = 60
    @State private var timerActive: Bool = true
    @State private var pulsing: Bool = false
    
    @State private var editingSetID: UUID? = nil
    @State private var editReps: String = ""
    @State private var editWeight: String = ""

    @State private var sets: [WorkoutSet] = [
        WorkoutSet(number: 1, reps: 10, weight: 45, status: .done),
        WorkoutSet(number: 2, reps: 10, weight: 45, status: .active),
        WorkoutSet(number: 3, reps: 10, weight: 45, status: .upcoming)
    ]

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var progress: Double {
        Double(timeRemaining) / Double(totalTime)
    }

    var body: some View {
        ZStack {
            // Background
            ColorTheme.background.ignoresSafeArea()
            gridOverlay

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    topBar
                    progressSegments
                    exerciseHero
                    statsRow
                    setsSection
                    restTimerCard
                    nextExerciseCard
                    Spacer(minLength: 100)
                }
                .padding(.bottom, 20)
            }

//            VStack {
//                Spacer()
//                bottomNav
//            }
//            .ignoresSafeArea(edges: .bottom)
        }
        .onReceive(timer) { _ in
            guard timerActive, timeRemaining > 0 else { return }
            timeRemaining -= 1
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulsing = true
            }
        }
    }

    // MARK: - Grid Overlay
    var gridOverlay: some View {
        Canvas { context, size in
            let spacing: CGFloat = 30
            var x: CGFloat = 0
            while x <= size.width {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(ColorTheme.secondary.opacity(0.04)), lineWidth: 1)
                x += spacing
            }
            var y: CGFloat = 0
            while y <= size.height {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(ColorTheme.secondary.opacity(0.04)), lineWidth: 1)
                y += spacing
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Top Bar
    var topBar: some View {
        HStack {
            iconButton(icon: "xmark") {}
            Spacer()
            VStack(spacing: 3) {
                Text("UPPER BODY STRENGTH")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(2.5)
                    .foregroundStyle(
                        LinearGradient(colors: [ColorTheme.primary, ColorTheme.secondary],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                Text("Exercise 2 of 6")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1)
                    .foregroundColor(ColorTheme.textSecondary)
            }
            Spacer()
            iconButton(icon: "gearshape") {}
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 12)
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
            ForEach(0..<6, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        i < 1 ? AnyShapeStyle(ColorTheme.primary) :
                        i == 1 ? AnyShapeStyle(LinearGradient(colors: [ColorTheme.primary, ColorTheme.secondary],
                                                               startPoint: .leading, endPoint: .trailing)) :
                        AnyShapeStyle(Color.white.opacity(0.1))
                    )
                    .frame(height: 3)
                    .shadow(color: i <= 1 ? ColorTheme.primary.opacity(0.6) : .clear, radius: 4)
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 14)
    }

    // MARK: - Exercise Hero
    var exerciseHero: some View {
        ZStack(alignment: .bottomLeading) {
            // Hero image placeholder (replace with AsyncImage for real app)
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#0c1220"), Color(hex: "#182540"), Color(hex: "#0c1220")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 320)

                // Barbell illustration
//                BarbellIllustration()

                // Radial glow
                RadialGradient(
                    colors: [ColorTheme.secondary.opacity(0.08), .clear],
                    center: .center, startRadius: 0, endRadius: 160
                )
            }

            // Bottom overlay
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
                            Text("Dumbbell Bench Press")
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(.white)
                            HStack(spacing: 8) {
                                muscleTag("Chest", color: ColorTheme.primary)
                                muscleTag("Triceps", color: ColorTheme.secondary)
                            }
                        }
                        .padding(.leading, 16)
                        .padding(.bottom, 14)
                        Spacer()
                        Button(action: {}) {
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

    // MARK: - Stats Row
    var statsRow: some View {
        HStack(spacing: 0) {
            statBlock(label: "TARGET REPS", value: "10", unit: "reps")
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.08))
            statBlock(label: "WEIGHT (LB)", value: "45", unit: "lbs")
        }
        .frame(maxWidth: .infinity)
        .background(ColorTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(ColorTheme.secondary.opacity(0.12), lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.top, 14)
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

    // MARK: - Sets Section
    var setsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SETS")
                .font(.system(size: 10, weight: .bold))
                .tracking(2.5)
                .foregroundColor(ColorTheme.textSecondary)
                .padding(.leading, 2)

            ForEach(sets) { set in
                setRow(set)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
    }

    // MARK: - Enhanced Set Row
    @ViewBuilder
    func setRow(_ set: WorkoutSet) -> some View {
        let isEditing = editingSetID == set.id
        let isActive  = set.status == .active

        VStack(spacing: 0) {

            // ── Main Row ──────────────────────────────────────────
            HStack(spacing: 12) {

                // Circle indicator
                ZStack {
                    Circle()
                        .fill(setCircleFill(set.status))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(setCircleBorder(set.status), lineWidth: 1.5)
                        )
                        .shadow(color: setCircleShadow(set.status), radius: 6)

                    if set.status == .done {
                        Image(systemName: isEditing ? "pencil" : "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(isEditing ? ColorTheme.secondary : ColorTheme.primary)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(response: 0.3), value: isEditing)
                    } else {
                        Text("\(set.number)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(isActive ? ColorTheme.secondary : ColorTheme.textSecondary)
                    }
                }

                // Labels
                VStack(alignment: .leading, spacing: 3) {
                    Text("Set \(set.number)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(set.status == .upcoming ? ColorTheme.textSecondary : .white)

                    if isActive {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(ColorTheme.secondary)
                                .frame(width: 5, height: 5)
                                .opacity(pulsing ? 1 : 0.3)
                                .animation(.easeInOut(duration: 0.8).repeatForever(), value: pulsing)
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
                        Text("\(set.reps) Reps · \(set.weight) lb")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.35))
                    }
                }

                Spacer()

                // Right action button
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
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            if isEditing {
                                editingSetID = nil
                            } else {
                                editReps   = "\(set.reps)"
                                editWeight = "\(set.weight)"
                                editingSetID = set.id
                            }
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isEditing
                                      ? ColorTheme.secondary.opacity(0.15)
                                      : Color.white.opacity(0.04))
                                .frame(width: 34, height: 34)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isEditing
                                                ? ColorTheme.secondary.opacity(0.5)
                                                : Color.white.opacity(0.08),
                                                lineWidth: 1)
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

            // ── Expanded Edit Panel ───────────────────────────────
            if isEditing {
                VStack(spacing: 12) {

                    Divider()
                        .background(ColorTheme.secondary.opacity(0.2))
                        .padding(.horizontal, 4)

                    HStack(spacing: 12) {
                        // Reps field
                        editField(
                            icon:    "repeat",
                            label:   "REPS",
                            value:   $editReps,
                            color:   ColorTheme.primary,
                            keyboard: .numberPad
                        )

                        // Weight field
                        editField(
                            icon:    "scalemass.fill",
                            label:   "WEIGHT (LB)",
                            value:   $editWeight,
                            color:   ColorTheme.secondary,
                            keyboard: .decimalPad
                        )
                    }
                    .padding(.horizontal, 4)

                    // Save button
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
                    removal:   .push(from: .bottom).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isEditing)
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
            color: isEditing
                ? ColorTheme.primary.opacity(0.12)
                : isActive ? ColorTheme.secondary.opacity(pulsing ? 0.18 : 0.06) : .clear,
            radius: isEditing ? 20 : (pulsing ? 16 : 8)
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isEditing)
    }

    // MARK: - Edit Field Helper
    func editField(
        icon: String,
        label: String,
        value: Binding<String>,
        color: Color,
        keyboard: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(ColorTheme.textSecondary)
            }

            HStack {
                TextField("0", text: value)
                    .keyboardType(keyboard)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.white, color.opacity(0.8)],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 10)
            .background(color.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color.opacity(0.25), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Actions

    func handleDone(set: WorkoutSet) {
        guard let idx = sets.firstIndex(where: { $0.id == set.id }) else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            sets[idx].status = .done
            if idx + 1 < sets.count {
                sets[idx + 1].status = .active
            }
        }
    }

    func saveEdit(set: WorkoutSet) {
        guard let idx = sets.firstIndex(where: { $0.id == set.id }) else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            sets[idx].reps   = Int(editReps)   ?? sets[idx].reps
            sets[idx].weight = Int(editWeight) ?? sets[idx].weight
            editingSetID = nil
        }
    }

    func setBackground(_ status: SetStatus) -> Color {
        switch status {
        case .done:     return ColorTheme.primary.opacity(0.04)
        case .active:   return ColorTheme.secondary.opacity(0.08)
        case .upcoming: return Color.white.opacity(0.02)
        }
    }

    func setStroke(_ status: SetStatus) -> Color {
        switch status {
        case .done:     return ColorTheme.primary.opacity(0.15)
        case .active:   return ColorTheme.secondary.opacity(0.4)
        case .upcoming: return Color.white.opacity(0.06)
        }
    }

    func setCircleFill(_ status: SetStatus) -> Color {
        switch status {
        case .done:     return ColorTheme.primary.opacity(0.12)
        case .active:   return ColorTheme.secondary.opacity(0.15)
        case .upcoming: return Color.white.opacity(0.04)
        }
    }

    func setCircleBorder(_ status: SetStatus) -> Color {
        switch status {
        case .done:     return ColorTheme.primary.opacity(0.6)
        case .active:   return ColorTheme.secondary
        case .upcoming: return Color.white.opacity(0.12)
        }
    }

    func setCircleShadow(_ status: SetStatus) -> Color {
        switch status {
        case .active: return ColorTheme.secondary.opacity(0.4)
        default:      return .clear
        }
    }

    // MARK: - Rest Timer
    var restTimerCard: some View {
        RestTimerView(initialSeconds: 60) {
            // fires when timer naturally hits 0
            moveToNextExercise()
        } onSkip: {
            // fires when user skips
            moveToNextExercise()
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
    }
    
    func moveToNextExercise() {
        guard let activeSet = sets.first(where: { $0.status == .active }) else { return }
        handleDone(set: activeSet)
    }
    
    var timeString: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Next Exercise
    var nextExerciseCard: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(colors: [Color(hex: "#162035"), Color(hex: "#0c1828")],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 52, height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(ColorTheme.primary.opacity(0.25), lineWidth: 1)
                    )
                Text("💪")
                    .font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("NEXT UP")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2)
                    .foregroundColor(ColorTheme.textSecondary)
                Text("Incline Push-ups")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                Text("3 × 12 reps")
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

    // MARK: - Bottom Nav
    var bottomNav: some View {
        HStack {
            navAction(icon: "pause.fill", label: "Pause", color: ColorTheme.textSecondary) {}
            Spacer()
            navAction(icon: "stop.fill", label: "End", color: ColorTheme.danger) {}
            Spacer()
            navAction(icon: "arrow.left.arrow.right", label: "Replace", color: ColorTheme.textSecondary) {}
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background(
            ZStack {
                // Blur layer
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                
                // Tinted overlay on top of blur
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                ColorTheme.surface.opacity(0.6),
                                ColorTheme.background.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Subtle border glow
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                ColorTheme.secondary.opacity(0.3),
                                ColorTheme.primary.opacity(0.15),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: ColorTheme.secondary.opacity(0.08), radius: 20, x: 0, y: -4)
        .padding(.horizontal, 16)
        .padding(.bottom, 30)
        .padding(.top, 10)
    }

    func navAction(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(color)
            }
        }
    }
}

// MARK: - Barbell Illustration

struct BarbellIllustration: View {
    var body: some View {
        ZStack {
            // Bar
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "#2a3a54"))
                .frame(width: 240, height: 8)

            // Left weight plate
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(hex: "#1d2d45"))
                .frame(width: 22, height: 46)
                .offset(x: -95)
                .overlay(
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(hex: "#162236"))
                        .frame(width: 6, height: 34)
                        .offset(x: -100)
                )

            // Right weight plate
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(hex: "#1d2d45"))
                .frame(width: 22, height: 46)
                .offset(x: 95)
                .overlay(
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(hex: "#162236"))
                        .frame(width: 6, height: 34)
                        .offset(x: 100)
                )

            // Bench seat
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "#253650"))
                .frame(width: 130, height: 10)
                .offset(y: 42)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "#1e2e45"))
                .frame(width: 120, height: 14)
                .offset(y: 52)

            // Bench legs
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "#1a2840"))
                .frame(width: 9, height: 18)
                .offset(x: -46, y: 66)

            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "#1a2840"))
                .frame(width: 9, height: 18)
                .offset(x: 46, y: 66)

            // Subtle glow line on bar
            Ellipse()
                .stroke(ColorTheme.secondary.opacity(0.15), lineWidth: 1)
                .frame(width: 200, height: 10)
                .offset(y: 2)
        }
        .frame(width: 280, height: 180)
    }
}

// MARK: - Preview

#Preview {
    WorkoutActiveScreen()
        .preferredColorScheme(.dark)
}
