//
//  RestTimerView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 05/03/26.
//

//
//  RestTimerView.swift
//  FuelFlex
//
//  A fully self-contained rest timer — drop in anywhere.
//
//  USAGE:
//  ──────
//  // Basic
//  RestTimerView()
//
//  // Custom default duration
//  RestTimerView(initialSeconds: 90)
//
//  // With completion callback
//  RestTimerView(initialSeconds: 60) {
//      print("Rest finished!")
//  }
//
//  // With skip callback
//  RestTimerView(initialSeconds: 60, onSkip: {
//      print("User skipped rest")
//  })
//

import SwiftUI

// MARK: - RestTimerView

struct RestTimerView: View {

    // MARK: - Configuration
    var initialSeconds: Int
    var onComplete: (() -> Void)?
    var onSkip: (() -> Void)?

    

    // MARK: - State
    @State private var timeRemaining: Int
    @State private var totalTime:     Int
    @State private var selectedPreset: Int
    @State private var timerActive:   Bool = false
    @State private var timerFinished: Bool = false
    @State private var ringPulse:     Bool = false
    @State private var displayTimer:  Timer? = nil

    // Initialise @State from stored props
    init(
        initialSeconds: Int = 60,
        onComplete: (() -> Void)? = nil,
        onSkip: (() -> Void)? = nil,
        _dummy: Bool = false
    ) {
        self.initialSeconds  = initialSeconds
        self.onComplete      = onComplete
        self.onSkip          = onSkip
        _timeRemaining       = State(initialValue: initialSeconds)
        _totalTime           = State(initialValue: initialSeconds)
        _selectedPreset      = State(initialValue: initialSeconds)
    }

    let timerPresets: [Int] = [30, 60, 90, 120]

