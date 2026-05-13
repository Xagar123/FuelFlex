//
//  GeneratedPlanPreview.swift
//  FuelFlex
//

import SwiftUI

struct GeneratedPlanPreview: View {
    
    @EnvironmentObject var planManager: WorkoutPlanManager
    var onDismiss: () -> Void
    
    private var schedule: [WorkoutDay] {
        planManager.currentPlan?.weeklySchedule ?? []
    }
    
    var body: some View {
        ZStack {
            ColorTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with close button
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(ColorTheme.primary)
                            Text("PLAN READY")
                                .font(.system(size: 10, weight: .black))
                                .tracking(2)
                                .foregroundColor(ColorTheme.primary)
                        }
                        Text("Your Weekly Plan")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(ColorTheme.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(ColorTheme.surface)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(schedule) { day in
                            PlanPreviewCard(day: day)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
                
                // Bottom CTA
                Button(action: onDismiss) {
                    Text("LET'S GO")
                        .font(.system(size: 17, weight: .black))
                        .tracking(2)
                        .foregroundColor(ColorTheme.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(ColorTheme.buttonGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: ColorTheme.primary.opacity(0.3), radius: 10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Plan Preview Card

struct PlanPreviewCard: View {
    let day: WorkoutDay
    
    var body: some View {
        HStack(spacing: 14) {
            // Day circle
            ZStack {
                Circle()
                    .fill(day.dayType == .training ? ColorTheme.primary.opacity(0.12) : Color.white.opacity(0.05))
                    .frame(width: 44, height: 44)
                
                if day.dayType == .training {
                    Text(day.dayOfWeek.letter)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(ColorTheme.primary)
                } else {
                    Image(systemName: "figure.mind.and.body")
                        .font(.system(size: 16))
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(day.dayOfWeek.shortName.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundColor(ColorTheme.textSecondary.opacity(0.5))
                
                Text(day.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                if !day.focusMuscles.isEmpty {
                    Text(day.focusMuscles.map(\.displayName).joined(separator: " · "))
                        .font(.system(size: 11))
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
            
            Spacer()
            
            if day.dayType == .training {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(day.estimatedDuration)m")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(ColorTheme.secondary)
                    Text("\(day.mainExercises.count) exercises")
                        .font(.system(size: 10))
                        .foregroundColor(ColorTheme.textSecondary.opacity(0.5))
                }
            } else {
                Text("REST")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundColor(ColorTheme.textSecondary.opacity(0.4))
            }
        }
        .padding(14)
        .background(ColorTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
