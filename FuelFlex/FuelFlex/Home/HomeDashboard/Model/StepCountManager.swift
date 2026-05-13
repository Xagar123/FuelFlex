import Foundation
import HealthKit

@MainActor
class StepCountManager: ObservableObject {

    @Published var steps: Int = 0
    @Published var isAvailable: Bool = false

    private var store: HKHealthStore?

    func requestAccessAndFetch() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let store = HKHealthStore()
        self.store = store
        self.isAvailable = true

        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        store.requestAuthorization(toShare: [], read: [stepType]) { ok, _ in
            guard ok else { return }
            self.fetchTodaySteps(store: store, stepType: stepType)
        }
    }

    private func fetchTodaySteps(store: HKHealthStore, stepType: HKQuantityType) {
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let value = Int(result?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            Task { @MainActor in self.steps = value }
        }
        store.execute(query)
    }
}