    // MARK: - Computed
    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return Double(timeRemaining) / Double(totalTime)
    }

    var timeString: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    var ringColor: Color {
        timerFinished ? ColorTheme.primary : ColorTheme.secondary
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            headerRow
            circularTimer
            presetSelector
            Divider()
                .background(Color.white.opacity(0.06))
                .padding(.horizontal, 16)
            controlRow
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(cardBorder)
        .shadow(
            color: timerFinished
                ? ColorTheme.primary.opacity(0.15)
                : ColorTheme.secondary.opacity(0.08),
            radius: 24, x: 0, y: 8
        )
        .onAppear {
            startDisplayTimer()
        }
        .onDisappear {
            displayTimer?.invalidate()
            displayTimer = nil
        }
        .onChange(of: timerActive) { _ in
            if timerActive { startDisplayTimer() }
            else { displayTimer?.invalidate(); displayTimer = nil }
        }
    }

    // MARK: - Header

    var headerRow: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "timer")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(ColorTheme.secondary)
                Text("REST TIMER")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2.5)
                    .foregroundColor(ColorTheme.secondary)
            }
            Spacer()
            statusBadge
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 20)
    }

    var statusBadge: some View {
        let label = timerFinished ? "DONE" : timerActive ? "RUNNING" : "PAUSED"
        let color: Color = timerFinished ? ColorTheme.primary
                         : timerActive   ? ColorTheme.secondary
                         : ColorTheme.textSecondary

        return Text(label)
            .font(.system(size: 9, weight: .bold))
            .tracking(1.5)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
            .animation(.easeInOut(duration: 0.25), value: timerFinished)
            .animation(.easeInOut(duration: 0.25), value: timerActive)
    }

    // MARK: - Circular Timer

    var circularTimer: some View {
        ZStack {
            // Outer pulse ring (finish state)
            Circle()
                .stroke(ringColor.opacity(0.12), lineWidth: 20)
                .frame(width: 190, height: 190)
                .scaleEffect(ringPulse && timerFinished ? 1.05 : 1.0)
                .animation(
                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                    value: ringPulse
                )

            // Track
            Circle()
                .stroke(Color.white.opacity(0.05), lineWidth: 10)
                .frame(width: 170, height: 170)

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    timerFinished
                        ? AngularGradient(
                            colors: [ColorTheme.primary, ColorTheme.golden, ColorTheme.primary],
                            center: .center)
                        : AngularGradient(
                            colors: [ColorTheme.primary, ColorTheme.secondary, ColorTheme.primary],
                            center: .center),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .frame(width: 170, height: 170)
                .rotationEffect(.degrees(-90))
                .shadow(color: ringColor.opacity(0.55), radius: 8)
                .animation(.linear(duration: 1), value: timeRemaining)

            // Glow dot
            if !timerFinished && progress > 0.01 {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white, ColorTheme.primary],
                            center: .center,
                            startRadius: 0,
                            endRadius: 6
                        )
                    )
                    .frame(width: 12, height: 12)
                    .shadow(color: ColorTheme.primary, radius: 8)
                    .offset(y: -85)
                    .rotationEffect(.degrees(-90 + (1 - progress) * 360))
                    .animation(.linear(duration: 1), value: timeRemaining)
            }

            // Center content
            centerContent
        }
        .frame(width: 190, height: 190)
        .onTapGesture { handleRingTap() }
        .padding(.bottom, 24)
    }

    @ViewBuilder
    var centerContent: some View {
        if timerFinished {
            VStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ColorTheme.primary, ColorTheme.golden],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .shadow(color: ColorTheme.primary.opacity(0.6), radius: 10)

                Text("COMPLETE")
                    .font(.system(size: 11, weight: .black))
                    .tracking(2)
                    .foregroundColor(ColorTheme.primary)
            }
            .transition(.scale.combined(with: .opacity))
        } else {
            VStack(spacing: 4) {
                Text(timeString)
                    .font(.system(size: 46, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: timeRemaining <= 10
                                ? [ColorTheme.accent, ColorTheme.golden]
                                : [.white, ColorTheme.secondary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 1), value: timeRemaining)

                Text(timerActive ? "remaining" : "tap to start")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1)
                    .foregroundColor(
                        timerActive
                            ? ColorTheme.textSecondary.opacity(0.6)
                            : ColorTheme.secondary.opacity(0.7)
                    )
                    .animation(.easeInOut, value: timerActive)
            }
            .transition(.opacity)
        }
    }

    // MARK: - Preset Selector

    var presetSelector: some View {
        VStack(spacing: 8) {
            Text("QUICK SET")
                .font(.system(size: 9, weight: .bold))
                .tracking(2)
                .foregroundColor(ColorTheme.textSecondary.opacity(0.5))

            HStack(spacing: 8) {
                ForEach(timerPresets, id: \.self) { preset in
                    Button(action: { applyPreset(preset) }) {
                        Text(presetLabel(preset))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(
                                selectedPreset == preset
                                    ? ColorTheme.background
                                    : ColorTheme.textSecondary
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(
                                selectedPreset == preset
                                    ? AnyView(ColorTheme.buttonGradient)
                                    : AnyView(Color.white.opacity(0.04))
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        selectedPreset == preset
                                            ? Color.clear
                                            : Color.white.opacity(0.08),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(
                                color: selectedPreset == preset
                                    ? ColorTheme.primary.opacity(0.3)
                                    : .clear,
                                radius: 8
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Control Row

    var controlRow: some View {
        HStack(spacing: 10) {

            // Reset
            Button(action: resetTimer) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 13, weight: .bold))
                    Text("Reset")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(ColorTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
            }

            // Play / Pause / Restart
            Button(action: handlePrimaryAction) {
                HStack(spacing: 6) {
                    Image(systemName: primaryIcon)
                        .font(.system(size: 16, weight: .bold))
                    Text(primaryLabel)
                        .font(.system(size: 14, weight: .bold))
                        .tracking(0.5)
                }
                .foregroundColor(ColorTheme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    timerFinished
                        ? AnyView(LinearGradient(
                            colors: [ColorTheme.primary, ColorTheme.golden],
                            startPoint: .leading, endPoint: .trailing))
                        : AnyView(ColorTheme.buttonGradient)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(
                    color: timerFinished
                        ? ColorTheme.primary.opacity(0.5)
                        : ColorTheme.primary.opacity(0.35),
                    radius: 12
                )
            }

            // +30s
            Button(action: addThirtySeconds) {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                    Text("30s")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(ColorTheme.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(ColorTheme.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ColorTheme.secondary.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    var primaryIcon: String {
        if timerFinished { return "arrow.counterclockwise.circle.fill" }
        return timerActive ? "pause.circle.fill" : "play.circle.fill"
    }

    var primaryLabel: String {
        if timerFinished { return "Restart" }
        return timerActive ? "Pause" : "Start"
    }

    // MARK: - Background & Border

    var cardBackground: some View {
        ZStack {
            ColorTheme.surface
            RadialGradient(
                colors: [ringColor.opacity(0.07), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 220
            )
            .animation(.easeInOut(duration: 1), value: timerFinished)
        }
    }

    var cardBorder: some View {
        RoundedRectangle(cornerRadius: 22)
            .stroke(
                timerFinished
                    ? LinearGradient(
                        colors: [ColorTheme.primary.opacity(0.5), ColorTheme.golden.opacity(0.3)],
                        startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(
                        colors: [ColorTheme.secondary.opacity(0.2), ColorTheme.primary.opacity(0.1)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                lineWidth: 1.5
            )
            .animation(.easeInOut(duration: 0.5), value: timerFinished)
    }

    // MARK: - Logic

    private func startDisplayTimer() {
        displayTimer?.invalidate()
        let timer = Timer(timeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async { handleTick() }
        }
        RunLoop.main.add(timer, forMode: .common)
        displayTimer = timer
    }

    func handleTick() {
        guard timerActive, timeRemaining > 0 else {
            if timerActive && timeRemaining == 0 {
                timerActive   = false
                timerFinished = true
                withAnimation(.spring()) { ringPulse = true }
                onComplete?()
            }
            return
        }
        timeRemaining -= 1
    }

    func handleRingTap() {
        guard !timerFinished else { return }
        withAnimation(.spring(response: 0.3)) { timerActive.toggle() }
    }

    func handlePrimaryAction() {
        if timerFinished {
            resetTimer()
        } else {
            withAnimation(.spring(response: 0.3)) { timerActive.toggle() }
        }
    }

    func applyPreset(_ seconds: Int) {
        withAnimation(.spring(response: 0.4)) {
            selectedPreset = seconds
            totalTime      = seconds
            timeRemaining  = seconds
            timerActive    = false
            timerFinished  = false
            ringPulse      = false
        }
    }

    func resetTimer() {
        withAnimation(.spring(response: 0.4)) {
            timeRemaining = totalTime
            timerActive   = false
            timerFinished = false
            ringPulse     = false
        }
    }

    func addThirtySeconds() {
        withAnimation(.spring(response: 0.3)) {
            totalTime     += 30
            timeRemaining  = min(timeRemaining + 30, totalTime)
            timerFinished  = false
            ringPulse      = false
            if !timerActive { timerActive = true }
        }
    }

    func presetLabel(_ seconds: Int) -> String {
        seconds < 60 ? "\(seconds)s" : "\(seconds / 60)m"
    }
}

// MARK: - Preview

#Preview("Default") {
    ZStack {
        ColorTheme.background.ignoresSafeArea()
        ScrollView {
            RestTimerView()
                .padding(.horizontal, 16)
                .padding(.top, 40)
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("Custom 90s + Callbacks") {
    ZStack {
        ColorTheme.background.ignoresSafeArea()
        RestTimerView(initialSeconds: 90) {
            print("✅ Rest complete!")
        } onSkip: {
            print("⏭ Skipped rest")
        }
        .padding(.horizontal, 16)
    }
    .preferredColorScheme(.dark)
}
