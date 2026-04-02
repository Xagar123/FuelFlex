//
//  WorkoutDetailBriefView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 03/03/26.
//

import SwiftUI

// MARK: - Models
struct WorkoutPhase: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
}

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let sets: Int
    let reps: Int
    let muscles: [String]
    let imageName: String
}

// MARK: - WorkoutDetailBriefView
struct WorkoutDetailBriefView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhase: Int = 1
    @State var navigateToStartWorkout: Bool = false
    @State var navigateToModifyWorkout: Bool = false
    @Binding var rootView: WorkoutRoot
    
    let phases: [WorkoutPhase] = [
        WorkoutPhase(icon: "figure.walk", label: "Warm-up"),
        WorkoutPhase(icon: "dumbbell.fill", label: "Main Sets"),
        WorkoutPhase(icon: "bolt.fill", label: "Finisher"),
        WorkoutPhase(icon: "cooldown", label: "Cool-down"),
    ]
    
    let exercises: [Exercise] = [
        Exercise(name: "Barbell Back Squat", sets: 4, reps: 8, muscles: ["QUADS", "GLUTES"], imageName: "figure.strengthtraining.traditional"),
        Exercise(name: "Bulgarian Split Squat", sets: 3, reps: 12, muscles: ["QUADS", "CORE"], imageName: "figure.strengthtraining.functional"),
        Exercise(name: "Leg Press", sets: 3, reps: 10, muscles: ["HAMSTRINGS", "QUADS"], imageName: "figure.strengthtraining.traditional"),
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ColorTheme.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: Hero
                    heroSection
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // MARK: Stats Bar
                        statsBar
                        
                        // MARK: Phase Selector
                        phaseSelector
                        
                        // MARK: Exercise List
                        exerciseList
                        
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationDestination(isPresented: $navigateToStartWorkout) {
                WorkoutActiveScreen()
                    .preferredColorScheme(.dark)
            }
            .navigationDestination(isPresented: $navigateToModifyWorkout) {
                WeeklyPlanView(root: $rootView)
                    .preferredColorScheme(.dark)
            }
            
            // MARK: Bottom CTA
            bottomCTA
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            // Image area
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
            
            // Gradient fade into background
            LinearGradient(
                colors: [Color.clear, ColorTheme.background],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 300)
            
            // Overlay content
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    TagPill(text: "STRENGTH", color: ColorTheme.primary)
                    TagPill(text: "STABILITY", color: ColorTheme.secondary)
                }
                
                Text("Lower Body Strength")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            // Nav bar
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
//                    Text("Workout Details")
//                        .font(.system(size: 17, weight: .semibold))
//                        .foregroundColor(.white)
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
            StatItem(icon: "clock", value: "45 min", color: ColorTheme.secondary)
            
            Divider()
                .frame(width: 1, height: 40)
                .background(Color.white.opacity(0.1))
            
            StatItem(icon: "bolt.fill", value: "520 kcal", color: ColorTheme.primary)
            
            Divider()
                .frame(width: 1, height: 40)
                .background(Color.white.opacity(0.1))
            
            StatItem(icon: "chart.bar.fill", value: "Intermediate", color: ColorTheme.secondary)
        }
        .padding(.vertical, 16)
        .background(ColorTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Phase Selector
    private var phaseSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(phases.enumerated()), id: \.offset) { index, phase in
                    PhaseItem(
                        phase: phase,
                        isSelected: selectedPhase == index,
                        index: index,
                        total: phases.count
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedPhase = index
                        }
                    }
                    
                    
                    if index < phases.count - 1 {
                        // Connector line
                        Rectangle()
                            .fill(index < selectedPhase ? ColorTheme.primary.opacity(0.5) : Color.white.opacity(0.15))
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
                Text("Main Sets")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                Text("\(exercises.count) Exercises")
                    .font(.system(size: 13))
                    .foregroundColor(ColorTheme.textSecondary)
            }
            
            VStack(spacing: 10) {
                ForEach(exercises) { exercise in
                    ExerciseRow(exercise: exercise)
                }
            }
        }
    }
    
    // MARK: - Bottom CTA
    private var bottomCTA: some View {
        VStack(spacing: 12) {
            Button(action: {
                self.navigateToStartWorkout = true
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
                self.navigateToModifyWorkout = true
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
            .overlay(
                Capsule().stroke(color.opacity(0.4), lineWidth: 1)
            )
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

struct PhaseItem: View {
    let phase: WorkoutPhase
    let isSelected: Bool
    let index: Int
    let total: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? ColorTheme.primary : ColorTheme.surface)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? Color.clear : Color.white.opacity(0.15),
                                    lineWidth: 1
                                )
                        )
                    
                    Image(systemName: phase.icon == "cooldown" ? "snowflake" : phase.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? ColorTheme.background : ColorTheme.textSecondary)
                }
                
                Text(phase.label)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? ColorTheme.primary : ColorTheme.textSecondary)
            }
            .frame(height: 80)
        }
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Exercise thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ColorTheme.background)
                        .frame(width: 64, height: 64)
                    Image(systemName: exercise.imageName)
                        .font(.system(size: 26))
                        .foregroundColor(ColorTheme.primary.opacity(0.6))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    Text("\(exercise.sets) Sets • \(exercise.reps) Reps")
                        .font(.system(size: 13))
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    HStack(spacing: 6) {
                        ForEach(exercise.muscles, id: \.self) { muscle in
                            Text(muscle)
                                .font(.system(size: 10, weight: .bold))
                                .tracking(0.5)
                                .foregroundColor(
                                    muscle == exercise.muscles.first ? ColorTheme.primary : ColorTheme.textSecondary
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
            
            // Expanded detail
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
                                Text("\(exercise.reps)")
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
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(ColorTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview
//#Preview {
//    NavigationStack {
//        WorkoutDetailBriefView()
//    }
//}
