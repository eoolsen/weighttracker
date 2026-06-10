import SwiftData
import Foundation

@Model
final class UserSettings {
    var heightMeters: Double
    var goalWeightKg: Double
    var notificationsEnabled: Bool
    var logDays: [Int]       // Calendar weekday: 1=Sun … 7=Sat
    var reminderHour: Int
    var reminderMinute: Int

    init(
        heightMeters: Double = 1.75,
        goalWeightKg: Double = 75.0,
        notificationsEnabled: Bool = false,
        logDays: [Int] = [],
        reminderHour: Int = 22,
        reminderMinute: Int = 0
    ) {
        self.heightMeters = heightMeters
        self.goalWeightKg = goalWeightKg
        self.notificationsEnabled = notificationsEnabled
        self.logDays = logDays
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
    }
}
