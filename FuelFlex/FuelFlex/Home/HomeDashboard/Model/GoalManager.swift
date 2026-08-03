import Foundation
import FirebaseFirestore

@MainActor
class GoalManager: ObservableObject {
    
    @Published var goals: [Goal] = []
    @Published var stats: GoalStats = GoalStats()
    @Published var isLoaded = false
    
    private let db = Firestore.firestore()
    private var userId: String?
    
    // MARK: - Computed
    
    var dailyGoals: [Goal] { goals.filter { $0.frequency == .daily && $0.isActive } }
    var weeklyGoals: [Goal] { goals.filter { $0.frequency == .weekly && $0.isActive } }
    var completedToday: Int { dailyGoals.filter(\.isCompleted).count }
    
    // MARK: - Load
    
    func load(userId: String) async {
        self.userId = userId
        do {
            let snapshot = try await goalsCollection(userId).getDocuments()
            self.goals = snapshot.documents.compactMap { try? $0.data(as: Goal.self) }
            
            let statsDoc = try await statsDocument(userId).getDocument()
            if statsDoc.exists {
                self.stats = try statsDoc.data(as: GoalStats.self)
            }
            resetDailyProgressIfNeeded()
        } catch {
            print("GoalManager load error: \(error)")
        }
        isLoaded = true
    }
    
    // MARK: - CRUD
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        save(goal)
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        guard let uid = userId else { return }
        Task { try? await goalsCollection(uid).document(goal.id).delete() }
    }
    
    func updateProgress(goalId: String, value: Double) {
        guard let idx = goals.firstIndex(where: { $0.id == goalId }) else { return }
        let wasCompleted = goals[idx].isCompleted
        goals[idx].currentValue = min(value, goals[idx].targetValue)
        
        if !wasCompleted && goals[idx].isCompleted {
            awardXP(goals[idx].xpReward)
        }
        save(goals[idx])
    }
    
    func incrementProgress(goalId: String, by amount: Double = 1) {
        guard let idx = goals.firstIndex(where: { $0.id == goalId }) else { return }
        let newValue = goals[idx].currentValue + amount
        updateProgress(goalId: goalId, value: newValue)
    }
    
    // MARK: - XP & Streaks
    
    private func awardXP(_ xp: Int) {
        stats.totalXP += xp
        stats.goalsCompletedToday += 1
        checkStreak()
        saveStats()
    }
    
    private func checkStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        if let last = stats.lastCompletedDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                stats.currentStreak += 1
            } else if diff > 1 {
                stats.currentStreak = 1
            }
        } else {
            stats.currentStreak = 1
        }
        stats.longestStreak = max(stats.longestStreak, stats.currentStreak)
        stats.lastCompletedDate = Date()
    }
    
    // MARK: - Daily Reset
    
    private func resetDailyProgressIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())
        if let last = stats.lastCompletedDate,
           Calendar.current.startOfDay(for: last) < today {
            // Reset daily goals
            for i in goals.indices where goals[i].frequency == .daily {
                goals[i].currentValue = 0
            }
            stats.goalsCompletedToday = 0
            saveAll()
        }
    }
    
    // MARK: - Auto-Track (call from external events)
    
    func onWorkoutCompleted() {
        for goal in dailyGoals where goal.category == .workout && !goal.isCompleted {
            incrementProgress(goalId: goal.id)
            break
        }
    }
    
    func updateSteps(_ steps: Int) {
        for goal in dailyGoals where goal.category == .steps && !goal.isCompleted {
            updateProgress(goalId: goal.id, value: Double(steps))
            break
        }
    }
    
    // MARK: - Firestore
    
    private func goalsCollection(_ uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("goals")
    }
    
    private func statsDocument(_ uid: String) -> DocumentReference {
        db.collection("users").document(uid).collection("goalStats").document("current")
    }
    
    private func save(_ goal: Goal) {
        guard let uid = userId else { return }
        Task {
            let data = try Firestore.Encoder().encode(goal)
            try? await goalsCollection(uid).document(goal.id).setData(data)
        }
    }
    
    private func saveStats() {
        guard let uid = userId else { return }
        Task {
            let data = try Firestore.Encoder().encode(stats)
            try? await statsDocument(uid).setData(data)
        }
    }
    
    private func saveAll() {
        goals.forEach { save($0) }
        saveStats()
    }
}
