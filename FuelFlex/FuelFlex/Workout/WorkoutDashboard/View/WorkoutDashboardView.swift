//
//  WorkoutDashboard.swift
//  FuelFlex
//
//  Created by DAS Sagar on 03/03/26.
//

import SwiftUI

// MARK: - WorkoutDashboardView
struct WorkoutDashboardView: View {
    
    @EnvironmentObject var planManager: WorkoutPlanManager
    @State private var selectedFilter: WorkoutFilter = .express
    @State private var animateProgress: Bool = false
    @State var navigateToWorkoutDetail: Bool = false
    @State private var selectedDay: WorkoutDay?
    @Binding var rootView: WorkoutRoot
    
    private var plan: WorkoutPlan? { planManager.currentPlan }
    
    private var today: WorkoutDay? { planManager.todayWorkout }
    
    var body: some View {
        ZStack {
            ColorTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .background(ColorTheme.background)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        weeklyProgressCard
                        todayWorkoutCard
                        shortOnTimeSection
                        statsRow
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationDestination(isPresented: $navigateToWorkoutDetail) {
                if let day = selectedDay {
                    WorkoutDetailBriefView(
                        workoutDay: day,
                        rootView: $rootView,
                        navigateToWorkoutDetail: $navigateToWorkoutDetail
                    )
                    .preferredColorScheme(.dark)
                }
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
                    Text(greetingText)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(ColorTheme.textPrimary)
                    Circle()
                        .fill(ColorTheme.primary)
                        .frame(width: 10, height: 10)
                }
                Text(todaySubtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(ColorTheme.secondary)
            }
            Spacer()
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
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting = hour < 12 ? "Good Morning" : hour < 17 ? "Good Afternoon" : "Good Evening"
        return "\(greeting), Sagar"
    }
    
    private var todaySubtitle: String {
        guard let day = today else { return "Rest Day" }
        if day.dayType != .training { return "Rest & Recovery" }
        let dayIndex = plan?.weeklySchedule.filter { $0.dayType == .training }
            .firstIndex(where: { $0.id == day.id }).map { $0 + 1 } ?? 1
        return "Day \(dayIndex) — \(day.title)"
    }
    
    // MARK: - Today's Workout Card
    private var todayWorkoutCard: some View {
        Group {
            if let day = today, day.dayType == .training {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero Image Area
                    ZStack(alignment: .topLeading) {
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
                                ZStack {
                                    Image("lowerBody")
                                        .resizable()
                                        .scaledToFit()
                                        .opacity(0.7)
                                    
                                    VStack {
                                        Spacer()
                                        LinearGradient(
                                            colors: [Color.clear, ColorTheme.surface],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        .frame(height: 80)
                                    }
                                }
                            )
                        
                        HStack(spacing: 8) {
                            TagBadge(text: "STRENGTH")
                            if plan?.fitnessLevel == .advanced {
                                TagBadge(text: "PRO")
                            }
                        }
                        .padding(12)
                    }
                    
                    // Card Content
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(day.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(ColorTheme.textPrimary)
                            
                            HStack(spacing: 6) {
                                ForEach(Array(day.focusMuscles.prefix(3)), id: \.self) { muscle in
                                    if muscle != day.focusMuscles.first {
                                        Circle().frame(width: 3, height: 3)
                                    }
                                    Text(muscle.displayName)
                                }
                            }
                            .font(.system(size: 13))
                            .foregroundColor(ColorTheme.textSecondary)
                        }
                        
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "clock")
                                    .foregroundColor(ColorTheme.secondary)
                                Text("\(day.estimatedDuration) min")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(ColorTheme.textPrimary)
                            }
                            Spacer()
                            HStack(spacing: 6) {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(ColorTheme.primary)
                                Text("\(day.estimatedCalories) kcal")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(ColorTheme.textPrimary)
                            }
                        }
                        
                        Button(action: {
                            selectedDay = day
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
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ColorTheme.surface, lineWidth: 1)
                )
            } else {
                // Rest day card
                VStack(spacing: 12) {
                    Image(systemName: "figure.mind.and.body")
                        .font(.system(size: 40))
                        .foregroundColor(ColorTheme.secondary)
                    Text("Rest Day")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(ColorTheme.textPrimary)
                    Text("Recovery is part of the plan. You've earned it.")
                        .font(.system(size: 14))
                        .foregroundColor(ColorTheme.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        if let day = today {
                            planManager.overrideRestDay(day)
                        }
                    } label: {
                        Text("Train Anyway")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(ColorTheme.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(ColorTheme.buttonGradient)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .background(ColorTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    // MARK: - Short on Time
    private var shortOnTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SHORT ON TIME?")
                .font(.system(size: 12, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(ColorTheme.textSecondary)
            
            HStack(spacing: 12) {
                FilterButton(icon: "timer", title: "15-min Express", isSelected: selectedFilter == .express) {
                    selectedFilter = .express
                }
                FilterButton(icon: "figure.walk", title: "No-Equipment", isSelected: selectedFilter == .noEquipment) {
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
                Button {
                    rootView = .weeklyPlan
                } label: {
                    Text("VIEW PLAN")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(1)
                        .foregroundColor(ColorTheme.secondary)
                }
            }
            
            if let schedule = plan?.weeklySchedule {
                HStack(spacing: 0) {
                    ForEach(schedule) { day in
                        let status = weekDayStatus(for: day)
                        VStack(spacing: 8) {
                            Text(day.dayOfWeek.letter)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(status == .today ? ColorTheme.secondary : ColorTheme.textSecondary)
                            WeekDayCircle(status: status)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(20)
        .background(ColorTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func weekDayStatus(for day: WorkoutDay) -> WeekDayStatus {
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        let mapped = todayWeekday == 1 ? 7 : todayWeekday - 1
        if day.isCompleted { return .completed }
        if day.dayOfWeek.rawValue == mapped { return .today }
        return .upcoming
    }
    
    // MARK: - Stats Row
    private var statsRow: some View {
        let completed = planManager.completedDaysThisWeek
        let total = planManager.trainingDaysThisWeek
        let calories = planManager.totalCaloriesBurned
        let consistencyProgress = total > 0 ? Double(completed) / Double(total) : 0
        
        return HStack(spacing: 12) {
            DashboardStatCard(
                title: "CONSISTENCY",
                value: "\(completed)/\(total)",
                unit: "Workouts",
                progress: animateProgress ? consistencyProgress : 0,
                color: ColorTheme.secondary
            )
            DashboardStatCard(
                title: "ENERGY BURN",
                value: "\(calories)",
                unit: "kcal",
                progress: animateProgress ? min(Double(calories) / 2500.0, 1.0) : 0,
                color: ColorTheme.primary
            )
        }
    }
}

// MARK: - Supporting Views

enum WeekDayStatus {
    case completed, today, upcoming
}

struct DashboardStatCard: View {
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
