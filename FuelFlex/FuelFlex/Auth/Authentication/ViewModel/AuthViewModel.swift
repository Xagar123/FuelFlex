import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: FuelFlexUser?
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    init() {
        self.userSession = Auth.auth().currentUser
        Task { await fetchUser() }
    }

    // MARK: - Auth

    func signIn(withEmail email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.userSession = result.user
        await fetchUser()
    }

    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        self.userSession = result.user

        let user = FuelFlexUser(
            id: result.user.uid,
            fullName: fullName,
            email: email,
            isOnboardingComplete: false,
            createdAt: Date()
        )
        try await saveUser(user)
        self.currentUser = user
    }

    func signOut() {
        try? Auth.auth().signOut()
        self.userSession = nil
        self.currentUser = nil
    }

    func deleteAccount() async throws {
        guard let uid = userSession?.uid else { return }
        try await db.collection("users").document(uid).delete()
        try await Auth.auth().currentUser?.delete()
        self.userSession = nil
        self.currentUser = nil
    }

    // MARK: - Firestore

    func fetchUser() async {
        guard let uid = userSession?.uid else {
            self.isLoading = false
            return
        }
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            self.currentUser = try doc.data(as: FuelFlexUser.self)
        } catch {
            print("Error fetching user: \(error)")
        }
        self.isLoading = false
    }

    func saveUser(_ user: FuelFlexUser) async throws {
        let encoded = try Firestore.Encoder().encode(user)
        let docRef = db.collection("users").document(user.id)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            docRef.setData(encoded, merge: true) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func completeOnboarding(profile: UserProfile, calories: Int, protein: Int, carbs: Int, fats: Int) async throws {
        guard let uid = userSession?.uid else { return }

        // If currentUser is nil (race condition), fetch it first
        if currentUser == nil {
            await fetchUser()
        }

        var user = currentUser ?? FuelFlexUser(
            id: uid,
            fullName: "",
            email: userSession?.email ?? "",
            isOnboardingComplete: false,
            createdAt: Date()
        )

        user.age = profile.age
        user.heightCM = profile.heightCM
        user.weightKG = profile.weightKG
        user.gender = profile.gender.rawValue
        user.goal = profile.id.rawValue
        user.fitnessLevel = profile.fitnessLevel.rawValue
        user.daysPerWeek = profile.daysPerWeek
        user.dailyCalories = calories
        user.proteinGrams = protein
        user.carbsGrams = carbs
        user.fatsGrams = fats
        user.isOnboardingComplete = true

        try await saveUser(user)
        self.currentUser = user
    }
}
