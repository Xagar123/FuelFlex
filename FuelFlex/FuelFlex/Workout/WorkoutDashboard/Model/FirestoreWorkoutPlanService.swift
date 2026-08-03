import Foundation
import FirebaseFirestore

final class FirestoreWorkoutPlanService: WorkoutPlanService {

    private let db = Firestore.firestore()

    func savePlan(_ plan: WorkoutPlan) async throws {
        let data = try Firestore.Encoder().encode(plan)
        try await db.collection("users").document(plan.userId)
            .collection("workoutPlans").document(plan.id.uuidString)
            .setData(data)
    }

    func fetchPlan(userId: String) async throws -> WorkoutPlan? {
        let snapshot = try await db.collection("users").document(userId)
            .collection("workoutPlans")
            .order(by: "createdAt", descending: true)
            .limit(to: 1)
            .getDocuments()
        guard let doc = snapshot.documents.first else { return nil }
        return try doc.data(as: WorkoutPlan.self)
    }

    func saveWorkoutLog(_ log: WorkoutLog, userId: String) async throws {
        let data = try Firestore.Encoder().encode(log)
        try await db.collection("users").document(userId)
            .collection("workoutLogs").document(log.id.uuidString)
            .setData(data)
    }

    func fetchWorkoutLogs(userId: String) async throws -> [WorkoutLog] {
        let snapshot = try await db.collection("users").document(userId)
            .collection("workoutLogs")
            .order(by: "startTime", descending: true)
            .limit(to: 50)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: WorkoutLog.self) }
    }
}
