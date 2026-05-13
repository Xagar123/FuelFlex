//
//  WorkoutCompletionView.swift
//  FuelFlex
//

import SwiftUI

struct WorkoutCompletionView: View {

    let totalDuration: TimeInterval
    let totalVolume: Int
    let prCount: Int
    let exerciseCount: Int
    let onDone: () -> Void

    @State private var showCheckmark = false
    @State private var showCards = false

    private var durationString: String {
        let m = Int(totalDuration) / 60
        let s = Int(totalDuration) % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            ColorTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    header
                    statsGrid
                    doneButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showCheckmark = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                showCards = true
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(ColorTheme.primary.opacity(0.12))
                    .frame(width: 100, height: 100)
                    .scaleEffect(showCheckmark ? 1 : 0.3)
                    .opacity(showCheckmark ? 1 : 0)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ColorTheme.primary, ColorTheme.golden],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: ColorTheme.primary.opacity(0.5), radius: 16)
                    .scaleEffect(showCheckmark ? 1 : 0)
                    .opacity(showCheckmark ? 1 : 0)
            }

            Text("WORKOUT COMPLETE")
                .font(.system(size: 13, weight: .black))
                .tracking(3)
                .foregroundColor(ColorTheme.primary)

            Text("\(exerciseCount) exercises crushed")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(ColorTheme.textSecondary)
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                statCard(icon: "clock.fill", label: "Duration", value: durationString, color: ColorTheme.secondary)
                statCard(icon: "scalemass.fill", label: "Volume", value: "\(totalVolume) kg", color: ColorTheme.primary)
            }
            if prCount > 0 {
                statCard(icon: "trophy.fill", label: "Personal Records", value: "\(prCount) PR\(prCount == 1 ? "" : "s")", color: ColorTheme.golden)
            }
        }
        .opacity(showCards ? 1 : 0)
        .offset(y: showCards ? 0 : 20)
    }

    private func statCard(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.4), radius: 6)

            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundColor(ColorTheme.textSecondary.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(ColorTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Done Button

    private var doneButton: some View {
        Button(action: onDone) {
            Text("Done")
                .font(.system(size: 17, weight: .bold))
                .tracking(0.5)
                .foregroundColor(ColorTheme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(ColorTheme.buttonGradient)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: ColorTheme.primary.opacity(0.4), radius: 12)
        }
    }
}

// MARK: - Preview

#Preview {
    WorkoutCompletionView(
        totalDuration: 2745,
        totalVolume: 8400,
        prCount: 2,
        exerciseCount: 5,
        onDone: {}
    )
    .preferredColorScheme(.dark)
}
