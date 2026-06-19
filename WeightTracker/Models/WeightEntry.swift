import SwiftData
import Foundation

@Model
final class WeightEntry {
    var date: Date
    var weightKg: Double

    init(date: Date = .now, weightKg: Double) {
        self.date = date
        self.weightKg = weightKg
    }
}
