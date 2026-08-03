//  Dashboard.swift
//  FuelFlex
//
//  Created by DAS Sagar on 12/01/26.
//

import SwiftUI

// MARK: - Models

struct TodayWorkoutPlan: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let duration: Int
    let exercises: Int
    let calories: Int
    let difficulty: Difficulty
    let muscleGroups: [String]
    let imageName: String
    let isScheduled: Bool

    enum Difficulty: String {
        case beginner     = "BEGINNER"
        case intermediate = "INTERMEDIATE"
        case advanced     = "ADVANCED"

        var color: Color {
            switch self {
            case .beginner:     return ColorTheme.primary
            case .intermediate: return ColorTheme.secondary
            case .advanced:     return ColorTheme.accent
            }
        }
    }
}

struct SuggestedWorkout: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let duration: Int
    let exercises: Int
    let calories: Int
    let rating: Double
    let imageName: String
    let tag: String
    let tagColor: Color
}

// MARK: - Dashboard

struct Dashboard: View {

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var planManager: WorkoutPlanManager

    private var user: FuelFlexUser? { authViewModel.currentUser }

    private var todayDateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE · MMM d"
        return f.string(from: Date())
    }

    let homeBanners: [HomeBanner] = [
        HomeBanner(image: "banner_workout2",  title: "Train Smarter 💪",     subtitle: "AI-powered workouts made for you"),
        HomeBanner(image: "banner_nutrition", title: "Fuel Your Body 🥗",    subtitle: "Track nutrition & hydration daily"),
        HomeBanner(image: "banner_progress",  title: "See Real Progress 📈", subtitle: "Analytics that keep you motivated")
    ]

    // MARK: - Live Plan Data

    private var todayPlans: [TodayWorkoutPlan] {
        guard let schedule = planManager.currentPlan?.weeklySchedule else { return [] }
        let weekday = Calendar.current.component(.weekday, from: Date())
        let mapped = weekday == 1 ? 7 : weekday - 1
        // Today's workout first (scheduled), then next upcoming training days
        let sorted = schedule
            .filter { $0.dayType == .training }
            .sorted { a, b in
                let aIsToday = a.dayOfWeek.rawValue == mapped
                let bIsToday = b.dayOfWeek.rawValue == mapped
                if aIsToday != bIsToday { return aIsToday }
                // Sort remaining by proximity to today
                let aDist = (a.dayOfWeek.rawValue - mapped + 7) % 7
                let bDist = (b.dayOfWeek.rawValue - mapped + 7) % 7
                return aDist < bDist
            }
        return sorted.prefix(3).map { day in
            TodayWorkoutPlan(
                title: day.title,
                subtitle: day.focusMuscles.map(\.displayName).joined(separator: ", "),
                duration: day.estimatedDuration,
                exercises: day.phases.flatMap(\.exercises).count,
                calories: day.estimatedCalories,
                difficulty: mapDifficulty(planManager.currentPlan?.fitnessLevel ?? .intermediate),
                muscleGroups: day.focusMuscles.prefix(3).map(\.displayName),
                imageName: imageForMuscles(day.focusMuscles),
                isScheduled: day.dayOfWeek.rawValue == mapped
            )
        }
    }

    private var suggestedWorkouts: [SuggestedWorkout] {
        guard let schedule = planManager.currentPlan?.weeklySchedule else { return [] }
        let weekday = Calendar.current.component(.weekday, from: Date())
        let mapped = weekday == 1 ? 7 : weekday - 1
        // Show upcoming training days (excluding today) as suggestions
        let upcoming = schedule
            .filter { $0.dayType == .training && $0.dayOfWeek.rawValue != mapped }
            .sorted { a, b in
                let aDist = (a.dayOfWeek.rawValue - mapped + 7) % 7
                let bDist = (b.dayOfWeek.rawValue - mapped + 7) % 7
                return aDist < bDist
            }
        let tags = [("NEXT UP", ColorTheme.accent), ("UPCOMING", ColorTheme.primary),
                    ("LATER", ColorTheme.secondary), ("PLANNED", ColorTheme.golden)]
        return upcoming.prefix(4).enumerated().map { idx, day in
            let tag = tags[min(idx, tags.count - 1)]
            return SuggestedWorkout(
                title: day.title,
                category: day.focusMuscles.first?.displayName.uppercased() ?? "TRAINING",
                duration: day.estimatedDuration,
                exercises: day.phases.flatMap(\.exercises).count,
                calories: day.estimatedCalories,
                rating: 4.7,
                imageName: imageForMuscles(day.focusMuscles),
                tag: tag.0,
                tagColor: tag.1
            )
        }
    }

    private func mapDifficulty(_ level: FitnessLevel) -> TodayWorkoutPlan.Difficulty {
        switch level {
        case .beginner: return .beginner
        case .intermediate: return .intermediate
        case .advanced: return .advanced
        }
    }

    private func imageForMuscles(_ muscles: [MuscleGroup]) -> String {
        guard let primary = muscles.first else { return "workout_upper" }
        switch primary {
        case .chest, .shoulders, .triceps: return "workout_upper"
        case .back, .biceps: return "suggest_pull"
        case .quads, .hamstrings, .glutes, .calves: return "suggest_legs"
        case .core: return "workout_core"
        case .fullBody: return "workout_hiit"
        }
    }

    @State private var bpm: Int = 72
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack(alignment: .top) {
            ColorTheme.background.ignoresSafeArea()

            // Nav background image
            Image("nav_bg")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    ColorTheme.background.opacity(0.3),
                                    ColorTheme.background.opacity(0.85),
                                    ColorTheme.background
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {

                // ── Nav Bar ───────────────────────────────────────
                HomeNavigationBar(
                    userName: user?.fullName.components(separatedBy: " ").first ?? "User",
                    dateString: todayDateString,
                    coins: 1_240,
                    notificationCount: 3
                )

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        HomeBannerCarousel(banners: homeBanners)
                        DailyGoalsSection()
                        vitalsView
                        weeklyStreakView
                        todayWorkoutSection
                        suggestedWorkoutsSection
                        Spacer(minLength: 30)
                    }
                    .padding(.vertical)
                }
                .navigationBarHidden(true)
            }
        }
        .onAppear { startHeartRateAnimation() }
    }

  
    // MARK: - Vitals

    var vitalsView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 30) {
                VitalsSection()
                    .padding(.horizontal, 20)
            }
            FuelStatusCard(
                    calorieGoal: user?.dailyCalories ?? 2400,
                    proteinGoal: user?.proteinGrams ?? 142,
                    carbsGoal: user?.carbsGrams ?? 210,
                    fatsGoal: user?.fatsGrams ?? 58
                )
        }
        .padding(.horizontal)
        .offset(y: -20)
    }

    // MARK: - Weekly Streak

    var weeklyStreakView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(ColorTheme.accentGradient)
                    .frame(width: 3, height: 18)
                Text("WEEKLY STREAK")
                    .font(.system(size: 13, weight: .black))
                    .tracking(2)
                    .foregroundColor(.white)
                Spacer()
                Text("\(planManager.completedDaysThisWeek)/\(planManager.trainingDaysThisWeek)")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(ColorTheme.buttonGradient)
            }
            .padding(.horizontal, 20)

            HStack(spacing: 8) {
                ForEach(DayOfWeek.allCases, id: \.rawValue) { day in
                    let workoutDay = planManager.currentPlan?.weeklySchedule.first { $0.dayOfWeek == day }
                    let isTraining = workoutDay?.dayType == .training
                    let isCompleted = workoutDay?.isCompleted == true
                    let isToday = isDayToday(day)

                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(circleFill(isCompleted: isCompleted, isTraining: isTraining, isToday: isToday))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle().stroke(
                                        circleBorder(isCompleted: isCompleted, isTraining: isTraining, isToday: isToday),
                                        lineWidth: isToday ? 2 : 1
                                    )
                                )

                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(ColorTheme.background)
                            } else if isTraining {
                                Image(systemName: "dumbbell.fill")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(isToday ? ColorTheme.primary : ColorTheme.textSecondary.opacity(0.5))
                            }
                        }

                        Text(day.letter)
                            .font(.system(size: 10, weight: isToday ? .black : .bold))
                            .foregroundColor(isToday ? ColorTheme.primary : ColorTheme.textSecondary.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(ColorTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
            .padding(.horizontal, 16)
        }
    }

    private func isDayToday(_ day: DayOfWeek) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let mapped = weekday == 1 ? 7 : weekday - 1
        return day.rawValue == mapped
    }

    private func circleFill(isCompleted: Bool, isTraining: Bool, isToday: Bool) -> Color {
        if isCompleted { return ColorTheme.primary }
        if isToday && isTraining { return ColorTheme.primary.opacity(0.15) }
        return Color.white.opacity(0.04)
    }

    private func circleBorder(isCompleted: Bool, isTraining: Bool, isToday: Bool) -> Color {
        if isCompleted { return ColorTheme.primary }
        if isToday { return ColorTheme.primary.opacity(0.6) }
        if isTraining { return ColorTheme.secondary.opacity(0.3) }
        return Color.white.opacity(0.08)
    }

    // MARK: - Today Workout Section

    var todayWorkoutSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Section header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(ColorTheme.buttonGradient)
                            .frame(width: 3, height: 18)
                        Text("TODAY'S PLAN")
                            .font(.system(size: 13, weight: .black))
                            .tracking(2)
                            .foregroundColor(.white)
                    }
                    Text("\(planManager.trainingDaysThisWeek) workouts this week · \(planManager.completedDaysThisWeek) done")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(ColorTheme.textSecondary)
                        .padding(.leading, 9)
                }
                Spacer()
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.system(size: 12, weight: .bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ColorTheme.primary, ColorTheme.secondary],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                }
            }
            .padding(.horizontal, 20)

            if todayPlans.isEmpty {
                Text("No plan generated yet. Head to Workouts to create one!")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(ColorTheme.textSecondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 14) {
                        ForEach(todayPlans) { plan in
                            TodayWorkoutCard(plan: plan)
                                .frame(width: 220, height: 260)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
                }
                .frame(height: 272)
                .scrollClipDisabled()
                .contentMargins(.horizontal, 0, for: .scrollContent)
            }
        }
    }

    // MARK: - Suggested Workouts Section

    var suggestedWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Section header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(ColorTheme.accentGradient)
                            .frame(width: 3, height: 18)
                        Text("UPCOMING WORKOUTS")
                            .font(.system(size: 13, weight: .black))
                            .tracking(2)
                            .foregroundColor(.white)
                    }
                    Text("Your scheduled sessions this week")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(ColorTheme.textSecondary)
                        .padding(.leading, 9)
                }
                Spacer()
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Explore")
                            .font(.system(size: 12, weight: .bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ColorTheme.accent, ColorTheme.golden],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                }
            }
            .padding(.horizontal, 20)

            if suggestedWorkouts.isEmpty {
                Text("No upcoming workouts scheduled.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(ColorTheme.textSecondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 14) {
                        ForEach(suggestedWorkouts) { workout in
                            SuggestedWorkoutCard(workout: workout)
                                .frame(width: 220, height: 130)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
                }
                .frame(height: 282)
                .scrollClipDisabled()
                .contentMargins(.horizontal, 0, for: .scrollContent)
            }
        }
    }

    // MARK: - Helpers

    private func startHeartRateAnimation() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            pulseScale = 1.15
        }
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            bpm = Int.random(in: 70...78)
        }
    }
}

