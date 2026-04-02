//
//  WorkoutDashboard.swift
//  FuelFlex
//
//  Created by DAS Sagar on 03/03/26.
//

import SwiftUI


// MARK: - Models
struct WeekDay: Identifiable {
    let id = UUID()
    let letter: String
    let status: WeekDayStatus
}

enum WeekDayStatus {
    case completed, today, upcoming
}

// MARK: - WorkoutDashboardView
struct WorkoutDashboardView: View {
    
    @State private var selectedFilter: WorkoutFilter = .express
    @State private var animateProgress: Bool = false
    @State var navigateToWorkoutDetail: Bool = false
    @Binding var rootView: WorkoutRoot
    
    let weekDays: [WeekDay] = [
        WeekDay(letter: "M", status: .completed),
        WeekDay(letter: "T", status: .completed),
        WeekDay(letter: "W", status: .today),
        WeekDay(letter: "T", status: .upcoming),
        WeekDay(letter: "F", status: .upcoming),
        WeekDay(letter: "S", status: .upcoming),
        WeekDay(letter: "S", status: .upcoming),
    ]
    
    var body: some View {
        ZStack {
            ColorTheme.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: Header
                    headerSection
                    
                    // MARK: Weekly Progress
                    weeklyProgressCard
                    
                    // MARK: Today's Workout Card
                    todayWorkoutCard
                    
                    // MARK: Short on Time
                    shortOnTimeSection
                    
                    // MARK: Stats Row
                    statsRow
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .navigationDestination(isPresented: $navigateToWorkoutDetail) {
                WorkoutDetailBriefView(rootView: $rootView)
                    .preferredColorScheme(.dark)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateProgress = true
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("Good Evening, Sagar")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(ColorTheme.textPrimary)
                    Circle()
                        .fill(ColorTheme.primary)
                        .frame(width: 10, height: 10)
                }
                Text("Day 1 — Lower Body Strength")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(ColorTheme.secondary)
            }
            Spacer()
            // Bell Icon
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(ColorTheme.textPrimary)
                Circle()
                    .fill(ColorTheme.secondary)
                    .frame(width: 8, height: 8)
                    .offset(x: 2, y: -2)
            }
        }
    }
    
    // MARK: - Today's Workout Card
    private var todayWorkoutCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hero Image Area
            ZStack(alignment: .topLeading) {
                // Placeholder image area with gradient
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#1A2540"), Color(hex: "#0D1525")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)
                    .overlay(
                        // Silhouette placeholder
                        ZStack {
                           Image("lowerBody")
                                .resizable()
                                .scaledToFit()
//                                .frame(height: 120)
                                .opacity(0.7)
                            
                            
                            // ✅ Fade gradient at bottom
                            VStack {
                                Spacer()
                                LinearGradient(
                                    colors: [Color.clear, ColorTheme.surface],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .frame(height: 80) // adjust height to taste
                            }
                        }
                    )
//                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Tags
                HStack(spacing: 8) {
                    TagBadge(text: "STRENGTH")
                    TagBadge(text: "PRO")
                }
                .padding(12)
            }
            
            // Card Content
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lower Body Strength")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    HStack(spacing: 6) {
                        Text("Strength")
                        Circle().frame(width: 3, height: 3)
                        Text("Mobility")
                        Circle().frame(width: 3, height: 3)
                        Text("Core")
                    }
                    .font(.system(size: 13))
                    .foregroundColor(ColorTheme.textSecondary)
                }
                
                // Stats Row
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .foregroundColor(ColorTheme.secondary)
                        Text("45 min")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(ColorTheme.textPrimary)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(ColorTheme.primary)
                        Text("520 kcal")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(ColorTheme.textPrimary)
                    }
                }
                
                // Start Button
                Button(action: {
                    navigateToWorkoutDetail = true
                }) {
                    Text("Start Workout")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(ColorTheme.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(ColorTheme.buttonGradient)
                        .clipShape(Capsule())
                }
            }
            .padding(16)
            .background(ColorTheme.surface)
//            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ColorTheme.surface, lineWidth: 1)
        )
    }
    
    // MARK: - Short on Time
    private var shortOnTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SHORT ON TIME?")
                .font(.system(size: 12, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(ColorTheme.textSecondary)
            
            HStack(spacing: 12) {
                FilterButton(
                    icon: "timer",
                    title: "15-min Express",
                    isSelected: selectedFilter == .express
                ) {
                    selectedFilter = .express
                }
                
                FilterButton(
                    icon: "figure.walk",
                    title: "No-Equipment",
                    isSelected: selectedFilter == .noEquipment
                ) {
                    selectedFilter = .noEquipment
                }
            }
        }
    }
    
    // MARK: - Weekly Progress
    private var weeklyProgressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Progress")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                Spacer()
                Text("WEEK 12")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(1)
                    .foregroundColor(ColorTheme.secondary)
            }
            
            HStack(spacing: 0) {
                ForEach(weekDays) { day in
                    VStack(spacing: 8) {
                        Text(day.letter)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(
                                day.status == .today ? ColorTheme.secondary : ColorTheme.textSecondary
                            )
                        
                        WeekDayCircle(status: day.status)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(ColorTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "CONSISTENCY",
                value: "3/4",
                unit: "Workouts",
                progress: animateProgress ? 0.75 : 0,
                color: ColorTheme.secondary
            )
            StatCard(
                title: "ENERGY BURN",
                value: "1,840",
                unit: "kcal",
                progress: animateProgress ? 0.65 : 0,
                color: ColorTheme.primary
            )
        }
    }
    
    struct StatCard: View {
        let title: String
        let value: String
        let unit: String
        let progress: Double
        let color: Color
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1)
                    .foregroundColor(ColorTheme.textSecondary)
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(ColorTheme.textPrimary)
                    Text(unit)
                        .font(.system(size: 13))
                        .foregroundColor(ColorTheme.textSecondary)
                }
                
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color)
                            .frame(width: geo.size.width * progress, height: 4)
                            .animation(.easeOut(duration: 0.8), value: progress)
                    }
                }
                .frame(height: 4)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ColorTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    
}

// MARK: - Supporting Views

struct TagBadge: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .tracking(0.5)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
    }
}

enum WorkoutFilter {
    case express, noEquipment
}

struct FilterButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? ColorTheme.secondary : ColorTheme.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? ColorTheme.secondary : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
            )
        }
    }
}

struct WeekDayCircle: View {
    let status: WeekDayStatus
    
    var body: some View {
        ZStack {
            Circle()
                .fill(background)
                .frame(width: 34, height: 34)
                .overlay(
                    Circle()
                        .stroke(border, lineWidth: status == .today ? 2 : 0)
                )
            
            if status == .completed {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
            } else if status == .today {
                Circle()
                    .fill(ColorTheme.secondary)
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    var background: Color {
        switch status {
        case .completed: return ColorTheme.primary
        case .today: return Color.clear
        case .upcoming: return Color.white.opacity(0.08)
        }
    }
    
    var border: Color {
        status == .today ? ColorTheme.secondary : Color.clear
    }
}


// MARK: - Preview
//#Preview {
//    NavigationStack {
//        WorkoutDashboardView()
//    }
//}
