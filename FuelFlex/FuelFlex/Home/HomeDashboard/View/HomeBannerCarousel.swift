//
//  HomeBannerCarousel.swift
//  FuelFlex
//
//  Created by DAS Sagar on 23/01/26.
//

import SwiftUI

// MARK: - HomeBannerCarousel

struct HomeBannerCarousel: View {

    let banners: [HomeBanner]

    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false

    private let height: CGFloat = 240
    private let autoScrollInterval: TimeInterval = 3
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 14) {

            // ── Banner Stack ──────────────────────────────────
            GeometryReader { geo in
                ZStack {
                    ForEach(banners.indices, id: \.self) { index in
                        HomeBannerCard(
                            banner: banners[index],
                            isActive: index == currentIndex
                        )
                        .frame(width: geo.size.width, height: height)
                        .scaleEffect(index == currentIndex ? 1.0 : 0.92)
                        .opacity(cardOpacity(for: index))
                        .offset(x: cardOffset(for: index, width: geo.size.width))
                        .animation(
                            .spring(response: 0.55, dampingFraction: 0.82),
                            value: currentIndex
                        )
                        .animation(
                            .spring(response: 0.55, dampingFraction: 0.82),
                            value: dragOffset
                        )
                        .zIndex(index == currentIndex ? 1 : 0)
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            dragOffset = value.translation.width * 0.4
                        }
                        .onEnded { value in
                            isDragging = false
                            let threshold: CGFloat = 50
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                dragOffset = 0
                                if value.translation.width < -threshold {
                                    currentIndex = min(currentIndex + 1, banners.count - 1)
                                } else if value.translation.width > threshold {
                                    currentIndex = max(currentIndex - 1, 0)
                                }
                            }
                        }
                )
            }
            .frame(height: height)
            .padding(.horizontal, 16)

            // ── Indicator Row ─────────────────────────────────
            HStack(spacing: 0) {

                // Slide counter
                HStack(spacing: 4) {
                    Text("\(currentIndex + 1)")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ColorTheme.primary, ColorTheme.secondary],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                    Text("/ \(banners.count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(ColorTheme.textSecondary.opacity(0.4))
                }

                Spacer()

                // Dot indicators
                HStack(spacing: 6) {
                    ForEach(banners.indices, id: \.self) { index in
                        Capsule()
                            .fill(
                                index == currentIndex
                                    ? AnyShapeStyle(LinearGradient(
                                        colors: [ColorTheme.primary, ColorTheme.secondary],
                                        startPoint: .leading, endPoint: .trailing))
                                    : AnyShapeStyle(Color.white.opacity(0.15))
                            )
                            .frame(
                                width: index == currentIndex ? 22 : 6,
                                height: 6
                            )
                            .shadow(
                                color: index == currentIndex ? ColorTheme.primary.opacity(0.6) : .clear,
                                radius: 4
                            )
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentIndex)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    currentIndex = index
                                }
                            }
                    }
                }

                Spacer()

                // Auto-scroll progress arc
                AutoScrollArc(progress: arcProgress, color: ColorTheme.primary)
                    .frame(width: 22, height: 22)
            }
            .padding(.horizontal, 24)
        }
        .onReceive(timer) { _ in
            guard !isDragging else { return }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.82)) {
                currentIndex = (currentIndex + 1) % banners.count
            }
        }
    }

    // MARK: - Helpers

    @State private var arcProgress: CGFloat = 0

    func cardOffset(for index: Int, width: CGFloat) -> CGFloat {
        let base = CGFloat(index - currentIndex) * (width + 12)
        return base + dragOffset
    }

    func cardOpacity(for index: Int) -> Double {
        if index == currentIndex { return 1.0 }
        let distance = abs(index - currentIndex)
        return distance == 1 ? 0.35 : 0.0
    }
}

// MARK: - Auto Scroll Arc

struct AutoScrollArc: View {

    let progress: CGFloat
    let color: Color
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.1), lineWidth: 2)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)

            Image(systemName: "arrow.clockwise")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(color.opacity(0.6))
        }
    }
}

// MARK: - HomeBannerCard

struct HomeBannerCard: View {

    let banner: HomeBanner
    let isActive: Bool

