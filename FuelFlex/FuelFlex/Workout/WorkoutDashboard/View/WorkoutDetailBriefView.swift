//
//  WorkoutDetailBriefView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 03/03/26.
//

import SwiftUI

// MARK: - WorkoutDetailBriefView
struct WorkoutDetailBriefView: View {
    
    @EnvironmentObject var planManager: WorkoutPlanManager
    @Environment(\.dismiss) private var dismiss
    
    let workoutDay: WorkoutDay
    @State private var selectedPhaseIndex: Int = 0
    @State var navigateToStartWorkout: Bool = false
    @State var navigateToModifyWorkout: Bool = false
    @Binding var rootView: WorkoutRoot
    @Binding var navigateToWorkoutDetail: Bool
    
    private var availablePhases: [WorkoutPhaseData] {
        workoutDay.phases
    }
    
    private var currentPhaseExercises: [PlannedExercise] {
        guard selectedPhaseIndex < availablePhases.count else { return [] }
        return availablePhases[selectedPhaseIndex].exercises
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ColorTheme.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection
                    
                    VStack(alignment: .leading, spacing: 20) {
                        statsBar
                        phaseSelector
                        exerciseList
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .fullScreenCover(isPresented: $navigateToStartWorkout) {
                WorkoutActiveScreen(workoutDay: workoutDay) {
                    navigateToStartWorkout = false
                }
                .environmentObject(planManager)
                .preferredColorScheme(.dark)
            }
            .navigationDestination(isPresented: $navigateToModifyWorkout) {
                PlanEditorView(dayId: workoutDay.id)
                    .preferredColorScheme(.dark)
            }
            
            bottomCTA
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Default to "main" phase if available
            if let mainIdx = availablePhases.firstIndex(where: { $0.type == .main }) {
                selectedPhaseIndex = mainIdx
            }
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#1A2540"), Color(hex: "#0D1525")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                GeometryReader { geo in
                    Image("lowerBody2")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: 300)
                        .clipped()
                }
            }
            .frame(height: 300)
            .clipped()
            
            LinearGradient(
                colors: [Color.clear, ColorTheme.background],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 300)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(workoutDay.focusMuscles.prefix(2), id: \.self) { muscle in
                        TagPill(text: muscle.displayName.uppercased(), color: ColorTheme.primary)
                    }
                }
                
                Text(workoutDay.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    }
                    Spacer()
                    Button(action: {}) {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                Spacer()
            }
        }
        .frame(height: 300)
    }
    
    // MARK: - Stats Bar
    private var statsBar: some View {
        HStack(spacing: 0) {
            StatItem(icon: "clock", value: "\(workoutDay.estimatedDuration) min", color: ColorTheme.secondary)
            
            Divider()
                .frame(width: 1, height: 40)
                .background(Color.white.opacity(0.1))
            
            StatItem(icon: "bolt.fill", value: "\(workoutDay.estimatedCalories) kcal", color: ColorTheme.primary)
            
            Divider()
                .frame(width: 1, height: 40)
                .background(Color.white.opacity(0.1))
            
            StatItem(icon: "chart.bar.fill", value: planManager.currentPlan?.fitnessLevel.displayName ?? "—", color: ColorTheme.secondary)
        }
        .padding(.vertical, 16)
        .background(ColorTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Phase Selector
    private var phaseSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(availablePhases.enumerated()), id: \.element.id) { index, phase in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedPhaseIndex = index
                        }
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(selectedPhaseIndex == index ? ColorTheme.primary : ColorTheme.surface)
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Circle().stroke(
                                            selectedPhaseIndex == index ? Color.clear : Color.white.opacity(0.15),
                                            lineWidth: 1
                                        )
                                    )
                                
                                Image(systemName: phase.type.icon)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(selectedPhaseIndex == index ? ColorTheme.background : ColorTheme.textSecondary)
                            }
                            
                            Text(phase.type.displayName)
                                .font(.system(size: 11, weight: selectedPhaseIndex == index ? .semibold : .regular))
                                .foregroundColor(selectedPhaseIndex == index ? ColorTheme.primary : ColorTheme.textSecondary)
                        }
                        .frame(height: 80)
                    }
                    
                    if index < availablePhases.count - 1 {
                        Rectangle()
                            .fill(index < selectedPhaseIndex ? ColorTheme.primary.opacity(0.5) : Color.white.opacity(0.15))
                            .frame(width: 30, height: 1.5)
                    }
                }
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 100)
        }
    }
    
    // MARK: - Exercise List
    private var exerciseList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(availablePhases.indices.contains(selectedPhaseIndex) ? availablePhases[selectedPhaseIndex].type.displayName : "Exercises")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                Text("\(currentPhaseExercises.count) Exercises")
                    .font(.system(size: 13))
                    .foregroundColor(ColorTheme.textSecondary)
            }
            
            VStack(spacing: 10) {
                ForEach(currentPhaseExercises) { exercise in
                    PlannedExerciseRow(exercise: exercise)
                }
            }
        }
    }
    
    // MARK: - Bottom CTA
    private var bottomCTA: some View {
        VStack(spacing: 12) {
            Button(action: {
                navigateToStartWorkout = true
            }) {
                Text("Start Workout")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(ColorTheme.background)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(ColorTheme.buttonGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            Button(action: {
                navigateToModifyWorkout = true
            }) {
                Text("Modify Workout")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(ColorTheme.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .padding(.top, 16)
        .background(
            LinearGradient(
                colors: [ColorTheme.background.opacity(0), ColorTheme.background],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Supporting Views

struct TagPill: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .tracking(1)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .overlay(Capsule().stroke(color.opacity(0.4), lineWidth: 1))
            .clipShape(Capsule())
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(ColorTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PlannedExerciseRow: View {
    let exercise: PlannedExercise
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ColorTheme.background)
                        .frame(width: 64, height: 64)
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 26))
                        .foregroundColor(ColorTheme.primary.opacity(0.6))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    Text("\(exercise.sets) Sets • \(exercise.repRangeText) Reps")
                        .font(.system(size: 13))
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    HStack(spacing: 6) {
                        ForEach(exercise.targetMuscles, id: \.self) { muscle in
                            Text(muscle.displayName.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .tracking(0.5)
                                .foregroundColor(
                                    muscle == exercise.targetMuscles.first ? ColorTheme.primary : ColorTheme.textSecondary
                                )
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(ColorTheme.textSecondary)
            }
            .padding(14)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.white.opacity(0.08))
                        .padding(.horizontal, 14)
                    
                    HStack(spacing: 0) {
                        ForEach(1...exercise.sets, id: \.self) { set in
                            VStack(spacing: 4) {
                                Text("Set \(set)")
                                    .font(.system(size: 11))
                                    .foregroundColor(ColorTheme.textSecondary)
                                Text(exercise.repRangeText)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(ColorTheme.textPrimary)
                                Text("reps")
                                    .font(.system(size: 10))
                                    .foregroundColor(ColorTheme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 14)
                    
                    // Show rest time and alternatives
                    if exercise.restSeconds > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "timer")
                                .font(.system(size: 11))
                                .foregroundColor(ColorTheme.secondary)
                            Text("Rest: \(exercise.restSeconds)s")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(ColorTheme.textSecondary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 10)
                    }
                    
                    if !exercise.alternatives.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.system(size: 10))
                                .foregroundColor(ColorTheme.textSecondary.opacity(0.6))
                            Text("Alt: \(exercise.alternatives.joined(separator: ", "))")
                                .font(.system(size: 11))
                                .foregroundColor(ColorTheme.textSecondary.opacity(0.6))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 10)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(ColorTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
