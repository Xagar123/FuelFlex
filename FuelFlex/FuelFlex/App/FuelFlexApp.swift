import SwiftUI
import Firebase

@main
struct FuelFlexApp: App {

    @StateObject var viewModel = AuthViewModel()
    @StateObject var workoutPlanManager = WorkoutPlanManager()
    @StateObject var exerciseLibrary = ExerciseLibraryManager()
    @StateObject var goalManager = GoalManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(viewModel)
                .environmentObject(workoutPlanManager)
                .environmentObject(exerciseLibrary)
                .environmentObject(goalManager)
                .onChange(of: viewModel.userSession?.uid) { _, uid in
                    if let uid {
                        Task {
                            await workoutPlanManager.loadPlan(userId: uid)
                            await goalManager.load(userId: uid)
                        }
                    }
                }
                .task {
                    if let uid = viewModel.userSession?.uid {
                        await workoutPlanManager.loadPlan(userId: uid)
                        await goalManager.load(userId: uid)
                    }
                }
        }
    }
}
