import Foundation
import SwiftData

struct BMIPoint: Identifiable {
    let id: PersistentIdentifier
    let date: Date
    let bmiValue: Double
}

struct GoalProgressData {
    let startKg: Double
    let currentKg: Double
    let goalKg: Double
    let percent: Double  // 0–100+
}

struct StatsResult {
    var avg7dWeight: Double?
    var avg6wWeight: Double?
    var avg7dBMI: Double?
    var avg6wBMI: Double?
    var rate7d: Double?       // kg/week, negative = loss
    var rate6w: Double?
    var totalChange: Double?  // currentKg − firstKg
    var projectedGoalDate: Date?
}

struct ChartsData {
    var bmiSeries: [BMIPoint]
    var goalProgress: GoalProgressData?
}
