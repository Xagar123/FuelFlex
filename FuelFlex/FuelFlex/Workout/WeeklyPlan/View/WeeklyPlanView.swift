//
//  WeeklyPlanView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 24/02/26.
//

import SwiftUI

// MARK: - Main View
struct WeeklyPlanView: View {
    
    @EnvironmentObject var planManager: WorkoutPlanManager
    @Environment(\.dismiss) private var dismiss
    @Binding var root: WorkoutRoot
    @State private var editingDayId: UUID? = nil
    @State private var dayEditorId: UUID? = nil
    
    private var schedule: [WorkoutDay] {
        planManager.currentPlan?.weeklySchedule ?? []
    }
    
    private var completedCount: Int { planManager.completedDaysThisWeek }
    private var trainingCount: Int { planManager.trainingDaysThisWeek }
    
    var body: some View {
        NavigationStack {
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
                            
                            Text("BUILT FOR YOUR GOAL: \(planManager.currentPlan?.goal.displayName.uppercased() ?? "FITNESS")")
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
                                Text("\(completedCount) of \(trainingCount) workouts completed")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(ColorTheme.surface)
                                    Capsule()
                                        .fill(ColorTheme.primary)
                                        .frame(width: geo.size.width * (trainingCount > 0 ? CGFloat(completedCount) / CGFloat(trainingCount) : 0))
                                        .shadow(color: ColorTheme.primary.opacity(0.4), radius: 4)
                                }
                            }
                            .frame(height: 6)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                        
                        // Workout List
                        VStack(spacing: 4) {
                            ForEach(schedule) { day in
                                WeeklyPlanCard(day: day, onEdit: {
                                    editingDayId = day.id
                                }, onLongPress: {
                                    dayEditorId = day.id
                                })
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationDestination(item: $editingDayId) { dayId in
                PlanEditorView(dayId: dayId)
                    .preferredColorScheme(.dark)
            }
            .sheet(item: $dayEditorId) { dayId in
                DayEditorSheet(dayId: dayId)
                    .environmentObject(planManager)
                    .presentationDetents([.large])
                    .preferredColorScheme(.dark)
            }
            .navigationBarBackButtonHidden()
        }
    }
}

// MARK: - Weekly Plan Card

struct WeeklyPlanCard: View {
    let day: WorkoutDay
    var onEdit: (() -> Void)? = nil
    var onLongPress: (() -> Void)? = nil
    @State private var isExpanded = false
    
    private var isToday: Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let mapped = weekday == 1 ? 7 : weekday - 1
        return day.dayOfWeek.rawValue == mapped
    }
    
    private var isPast: Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let mapped = weekday == 1 ? 7 : weekday - 1
        return day.dayOfWeek.rawValue < mapped
    }
    
    private var isFuture: Bool { !isToday && !isPast && !day.isCompleted }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Row
            HStack(spacing: 16) {
                statusIcon
                
                VStack(alignment: .leading, spacing: 2) {
                    if isToday {
                        Text("TODAY")
                            .font(.system(size: 10, weight: .black))
                            .kerning(1.2)
                            .foregroundColor(ColorTheme.secondary)
                    }
                    
                    Text(day.dayOfWeek.shortName.capitalized + "day")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isToday ? .white : ColorTheme.textSecondary)
                    
                    HStack(spacing: 4) {
                        Text(day.title)
                        if day.dayType == .training && day.estimatedDuration > 0 {
                            Text("•")
                            Text("\(day.estimatedDuration) min")
                        }
                    }
                    .font(.system(size: 13))
                    .foregroundColor(isToday ? .white.opacity(0.9) : .gray)
                    
                    if !day.focusMuscles.isEmpty {
                        Text(day.focusMuscles.map(\.displayName).joined(separator: ", "))
                            .font(.system(size: 12))
                            .foregroundColor(isToday ? ColorTheme.textSecondary : .gray.opacity(0.8))
                    }
                }
                
                Spacer()
                trailingView
            }
            .padding(16)
            
            // Expanded View
            if isExpanded && day.dayType == .training {
                VStack(spacing: 16) {
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.horizontal)
                    
                    // Show main exercises
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(day.mainExercises) { exercise in
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(ColorTheme.primary.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Text("\(exercise.order + 1)")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(ColorTheme.primary)
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(exercise.name)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("\(exercise.sets) × \(exercise.repRangeText) reps")
                                        .font(.system(size: 11))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    
                    if onEdit != nil {
                        Button(action: { onEdit?() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Edit Exercises")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(ColorTheme.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(ColorTheme.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(ColorTheme.secondary.opacity(0.3), lineWidth: 1))
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isToday ? Color.clear : ColorTheme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isToday ? ColorTheme.secondary : Color.white.opacity(0.05), lineWidth: 2)
        )
        .shadow(color: isToday ? ColorTheme.secondary.opacity(0.15) : .clear, radius: 10)
        .padding(.bottom, 8)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if day.dayType == .training {
                    isExpanded.toggle()
                }
            }
        }
        .onLongPressGesture {
            onLongPress?()
        }
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        if day.isCompleted {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(ColorTheme.primary)
        } else if isToday {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: "dumbbell.fill")
                    .foregroundColor(ColorTheme.secondary)
            }
        } else if day.dayType == .rest || day.dayType == .activeRecovery {
            Image(systemName: "figure.mind.and.body")
                .font(.system(size: 24))
                .foregroundColor(.gray)
        } else {
            Image(systemName: isFuture ? "lock.fill" : "calendar")
                .font(.system(size: 24))
                .foregroundColor(.gray.opacity(0.5))
        }
    }
    
    @ViewBuilder
    private var trailingView: some View {
        HStack(spacing: 8) {
            if day.isCompleted {
                Text("COMPLETED")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            } else if isToday && !isExpanded && day.estimatedDuration > 0 {
                Text("\(day.estimatedDuration) min")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(ColorTheme.secondary.opacity(0.2))
                    .foregroundColor(ColorTheme.secondary)
                    .clipShape(Capsule())
            } else if day.dayType == .rest || day.dayType == .activeRecovery {
                Text("REST DAY")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            }
            
            Button {
                onLongPress?()
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(ColorTheme.secondary.opacity(0.6))
            }
            
            if isFuture && day.dayType == .training {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.5))
            } else if day.dayType == .training {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
    }
}
