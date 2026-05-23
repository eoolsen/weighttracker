import SwiftData
import Foundation

@Model
final class UserSettings {
    var heightMeters: Double
    var goalWeightKg: Double

    init(heightMeters: Double = 1.75, goalWeightKg: Double = 75.0) {
        self.heightMeters = heightMeters
        self.goalWeightKg = goalWeightKg
    }
}
