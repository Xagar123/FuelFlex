import Foundation

protocol WorkoutPlanService {
    func savePlan(_ plan: WorkoutPlan) async throws
    func fetchPlan(userId: String) async throws -> WorkoutPlan?
    func saveWorkoutLog(_ log: WorkoutLog, userId: String) async throws
    func fetchWorkoutLogs(userId: String) async throws -> [WorkoutLog]
}