// MARK: - Today Workout Card

struct TodayWorkoutCard: View {

    let plan: TodayWorkoutPlan
    @State private var pressed = false

    var body: some View {
        Button(action: {}) {
            ZStack(alignment: .topLeading) {
                
                // Background + image
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#0d1828"), Color(hex: "#182540")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                    
                    Image(plan.imageName)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                }
                .frame(width: 220, height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // Gradient overlay
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: .clear,                              location: 0.0),
                                .init(color: ColorTheme.background.opacity(0.3),  location: 0.4),
                                .init(color: ColorTheme.background.opacity(0.92), location: 1.0)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 220, height: 260)
                
                // Scheduled badge — top left
                if plan.isScheduled {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(ColorTheme.primary)
                            .frame(width: 6, height: 6)
                        Text("SCHEDULED")
                            .font(.system(size: 8, weight: .black))
                            .tracking(1.5)
                            .foregroundColor(ColorTheme.primary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(ColorTheme.primary.opacity(0.4), lineWidth: 1))
                    .padding(12)
                }
                
                // Difficulty badge — top right
                HStack {
                    Spacer()
                    Text(plan.difficulty.rawValue)
                        .font(.system(size: 7, weight: .black))
                        .tracking(1)
                        .foregroundColor(plan.difficulty.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(plan.difficulty.color.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(plan.difficulty.color.opacity(0.35), lineWidth: 1))
                }
                .padding(12)
                
                // Bottom content
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    
                    // Muscle chips
                    HStack(spacing: 5) {
                        ForEach(plan.muscleGroups, id: \.self) { group in
                            Text(group)
                                .font(.system(size: 8, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(ColorTheme.secondary.opacity(0.9))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(ColorTheme.secondary.opacity(0.1))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(ColorTheme.secondary.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    
                    // Title & subtitle
                    Text(plan.title)
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(plan.subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(ColorTheme.textSecondary)
                        .lineLimit(1)
                    
                    // Stats row
                    HStack(spacing: 0) {
                        miniStat(icon: "clock.fill",  value: "\(plan.duration)m",    color: ColorTheme.primary)
                        Spacer()
                        miniStat(icon: "bolt.fill",   value: "\(plan.exercises) ex", color: ColorTheme.secondary)
                        Spacer()
                        miniStat(icon: "flame.fill",  value: "\(plan.calories) cal", color: ColorTheme.accent)
                    }
                    .padding(.top, 2)
                    
                    // CTA button
                    HStack {
                        Text("START WORKOUT")
                            .font(.system(size: 11, weight: .black))
                            .tracking(1.5)
                            .foregroundColor(ColorTheme.background)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(ColorTheme.background)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(ColorTheme.buttonGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: ColorTheme.primary.opacity(0.35), radius: 8)
                }
                .padding(14)
                .frame(width: 220, height: 260, alignment: .bottomLeading)
            }
            .frame(width: 220, height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                ColorTheme.primary.opacity(0.25),
                                ColorTheme.secondary.opacity(0.15)
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: ColorTheme.primary.opacity(0.08), radius: 16, x: 0, y: 8)
            .scaleEffect(pressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: pressed)
            // ✅ Use _onButtonGesture instead of simultaneousGesture
            // It doesn't block the parent scroll recognizer
            .onTapGesture { /* navigate */ }
            ._onButtonGesture(
                pressing: { isPressing in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        pressed = isPressing
                    }
                },
                perform: {}
            )
        }
    }

    func miniStat(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(ColorTheme.textSecondary)
        }
    }
}

// MARK: - Suggested Workout Card

struct SuggestedWorkoutCard: View {

    let workout: SuggestedWorkout
    @State private var pressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Image area
            ZStack(alignment: .topLeading) {
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#0e1a2e"), Color(hex: "#1a2e48")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
//                        .frame(width: 170, height: 130)
                        .frame(width: 220, height: 130)

                    Image(workout.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 130)
                        .clipped()
                }

                // Gradient on image
                LinearGradient(
                    colors: [.clear, ColorTheme.surface.opacity(0.5)],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(width: 220, height: 130)
                .allowsHitTesting(false)

                // Tag badge — top left
                Text(workout.tag)
                    .font(.system(size: 8, weight: .black))
                    .tracking(1.2)
                    .foregroundColor(ColorTheme.background)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(workout.tagColor)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .shadow(color: workout.tagColor.opacity(0.5), radius: 6)
                    .padding(10)

                // Rating — top right
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                        .foregroundColor(ColorTheme.golden)
                    Text(String(format: "%.1f", workout.rating))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(10)
                .frame(width: 220, alignment: .trailing)
            }
            .frame(width: 220, height: 130)
            .clipped()

            // Info area
            VStack(alignment: .leading, spacing: 8) {

                Text(workout.category)
                    .font(.system(size: 9, weight: .black))
                    .tracking(2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ColorTheme.primary, ColorTheme.secondary],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )

                Text(workout.title)
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(1)

                // Stats
                HStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 9))
                            .foregroundColor(ColorTheme.primary)
                        Text("\(workout.duration)m")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 9))
                            .foregroundColor(ColorTheme.secondary)
                        Text("\(workout.exercises) ex")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 9))
                            .foregroundColor(ColorTheme.accent)
                        Text("\(workout.calories)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(ColorTheme.textSecondary)
                    }
//                    Spacer()
                }

                // Add to plan
                HStack(spacing: 5) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 12))
                    Text("Add to Plan")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [ColorTheme.accent, ColorTheme.golden],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
            }
            .padding(12)
            .frame(width: 220, alignment: .leading)
            .background(ColorTheme.surface)
        }
        .frame(width: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    ColorTheme.secondary.opacity(0.2),
                                    ColorTheme.primary.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: ColorTheme.secondary.opacity(0.07), radius: 14, x: 0, y: 6)
                .scaleEffect(pressed ? 0.96 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: pressed)
                // ✅ onTapGesture ONLY — no DragGesture at all
                .onTapGesture {
                    // handle navigation
                }
                // ✅ _onButtonGesture gives press state without blocking scroll
                ._onButtonGesture(pressing: { isPressing in
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        pressed = isPressing
                    }
                }, perform: {})
    }
}
// MARK: - Preview

#Preview {
    Dashboard()
        .environmentObject(AuthViewModel())
        .environmentObject(WorkoutPlanManager())
        .environmentObject(GoalManager())
        .preferredColorScheme(.dark)
}