    @State private var appeared: Bool = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            // ── Image ─────────────────────────────────────────
            GeometryReader { geo in
                Image(banner.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .scaleEffect(isActive ? 1.04 : 1.0)
                    .animation(
                        .easeInOut(duration: 6).repeatForever(autoreverses: true),
                        value: isActive
                    )
                    .clipped()
            }

            // ── Gradient layers ───────────────────────────────
            // Bottom dark fade
            LinearGradient(
                stops: [
                    .init(color: .clear,                              location: 0.0),
                    .init(color: ColorTheme.background.opacity(0.3),  location: 0.45),
                    .init(color: ColorTheme.background.opacity(0.85), location: 0.78),
                    .init(color: ColorTheme.background,               location: 1.0)
                ],
                startPoint: .top, endPoint: .bottom
            )

            // Side vignette
            LinearGradient(
                colors: [ColorTheme.background.opacity(0.5), .clear, ColorTheme.background.opacity(0.3)],
                startPoint: .leading, endPoint: .trailing
            )

            // Ambient color glow
            RadialGradient(
                colors: [ColorTheme.primary.opacity(0.12), .clear],
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 300
            )

            // ── Content ───────────────────────────────────────
            VStack(alignment: .leading, spacing: 0) {

                // Category chip
                HStack(spacing: 5) {
                    Image(systemName: bannerIcon)
                        .font(.system(size: 8, weight: .black))
                    Text(bannerCategory.uppercased())
                        .font(.system(size: 8, weight: .black))
                        .tracking(2)
                }
                .foregroundColor(ColorTheme.background)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(ColorTheme.buttonGradient)
                .clipShape(Capsule())
                .shadow(color: ColorTheme.primary.opacity(0.4), radius: 8)
                .offset(y: appeared ? 0 : 10)
                .opacity(appeared ? 1 : 0)
                .padding(.bottom, 10)

                // Title
                Text(banner.title)
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.4), radius: 4)
                    .offset(y: appeared ? 0 : 12)
                    .opacity(appeared ? 1 : 0)
                    .padding(.bottom, 5)

                // Subtitle
                Text(banner.subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(ColorTheme.textSecondary.opacity(0.85))
                    .lineLimit(1)
                    .offset(y: appeared ? 0 : 8)
                    .opacity(appeared ? 1 : 0)
                    .padding(.bottom, 14)

                // CTA row
                HStack(spacing: 10) {
                    // Primary CTA
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Text("ENTER THE ZONE")
                                .font(.system(size: 10, weight: .black))
                                .tracking(1.5)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10, weight: .black))
                        }
                        .foregroundColor(ColorTheme.background)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(ColorTheme.buttonGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: ColorTheme.primary.opacity(0.45), radius: 10, y: 4)
                    }

                    // Secondary — info pill
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(ColorTheme.golden)
                        Text("AI Powered")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                .offset(y: appeared ? 0 : 8)
                .opacity(appeared ? 1 : 0)
            }
            .padding(18)
            .animation(
                .spring(response: 0.55, dampingFraction: 0.8).delay(0.1),
                value: appeared
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            ColorTheme.primary.opacity(isActive ? 0.35 : 0.1),
                            ColorTheme.secondary.opacity(isActive ? 0.2 : 0.05),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: isActive ? ColorTheme.primary.opacity(0.15) : .clear,
            radius: 20, x: 0, y: 8
        )
        .onChange(of: isActive) { active in
            if active {
                appeared = false
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.05)) {
                    appeared = true
                }
            }
        }
        .onAppear {
            if isActive {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2)) {
                    appeared = true
                }
            }
        }
    }

    // Per-banner metadata
    var bannerCategory: String {
        if banner.title.contains("Train") || banner.title.contains("💪") { return "Workout" }
        if banner.title.contains("Fuel") || banner.title.contains("🥗")  { return "Nutrition" }
        if banner.title.contains("Progress") || banner.title.contains("📈") { return "Analytics" }
        return "FuelFlex"
    }

    var bannerIcon: String {
        if banner.title.contains("Train") || banner.title.contains("💪") { return "dumbbell.fill" }
        if banner.title.contains("Fuel") || banner.title.contains("🥗")  { return "fork.knife" }
        if banner.title.contains("Progress") || banner.title.contains("📈") { return "chart.line.uptrend.xyaxis" }
        return "bolt.fill"
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        ColorTheme.background.ignoresSafeArea()
        ScrollView {
            HomeBannerCarousel(
                banners: [
                    HomeBanner(image: "banner_workout2", title: "Train Smarter 💪",
                               subtitle: "AI-powered workouts made for you"),
                    HomeBanner(image: "banner_nutrition", title: "Fuel Your Body 🥗",
                               subtitle: "Track nutrition & hydration daily"),
                    HomeBanner(image: "banner_progress", title: "See Real Progress 📈",
                               subtitle: "Analytics that keep you motivated")
                ]
            )
            .padding(.top, 20)
        }
    }
    .preferredColorScheme(.dark)
}
