import Foundation
import Observation

@Observable
final class StatsViewModel {
    private(set) var avg7dWeight: Double?
    private(set) var avg6wWeight: Double?
    private(set) var avg7dBMI: Double?
    private(set) var avg6wBMI: Double?
    private(set) var rate7d: Double?       // kg/week, negative = loss
    private(set) var rate6w: Double?
    private(set) var totalChange: Double?  // currentKg - firstKg
    private(set) var projectedGoalDate: Date?

    func update(entries: [WeightEntry], settings: UserSettings?) {
        let sorted = entries.sorted { $0.date < $1.date }
        let now = Date.now
        let cut7d = now.addingTimeInterval(-7 * 86400)
        let cut6w = now.addingTimeInterval(-42 * 86400)

        let window7d = sorted.filter { $0.date >= cut7d }
        let window6w = sorted.filter { $0.date >= cut6w }

        avg7dWeight = mean(window7d.map(\.weightKg))
        avg6wWeight = mean(window6w.map(\.weightKg))

        if let h = settings?.heightMeters, h > 0 {
            avg7dBMI = mean(window7d.map { bmi(weightKg: $0.weightKg, heightMeters: h) })
            avg6wBMI = mean(window6w.map { bmi(weightKg: $0.weightKg, heightMeters: h) })
        } else {
            avg7dBMI = nil
            avg6wBMI = nil
        }

        rate7d = rateKgPerWeek(window7d)
        rate6w = rateKgPerWeek(window6w)

        if let first = sorted.first, let last = sorted.last {
            totalChange = last.weightKg - first.weightKg
        } else {
            totalChange = nil
        }

        if let goal = settings?.goalWeightKg,
           let current = sorted.last?.weightKg,
           let rate = rate6w,
           abs(rate) > 0.001 {
            let remaining = goal - current
            // Only project if rate is moving toward the goal
            if (remaining > 0 && rate > 0) || (remaining < 0 && rate < 0) {
                let daysToGoal = (remaining / rate) * 7
                projectedGoalDate = now.addingTimeInterval(daysToGoal * 86400)
            } else {
                projectedGoalDate = nil
            }
        } else {
            projectedGoalDate = nil
        }
    }

    private func mean(_ values: [Double]) -> Double? {
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    private func rateKgPerWeek(_ window: [WeightEntry]) -> Double? {
        guard window.count >= 2,
              let first = window.first,
              let last = window.last else { return nil }
        let days = last.date.timeIntervalSince(first.date) / 86400
        guard days > 0 else { return nil }
        return (last.weightKg - first.weightKg) / days * 7
    }
}
