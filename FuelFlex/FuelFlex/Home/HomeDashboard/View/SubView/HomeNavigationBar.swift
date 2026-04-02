//
//  HomeNavigationBar.swift
//  FuelFlex
//
//  Created by DAS Sagar on 05/03/26.
//

//
//  HomeNavigationBar.swift
//  FuelFlex
//

import SwiftUI

// MARK: - Header Button

struct HeaderButton: View {
    let icon: String
    var badgeCount: Int = 0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                // Blur base
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .frame(width: 42, height: 42)

                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.08), Color.white.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )

            // Badge
            if badgeCount > 0 {
                ZStack {
                    Circle()
                        .fill(ColorTheme.accent)
                        .frame(width: 16, height: 16)
                    Text("\(min(badgeCount, 9))\(badgeCount > 9 ? "+" : "")")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(.white)
                }
                .offset(x: 4, y: -4)
                .shadow(color: ColorTheme.accent.opacity(0.6), radius: 4)
            }
        }
    }
}

// MARK: - Coin Badge View

struct CoinBadgeView: View {

    let coins: Int
    @State private var shimmer: Bool = false
    @State private var coinBounce: Bool = false
    @State private var showReward: Bool = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                coinBounce = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                coinBounce = false
            }
            withAnimation(.spring(response: 0.4)) {
                showReward = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation { showReward = false }
            }
        }) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                ColorTheme.golden.opacity(0.18),
                                ColorTheme.accent.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 42)

                // Shimmer sweep
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                ColorTheme.golden.opacity(0.25),
                                .clear
                            ],
                            startPoint: shimmer ? .leading : .init(x: -0.5, y: 0),
                            endPoint:   shimmer ? .trailing : .init(x: 0.5, y: 0)
                        )
                    )
                    .frame(height: 42)
                    .animation(
                        .easeInOut(duration: 2).repeatForever(autoreverses: false),
                        value: shimmer
                    )

                // Border
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [ColorTheme.golden.opacity(0.5), ColorTheme.accent.opacity(0.2)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .frame(height: 42)

                // Content
                HStack(spacing: 6) {
                    // Coin icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [ColorTheme.golden, ColorTheme.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 26, height: 26)
                            .shadow(color: ColorTheme.golden.opacity(0.5), radius: 4)

                        Text("₣")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(coinBounce ? 1.25 : 1.0)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(coins)")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ColorTheme.golden, ColorTheme.accent],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .contentTransition(.numericText())
                        Text("COINS")
                            .font(.system(size: 7, weight: .black))
                            .tracking(1.5)
                            .foregroundColor(ColorTheme.golden.opacity(0.6))
                    }
                }
                .padding(.horizontal, 10)
            }
            .frame(height: 42)
        }
        .buttonStyle(.plain)
        .onAppear { shimmer = true }
        .overlay(
            // Float reward toast
            Group {
                if showReward {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundColor(ColorTheme.golden)
                        Text("+25 today")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(ColorTheme.golden)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(ColorTheme.golden.opacity(0.15))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(ColorTheme.golden.opacity(0.3), lineWidth: 1))
                    .shadow(color: ColorTheme.golden.opacity(0.3), radius: 8)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal:   .move(edge: .top).combined(with: .opacity)
                    ))
                    .offset(y: -50)
                }
            }
        )
    }
}

// MARK: - Home Navigation Bar

struct HomeNavigationBar: View {

    let userName: String
    let dateString: String
    let coins: Int
    var notificationCount: Int = 3

    @State private var greetingScale: Bool = false

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default:      return "Rest Up"
        }
    }

    var greetingIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "sunrise.fill"
        case 12..<17: return "sun.max.fill"
        case 17..<21: return "sunset.fill"
        default:      return "moon.stars.fill"
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {

            // ── Profile picture ───────────────────────────────
            profileAvatar

            // ── Name + greeting ───────────────────────────────
            VStack(alignment: .leading, spacing: 3) {

                // Greeting line
                HStack(spacing: 5) {
                    Image(systemName: greetingIcon)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(ColorTheme.golden)
                    Text(greeting)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(ColorTheme.textSecondary)
                }

                // Name
                Text(userName.uppercased())
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.white)
                    .scaleEffect(greetingScale ? 1.02 : 1.0, anchor: .leading)

                // Date row
                HStack(spacing: 5) {
                    Image(systemName: "calendar")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(ColorTheme.primary)
                    Text(dateString)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(ColorTheme.textSecondary.opacity(0.7))
                }
            }

            Spacer()

            // ── Right actions ─────────────────────────────────
            HStack(spacing: 10) {
                // Coin badge
                CoinBadgeView(coins: coins)

                // Notification bell
                HeaderButton(icon: "bell.fill", badgeCount: notificationCount)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 14)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3)) {
                greetingScale = true
            }
        }
    }

    // MARK: - Profile Avatar

    var profileAvatar: some View {
        ZStack(alignment: .bottomTrailing) {

            // Outer glow ring
            Circle()
                .fill(
                    LinearGradient(
                        colors: [ColorTheme.primary.opacity(0.3), ColorTheme.secondary.opacity(0.2)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 56, height: 56)

            // Profile image
            Image("profile_pic")
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(
                        LinearGradient(
                            colors: [ColorTheme.primary, ColorTheme.secondary],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                )
                .shadow(color: ColorTheme.primary.opacity(0.35), radius: 8, y: 3)

            // Online dot
            ZStack {
                Circle()
                    .fill(ColorTheme.background)
                    .frame(width: 14, height: 14)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.green, Color.green.opacity(0.6)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 5
                        )
                    )
                    .frame(width: 10, height: 10)
                    .shadow(color: Color.green.opacity(0.8), radius: 3)
            }
            .offset(x: 2, y: 2)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        // Simulate the nav_bg
        LinearGradient(
            colors: [Color(hex: "#1a2540"), ColorTheme.background],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack {
            HomeNavigationBar(
                userName: "Sagar",
                dateString: "Tuesday · Jan 13",
                coins: 1_240,
                notificationCount: 3
            )
            Spacer()
        }
    }
    .preferredColorScheme(.dark)
}
