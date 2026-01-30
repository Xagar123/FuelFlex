//
//  Dashboard.swift
//  FuelFlex
//
//  Created by DAS Sagar on 12/01/26.
//

import SwiftUI

struct Dashboard: View {
    
    let homeBanners: [HomeBanner] = [
        HomeBanner(
            image: "banner_workout2",
            title: "Train Smarter 💪",
            subtitle: "AI-powered workouts made for you"
        ),
        HomeBanner(
            image: "banner_nutrition",
            title: "Fuel Your Body 🥗",
            subtitle: "Track nutrition & hydration daily"
        ),
        HomeBanner(
            image: "banner_progress",
            title: "See Real Progress 📈",
            subtitle: "Analytics that keep you motivated"
        )
    ]
    @State private var bpm: Int = 72
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack(alignment: .top) {
            ColorTheme.background.ignoresSafeArea()
            
            ZStack(alignment: .bottom) {
                Image("nav_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipped()
                
                // 🔥 Fade into background
                LinearGradient(
                    colors: [
                        Color.clear,
                        ColorTheme.background.opacity(0.4),
                        ColorTheme.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 80)
            }
            .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 0) {
             
                homeNavigationBarView
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        HomeBannerCarousel(banners: homeBanners)
                        
                        //addind vitals
                        vitalsView
                        //
//                        DailySummaryCard()
//                            .padding(.horizontal)
                        
                        VStack {
                            ColorTheme.background.ignoresSafeArea()
                            ScrollView {
                                ProgressSectionView()
                            }
                        }
                        .padding(.top,-24)
                    }
                    .padding(.vertical)
                }
                .navigationBarHidden(true)
            }
        }
        .onAppear {
            startHeartRateAnimation()
        }
    }
    
    var homeNavigationBarView: some View {
        HStack(spacing: 16) {

            // PROFILE IMAGE WITH ONLINE INDICATOR
            ZStack(alignment: .bottomTrailing) {

                Image("profile_pic")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 46, height: 46)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [ColorTheme.primary, ColorTheme.secondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2.5
                            )
                    )
                    .shadow(color: ColorTheme.primary.opacity(0.4), radius: 6, y: 3)

                // 🟢 Online Indicator
                Circle()
                    .fill(Color.green)
                    .frame(width: 15, height: 15)
                    .overlay(
                        Circle()
                            .stroke(ColorTheme.background, lineWidth: 2)
                    )
                    .offset(x: 1, y: 2)
            }

            // DATE (VERTICALLY CENTERED WITH PROFILE)
            VStack(alignment: .leading, spacing: 4) {
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SAGAR").font(.system(size: 28, weight: .black))
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(ColorTheme.primary)
                            
                            Text("Tuesday · Jan 13")
                                .font(.caption.bold())
                                .foregroundColor(ColorTheme.textSecondary)
                        }
                    }
                    Spacer()
                    HStack(spacing: 12) {
                        HeaderButton(icon: "magnifyingglass")
                        HeaderButton(icon: "bell.badge.fill")
                    }
                }

            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 14)

    }
    
    var vitalsView: some View {
        VStack(spacing: 24) {
            // Vital Signs
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("VITAL SIGNS", systemImage: "timer")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                        .tracking(1)
                    Spacer()
                    Text("LIVE")
                        .font(.system(size: 10, weight: .black))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(4)
                }
                
                HStack(spacing: 12) {
                    StatCard(icon: "heart.fill", value: "\(bpm)", unit: "BPM", label: "PULSE", color: ColorTheme.accent, isPulse: true, pulseScale: pulseScale)
                    StatCard(icon: "drop.fill", value: "1.8", unit: "LTR", label: "WATER", color: ColorTheme.secondary)
                    StatCard(icon: "figure.walk", value: "8.4", unit: "K", label: "STEPS", color: ColorTheme.primary)
                }
            }
            
            // Fuel Status Card
            FuelStatusCard()
        }
        .padding(.horizontal)
        .offset(y: -20)
    }
    
    private func startHeartRateAnimation() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            pulseScale = 1.15
        }
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            bpm = Int.random(in: 70...78)
        }
    }
}

#Preview {
    Dashboard()
        .preferredColorScheme(.dark)
}
