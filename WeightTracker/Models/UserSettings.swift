import SwiftData
import Foundation

@Model
final class UserSettings {
    var heightMeters: Double
    var goalWeightKg: Double

    init(
        heightMeters: Double = 1.75,
        goalWeightKg: Double = 75.0
    ) {
        self.heightMeters = heightMeters
        self.goalWeightKg = goalWeightKg
    }

    /// Returns the singleton settings row, creating one if missing.
    /// All callers should go through this rather than `@Query` + `.first`.
    static func resolved(in context: ModelContext) -> UserSettings {
        let descriptor = FetchDescriptor<UserSettings>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let new = UserSettings()
        context.insert(new)
        return new
    }
}
