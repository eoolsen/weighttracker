import SwiftData
import Foundation

@Model
final class WeightEntry {
    var id: UUID
    var date: Date
    var weightKg: Double

    init(date: Date = .now, weightKg: Double) {
        self.id = UUID()
        self.date = date
        self.weightKg = weightKg
    }
}
