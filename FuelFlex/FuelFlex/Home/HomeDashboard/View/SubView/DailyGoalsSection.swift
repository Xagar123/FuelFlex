import SwiftUI

// MARK: - Daily Goals Section (Home Dashboard)

struct DailyGoalsSection: View {
    
    @EnvironmentObject var goalManager: GoalManager
    @State private var showCreationSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Header with streak + XP
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(ColorTheme.accentGradient)
                    .frame(width: 3, height: 18)
                Text("DAILY GOALS")
                    .font(.system(size: 13, weight: .black))
                    .tracking(2)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Streak badge
                if goalManager.stats.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Text("🔥")
                            .font(.system(size: 12))
                        Text("\(goalManager.stats.currentStreak)")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(ColorTheme.accent)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(ColorTheme.accent.opacity(0.12))
                    .clipShape(Capsule())
                }
                
                // Level/XP badge
                HStack(spacing: 4) {
                    Text("Lv\(goalManager.stats.level)")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(ColorTheme.primary)
                    Text("·")
                        .foregroundColor(ColorTheme.textSecondary.opacity(0.5))
                    Text("\(goalManager.stats.totalXP) XP")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
            .padding(.horizontal, 20)
            
            // Horizontal scroll of goal cards
            if goalManager.dailyGoals.isEmpty {
                // Empty state — just show add button
                Button(action: { showCreationSheet = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                        Text("Set your first daily goal")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(ColorTheme.buttonGradient)
                    .padding(.vertical, 30)
                    .frame(maxWidth: .infinity)
                    .background(ColorTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ColorTheme.primary.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [6]))
                    )
                }
                .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(goalManager.dailyGoals) { goal in
                            GoalCard(goal: goal)
                        }
                        
                        // Add button at end
                        AddGoalButton { showCreationSheet = true }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
                }
            }
        }
        .sheet(isPresented: $showCreationSheet) {
            GoalCreationSheet()
        }
    }
}

// MARK: - Goal Card

struct GoalCard: View {
    
    let goal: Goal
    @EnvironmentObject var goalManager: GoalManager
    
    private var categoryColor: Color { Color(hex: goal.category.color) }
    
    var body: some View {
        VStack(spacing: 10) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(categoryColor.opacity(0.15), lineWidth: 5)
                    .frame(width: 52, height: 52)
                Circle()
                    .trim(from: 0, to: goal.progress)
                    .stroke(categoryColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(-90))
                
                if goal.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(categoryColor)
                } else {
                    Image(systemName: goal.category.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(categoryColor)
                }
            }
            
            // Title
            Text(goal.title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            // Progress text
            Text("\(Int(goal.currentValue))/\(Int(goal.targetValue)) \(goal.unit)")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(ColorTheme.textSecondary)
            
            // Quick increment button (for manual goals)
            if !goal.isCompleted && goal.category != .steps {
                Button(action: { goalManager.incrementProgress(goalId: goal.id) }) {
                    Text("+1")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(categoryColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(categoryColor.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
        }
        .frame(width: 100, height: 140)
        .padding(.vertical, 10)
        .background(ColorTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    goal.isCompleted ? categoryColor.opacity(0.4) : Color.white.opacity(0.06),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Add Goal Button

struct AddGoalButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(ColorTheme.primary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [4]))
                        .frame(width: 52, height: 52)
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(ColorTheme.primary)
                }
                Text("Add")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(ColorTheme.textSecondary)
            }
            .frame(width: 100, height: 140)
            .padding(.vertical, 10)
            .background(ColorTheme.surface.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
    }
}
