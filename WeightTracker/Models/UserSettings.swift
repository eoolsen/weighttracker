import SwiftData
import Foundation

@Model
final class UserSettings {
    var heightMeters: Double
    var goalWeightKg: Double
    var notificationsEnabled: Bool
    var logDays: String      // comma-separated weekday ints, e.g. "2,5" (1=Sun … 7=Sat)
    var reminderHour: Int
    var reminderMinute: Int

    init(
        heightMeters: Double = 1.75,
        goalWeightKg: Double = 75.0,
        notificationsEnabled: Bool = false,
        logDays: String = "",
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

    var logDaysSet: Set<Int> {
        get { Set(logDays.split(separator: ",").compactMap { Int($0) }) }
        set { logDays = newValue.sorted().map(String.init).joined(separator: ",") }
    }
}
