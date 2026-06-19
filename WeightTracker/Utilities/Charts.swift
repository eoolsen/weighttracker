import Foundation
import SwiftData

enum Charts {
    static func compute(entries: [WeightEntry], settings: UserSettings?) -> ChartsData {
        let sorted = entries.sorted { $0.date < $1.date }

        guard let settings, settings.heightMeters > 0 else {
            return ChartsData(bmiSeries: [], goalProgress: nil)
        }

        let bmiSeries = sorted.map { entry in
            BMIPoint(
                id: entry.persistentModelID,
                date: entry.date,
                bmiValue: BMI.value(weightKg: entry.weightKg, heightMeters: settings.heightMeters)
            )
        }

        let goalProgress: GoalProgressData? = {
            guard let first = sorted.first, let last = sorted.last else { return nil }
            return GoalProgressData(
                startKg: first.weightKg,
                currentKg: last.weightKg,
                goalKg: settings.goalWeightKg,
                percent: Goal.percent(start: first.weightKg, current: last.weightKg, goal: settings.goalWeightKg)
            )
        }()

        return ChartsData(bmiSeries: bmiSeries, goalProgress: goalProgress)
    }
}
