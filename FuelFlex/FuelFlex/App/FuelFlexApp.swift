import SwiftUI
import Firebase

@main
struct FuelFlexApp: App {

    @StateObject var viewModel = AuthViewModel()
    @StateObject var workoutPlanManager = WorkoutPlanManager()
    @StateObject var exerciseLibrary = ExerciseLibraryManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(viewModel)
                .environmentObject(workoutPlanManager)
                .environmentObject(exerciseLibrary)
        }
    }
}
