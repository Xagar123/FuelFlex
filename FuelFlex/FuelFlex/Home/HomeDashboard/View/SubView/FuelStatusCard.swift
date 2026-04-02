//
//  FuelStatusCard.swift
//  FuelFlex
//
//  Created by DAS Sagar on 05/03/26.
//


import SwiftUI

// MARK: - FuelStatusCard

struct FuelStatusCard: View {

    @State private var animate = false

    let macros: [MacroData] = [
        MacroData(label: "Protein", value: "142g", progress: 0.65, color: ColorTheme.secondary,  icon: "bolt.fill"),
        MacroData(label: "Carbs",   value: "210g", progress: 0.75, color: ColorTheme.golden,     icon: "leaf.fill"),
        MacroData(label: "Fat",     value: "58g",  progress: 0.55, color: ColorTheme.accent,     icon: "drop.fill"),
        MacroData(label: "Fiber",   value: "24g",  progress: 0.80, color: ColorTheme.primary,    icon: "staroflife.fill")
    ]

    let consumed:  Int = 1850
    let goal:      Int = 2400
    var remaining: Int { goal - consumed }
    var calProgress: CGFloat { CGFloat(consumed) / CGFloat(goal) }

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            calorieBarSection
            macroSection
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(cardBorder)
        .shadow(color: ColorTheme.primary.opacity(0.08), radius: 24, x: 0, y: 10)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.9, dampingFraction: 0.75)) {
                    animate = true
                }
            }
        }
    }

    // MARK: - Header

    var headerSection: some View {
        HStack(alignment: .top, spacing: 0) {

            // Left — title + meal pills
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(ColorTheme.primary.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(colors: [ColorTheme.primary, ColorTheme.golden],
                                               startPoint: .top, endPoint: .bottom)
                            )
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("FUEL STATUS")
                            .font(.system(size: 11, weight: .black))
                            .tracking(2.5)
                            .foregroundStyle(
                                LinearGradient(colors: [ColorTheme.primary, ColorTheme.secondary],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                        Text("Today's Nutrition")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                }

                // Meal timing pills
                HStack(spacing: 6) {
                    mealPill(label: "🌅 Breakfast", done: true)
                    mealPill(label: "☀️ Lunch",     done: true)
                    mealPill(label: "🌙 Dinner",    done: false)
                }
            }

            Spacer()

            // Right — big calorie number
            VStack(alignment: .trailing, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(consumed)")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [ColorTheme.primary, ColorTheme.secondary],
                                           startPoint: .top, endPoint: .bottom)
                        )
                    Text("kcal")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(ColorTheme.textSecondary)
                        .padding(.bottom, 4)
                }
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(ColorTheme.accent)
                    Text("\(remaining) remaining")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(ColorTheme.accent)
                }
                Text("Goal · \(goal) kcal")
                    .font(.system(size: 10))
                    .foregroundColor(ColorTheme.textSecondary.opacity(0.6))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    func mealPill(label: String, done: Bool) -> some View {
        Text(label)
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(done ? ColorTheme.background : ColorTheme.textSecondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                done
                    ? AnyView(ColorTheme.buttonGradient)
                    : AnyView(Color.white.opacity(0.05))
            )
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(
                    done ? Color.clear : Color.white.opacity(0.1),
                    lineWidth: 1
                )
            )
    }

    // MARK: - Calorie Progress Bar

    var calorieBarSection: some View {
        VStack(spacing: 8) {

            // Segmented progress bar
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 10)

                // Fill
                GeometryReader { geo in
                    ZStack(alignment: .trailing) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [ColorTheme.primary, ColorTheme.secondary],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(width: animate ? geo.size.width * calProgress : 0, height: 10)
                            .shadow(color: ColorTheme.primary.opacity(0.5), radius: 6)

                        // Glow tip
                        Circle()
                            .fill(ColorTheme.primary)
                            .frame(width: 14, height: 14)
                            .shadow(color: ColorTheme.primary, radius: 6)
                            .opacity(animate ? 1 : 0)
                            .offset(x: 4)
                    }
                }
                .frame(height: 14)
            }
            .frame(height: 14)

            // Labels
            HStack {
                Text("0")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(ColorTheme.textSecondary.opacity(0.4))
                Spacer()
                Text("\(Int(calProgress * 100))% of daily goal")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(ColorTheme.primary)
                Spacer()
                Text("\(goal)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(ColorTheme.textSecondary.opacity(0.4))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Macro Section

    var macroSection: some View {
        VStack(spacing: 0) {
            // Divider with label
            HStack(spacing: 10) {
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)
                Text("MACROS")
                    .font(.system(size: 9, weight: .black))
                    .tracking(2)
                    .foregroundColor(ColorTheme.textSecondary.opacity(0.5))
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // Macro rings row
            HStack(spacing: 0) {
                ForEach(macros) { macro in
                    EnhancedMacroRing(macro: macro, animate: animate)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Card Background

    var cardBackground: some View {
        ZStack {
            ColorTheme.surface

            // Top-left glow
            RadialGradient(
                colors: [ColorTheme.primary.opacity(0.1), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 200
            )

            // Bottom-right glow
            RadialGradient(
                colors: [ColorTheme.secondary.opacity(0.06), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 180
            )

            // Subtle grid
            Canvas { context, size in
                let spacing: CGFloat = 24
                var x: CGFloat = 0
                while x <= size.width {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(path, with: .color(.white.opacity(0.02)), lineWidth: 1)
                    x += spacing
                }
                var y: CGFloat = 0
                while y <= size.height {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(path, with: .color(.white.opacity(0.02)), lineWidth: 1)
                    y += spacing
                }
            }
        }
    }

    var cardBorder: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        ColorTheme.primary.opacity(0.3),
                        ColorTheme.secondary.opacity(0.15),
                        Color.white.opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
    }
}

// MARK: - Macro Data Model

struct MacroData: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let progress: CGFloat
    let color: Color
    let icon: String
}

// MARK: - Enhanced Macro Ring

struct EnhancedMacroRing: View {

    let macro: MacroData
    let animate: Bool

    private let ringSize: CGFloat = 58
    private let lineWidth: CGFloat = 6

    var body: some View {
        VStack(spacing: 8) {

            ZStack {
                // Outer glow ring
                Circle()
                    .stroke(macro.color.opacity(0.08), lineWidth: lineWidth + 6)
                    .frame(width: ringSize, height: ringSize)

                // Track
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: lineWidth)
                    .frame(width: ringSize, height: ringSize)

                // Progress arc
                Circle()
                    .trim(from: 0, to: animate ? macro.progress : 0)
                    .stroke(
                        AngularGradient(
                            colors: [macro.color.opacity(0.5), macro.color, macro.color],
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: macro.color.opacity(0.5), radius: 4)

                // Icon + percent
                VStack(spacing: 1) {
                    Image(systemName: macro.icon)
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(macro.color)
                    Text("\(Int(macro.progress * 100))%")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .frame(width: ringSize + 12, height: ringSize + 12)

            // Label
            Text(macro.label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(ColorTheme.textSecondary)

            // Value pill
            Text(macro.value)
                .font(.system(size: 10, weight: .black))
                .foregroundColor(macro.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(macro.color.opacity(0.1))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(macro.color.opacity(0.25), lineWidth: 1))
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        ColorTheme.background.ignoresSafeArea()
        ScrollView {
            FuelStatusCard()
                .padding(.horizontal, 16)
                .padding(.top, 40)
        }
    }
    .preferredColorScheme(.dark)
}
