import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                SplashScreenView(showSplash: .constant(true))
            } else if viewModel.userSession == nil {
                GetStartedView()
            } else if viewModel.currentUser?.isOnboardingComplete != true {
                NavigationStack {
                    GoalSelectionView()
                }
            } else {
                NavigationStack {
                    MainTabView()
                        .preferredColorScheme(.dark)
                }
            }
        }
    }
}
