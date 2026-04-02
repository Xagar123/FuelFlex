//
//  WeeklyPlanView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 24/02/26.
//

import SwiftUI

// MARK: - Models
enum WorkoutStatus {
    case completed, today, locked, rest
}

struct WorkoutDay: Identifiable {
    let id = UUID()
    let day: String
    let title: String
    let duration: String?
    let subtext: String?
    let status: WorkoutStatus
}

// MARK: - Components
struct WorkoutCard: View {
    let data: WorkoutDay
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Row
            HStack(spacing: 16) {
                // Status Icon
                statusIcon
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    if data.status == .today {
                        Text("TODAY")
                            .font(.system(size: 10, weight: .black))
                            .kerning(1.2)
                            .foregroundColor(ColorTheme.secondary)
                    }
                    
                    Text(data.day)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(data.status == .today ? .white : ColorTheme.textSecondary)
                    
                    Text("\(data.title)\(data.duration != nil ? " • \(data.duration!)" : "")")
                        .font(.system(size: 13))
                        .foregroundColor(data.status == .today ? .white.opacity(0.9) : .gray)
                    
                    if let sub = data.subtext {
                        Text(sub)
                            .font(.system(size: 12))
                            .foregroundColor(data.status == .today ? ColorTheme.textSecondary : .gray.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Right Side Label/Status
                trailingView
            }
            .padding(16)
            
            // Expanded View
            if isExpanded && data.status != .locked {
                VStack(spacing: 16) {
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(ColorTheme.secondary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Session Overview")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("This session focuses on \(data.title.lowercased()). Follow prescribed rest periods to maximize hypertrophy.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                        if data.status == .today {
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("START WORKOUT")
                                        .font(.system(size: 14, weight: .black))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(ColorTheme.secondary)
                                .foregroundColor(ColorTheme.background)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(data.status == .today ? Color.clear : ColorTheme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(data.status == .today ? ColorTheme.secondary : Color.white.opacity(0.05), lineWidth: 2)
        )
        .shadow(color: data.status == .today ? ColorTheme.secondary.opacity(0.15) : .clear, radius: 10)
        .padding(.bottom, 8)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if data.status != .locked {
                    isExpanded.toggle()
                }
            }
        }
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch data.status {
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(ColorTheme.primary)
        case .today:
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: "dumbbell.fill")
                    .foregroundColor(ColorTheme.secondary)
            }
        case .rest:
            Image(systemName: "figure.mind.and.body")
                .font(.system(size: 24))
                .foregroundColor(.gray)
        case .locked:
            Image(systemName: data.day == "Friday" ? "timer" : "calendar")
                .font(.system(size: 24))
                .foregroundColor(.gray.opacity(0.5))
        }
    }
    
    @ViewBuilder
    private var trailingView: some View {
        HStack(spacing: 8) {
            if data.status == .completed {
                Text("COMPLETED")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            } else if data.status == .today && !isExpanded {
                Text(data.duration ?? "")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(ColorTheme.secondary.opacity(0.2))
                    .foregroundColor(ColorTheme.secondary)
                    .clipShape(Capsule())
            } else if data.status == .rest {
                Text("REST DAY")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            }
            
            if data.status == .locked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.5))
            } else if data.status != .rest {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
    }
}

// MARK: - Main View
struct WeeklyPlanView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var root: WorkoutRoot
    
    let workouts = [
        WorkoutDay(day: "Monday", title: "Upper Body Push", duration: "45 min", subtext: nil, status: .completed),
        WorkoutDay(day: "Tuesday", title: "Cardio Endurance", duration: "30 min", subtext: nil, status: .completed),
        WorkoutDay(day: "Wednesday", title: "Lower Body Power", duration: "50 min", subtext: "Strength & Hypertrophy Focus", status: .today),
        WorkoutDay(day: "Thursday", title: "Active Recovery & Mobility", duration: nil, subtext: nil, status: .rest),
        WorkoutDay(day: "Friday", title: "Full Body HIIT", duration: "40 min", subtext: nil, status: .locked),
        WorkoutDay(day: "Saturday", title: "Upper Body Pull", duration: "50 min", subtext: nil, status: .locked)
    ]
    
    var body: some View {
        
        ZStack {
            ColorTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Custom Navigation Bar
                    HStack {
                        Button(action: {
                            root = .dashboard
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Weekly Plan")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("BUILT FOR YOUR GOAL: FAT LOSS & STRENGTH")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(ColorTheme.secondary)
                            .kerning(0.5)
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
                    .padding(.bottom, 30)
                    
                    // Progress Section
                    VStack(spacing: 8) {
                        HStack {
                            Text("WEEKLY PROGRESS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("2 of 4 workouts completed")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(ColorTheme.surface)
                                Capsule()
                                    .fill(ColorTheme.primary)
                                    .frame(width: geo.size.width * 0.5)
                                    .shadow(color: ColorTheme.primary.opacity(0.4), radius: 4)
                            }
                        }
                        .frame(height: 6)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                    
                    // Workout List
                    VStack(spacing: 4) {
                        ForEach(workouts) { workout in
                            WorkoutCard(data: workout)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

//#Preview {
//    WeeklyPlanView()
//}
