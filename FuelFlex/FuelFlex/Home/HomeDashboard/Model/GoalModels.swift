import Foundation

// MARK: - Goal Frequency

enum GoalFrequency: String, Codable, CaseIterable {
    case daily, weekly
    
    var label: String { rawValue.capitalized }
}

// MARK: - Goal Category

enum GoalCategory: String, Codable, CaseIterable {
    case workout, nutrition, hydration, steps, sleep, custom
    
    var icon: String {
        switch self {
        case .workout:   return "dumbbell.fill"
        case .nutrition: return "fork.knife"
        case .hydration: return "drop.fill"
        case .steps:     return "figure.walk"
        case .sleep:     return "moon.zzz.fill"
        case .custom:    return "star.fill"
        }
    }
    
    var color: String {
        switch self {
        case .workout:   return "#00FF7F"
        case .nutrition: return "#FF6B00"
        case .hydration: return "#00CFFF"
        case .steps:     return "#FFD700"
        case .sleep:     return "#A855F7"
        case .custom:    return "#FF6B00"
        }
    }
}

// MARK: - Goal

struct Goal: Identifiable, Codable {
    let id: String
    var title: String
    var category: GoalCategory
    var frequency: GoalFrequency
    var targetValue: Double
    var currentValue: Double
    var unit: String
    var xpReward: Int
    var createdAt: Date
    var isActive: Bool
    
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }
    
    var isCompleted: Bool { progress >= 1.0 }
    
    init(title: String, category: GoalCategory, frequency: GoalFrequency,
         targetValue: Double, unit: String, xpReward: Int = 10) {
        self.id = UUID().uuidString
        self.title = title
        self.category = category
        self.frequency = frequency
        self.targetValue = targetValue
        self.currentValue = 0
        self.unit = unit
        self.xpReward = xpReward
        self.createdAt = Date()
        self.isActive = true
    }
}

// MARK: - User Goal Stats (persisted alongside goals)

struct GoalStats: Codable {
    var totalXP: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastCompletedDate: Date?
    var goalsCompletedToday: Int = 0
    
    var level: Int { totalXP / 100 + 1 }
    var xpInCurrentLevel: Int { totalXP % 100 }
    
    var levelTitle: String {
        switch level {
        case 1...2:  return "Rookie"
        case 3...5:  return "Hustler"
        case 6...9:  return "Warrior"
        case 10...14: return "Beast"
        default:     return "Legend"
        }
    }
}
