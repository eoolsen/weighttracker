import Foundation
import Observation

struct BMIPoint: Identifiable {
    let id = UUID()
    let date: Date
    let bmiValue: Double
}

struct GoalProgressData {
    let startKg: Double
    let currentKg: Double
    let goalKg: Double
    let percent: Double  // 0–100+
}

@Observable
final class ChartsViewModel {
    // Call update() whenever entries or settings change
    private(set) var weightSeries: [WeightEntry] = []
    private(set) var bmiSeries: [BMIPoint] = []
    private(set) var goalProgress: GoalProgressData?

    func update(entries: [WeightEntry], settings: UserSettings?) {
        // Sort ascending for charts
        let sorted = entries.sorted { $0.date < $1.date }
        weightSeries = sorted

        guard let settings, settings.heightMeters > 0 else {
            bmiSeries = []
            goalProgress = nil
            return
        }

        bmiSeries = sorted.map { entry in
            BMIPoint(date: entry.date, bmiValue: bmi(weightKg: entry.weightKg, heightMeters: settings.heightMeters))
        }

        if let first = sorted.first, let last = sorted.last {
            let pct = goalPercent(startKg: first.weightKg, currentKg: last.weightKg, goalKg: settings.goalWeightKg)
            goalProgress = GoalProgressData(
                startKg: first.weightKg,
                currentKg: last.weightKg,
                goalKg: settings.goalWeightKg,
                percent: pct
            )
        } else {
            goalProgress = nil
        }
    }
}
