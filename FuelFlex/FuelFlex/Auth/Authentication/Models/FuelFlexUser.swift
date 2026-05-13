import Foundation

struct FuelFlexUser: Identifiable, Codable {
    let id: String
    var fullName: String
    var email: String

    // Onboarding
    var age: Int?
    var heightCM: Int?
    var weightKG: Int?
    var gender: String?
    var goal: String?
    var fitnessLevel: String?
    var daysPerWeek: Int?

    // Generated goal matrix
    var dailyCalories: Int?
    var proteinGrams: Int?
    var carbsGrams: Int?
    var fatsGrams: Int?

    var isOnboardingComplete: Bool
    var createdAt: Date

    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}
