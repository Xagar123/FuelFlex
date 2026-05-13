//
//  VitalsSection.swift
//  FuelFlex
//
//  Created by DAS Sagar on 05/03/26.
//

import SwiftUI

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    let color: Color
    var isPulse: Bool = false
    var pulseScale: CGFloat = 1.0

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {

            // Icon area
            ZStack {
                // Outer glow ring
                Circle()
                    .fill(color.opacity(0.08))
                    .frame(width: 52, height: 52)

                // Inner icon background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.25), color.opacity(0.08)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 22
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: color.opacity(0.6), radius: 6)
                    .scaleEffect(isPulse ? pulseScale : 1.0)
            }
            .padding(.bottom, 12)

            // Value
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())

                Text(unit)
                    .font(.system(size: 9, weight: .black))
                    .tracking(0.5)
                    .foregroundColor(color.opacity(0.8))
                    .padding(.bottom, 2)
            }
            .padding(.bottom, 3)

            // Label
            Text(label)
                .font(.system(size: 9, weight: .black))
                .tracking(2)
                .foregroundColor(ColorTheme.textSecondary.opacity(0.6))

            // Mini sparkline bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 3)

                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.4), color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: appeared ? sparklineWidth : 0, height: 3)
                    .shadow(color: color.opacity(0.5), radius: 3)
                    .animation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.3), value: appeared)
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(cardBorder)
        .shadow(color: color.opacity(0.1), radius: 12, x: 0, y: 6)
        .onAppear {
            withAnimation { appeared = true }
        }
    }

    // Different sparkline fill per card to suggest different data levels
    var sparklineWidth: CGFloat {
        switch label {
        case "PULSE": return 38
        case "WATER": return 50
        case "STEPS": return 62
        default:      return 44
        }
    }

    var cardBackground: some View {
        ZStack {
            ColorTheme.surface

            // Top glow
            RadialGradient(
                colors: [color.opacity(0.12), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 80
            )

            // Diagonal shimmer
            LinearGradient(
                colors: [color.opacity(0.06), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var cardBorder: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [color.opacity(0.35), color.opacity(0.08), Color.white.opacity(0.03)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
}

// MARK: - Vitals Section

struct VitalsSection: View {

    @StateObject private var stepManager = StepCountManager()
    @State private var bpm: Int = 72
    @State private var pulseScale: CGFloat = 1.0
    @State private var livePulse: Bool = false

    private var stepsDisplay: String {
        guard stepManager.isAvailable else { return "--" }
        if stepManager.steps >= 1000 {
            return String(format: "%.1f", Double(stepManager.steps) / 1000.0)
        }
        return "\(stepManager.steps)"
    }

    private var stepsUnit: String {
        guard stepManager.isAvailable, stepManager.steps >= 1000 else { return "" }
        return "K"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Section header
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    // Animated live dot
                    ZStack {
                        Circle()
                            .fill(ColorTheme.accent.opacity(0.25))
                            .frame(width: 20, height: 20)
                            .scaleEffect(livePulse ? 1.4 : 1.0)
                            .animation(
                                .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                                value: livePulse
                            )
                        Circle()
                            .fill(ColorTheme.accent)
                            .frame(width: 7, height: 7)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("VITAL SIGNS")
                            .font(.system(size: 12, weight: .black))
                            .tracking(2.5)
                            .foregroundColor(.white)
                        Text("Updated just now")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(ColorTheme.textSecondary.opacity(0.6))
                    }
                }

                Spacer()

                // Live badge
                HStack(spacing: 5) {
                    Circle()
                        .fill(ColorTheme.primary)
                        .frame(width: 5, height: 5)
                        .opacity(livePulse ? 1 : 0.3)
                        .animation(
                            .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                            value: livePulse
                        )
                    Text("LIVE")
                        .font(.system(size: 9, weight: .black))
                        .tracking(2)
                        .foregroundColor(ColorTheme.primary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(ColorTheme.primary.opacity(0.1))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(ColorTheme.primary.opacity(0.3), lineWidth: 1))
            }

            // Cards row
            HStack(spacing: 10) {
                StatCard(
                    icon: "heart.fill",
                    value: "\(bpm)",
                    unit: "BPM",
                    label: "PULSE",
                    color: ColorTheme.accent,
                    isPulse: true,
                    pulseScale: pulseScale
                )
                StatCard(
                    icon: "drop.fill",
                    value: "1.8",
                    unit: "LTR",
                    label: "WATER",
                    color: ColorTheme.secondary
                )
                StatCard(
                    icon: "figure.walk",
                    value: stepsDisplay,
                    unit: stepsUnit,
                    label: "STEPS",
                    color: ColorTheme.primary
                )
            }
        }
        .onAppear {
            livePulse = true
            startHeartRateAnimation()
            stepManager.requestAccessAndFetch()
        }
    }

    private func startHeartRateAnimation() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            pulseScale = 1.2
        }
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.spring(response: 0.4)) {
                bpm = Int.random(in: 70...78)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        ColorTheme.background.ignoresSafeArea()
        VStack(spacing: 30) {
            VitalsSection()
                .padding(.horizontal, 20)
        }
        .padding(.top, 60)
    }
    .preferredColorScheme(.dark)
}
