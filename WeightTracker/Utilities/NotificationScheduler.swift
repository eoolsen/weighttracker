import UserNotifications
import Foundation

private let idPrefix = "weigh-in-"

func requestNotificationPermission() async -> Bool {
    let center = UNUserNotificationCenter.current()
    let settings = await center.notificationSettings()
    switch settings.authorizationStatus {
    case .authorized, .provisional: return true
    case .denied: return false
    default:
        return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }
}

func scheduleReminders(logDays: [Int], hour: Int, minute: Int) {
    let center = UNUserNotificationCenter.current()
    // Remove all existing weigh-in reminders before rescheduling
    center.getPendingNotificationRequests { pending in
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(idPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: ids)

        let content = UNMutableNotificationContent()
        content.title = "Time to weigh in"
        content.body = "Log your weight in weighttracker.io"
        content.sound = .default

        for weekday in logDays {
            var components = DateComponents()
            components.weekday = weekday
            components.hour = hour
            components.minute = minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: "\(idPrefix)\(weekday)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }
}

func cancelTodayReminder() {
    let weekday = Calendar.current.component(.weekday, from: .now)
    UNUserNotificationCenter.current()
        .removePendingNotificationRequests(withIdentifiers: ["\(idPrefix)\(weekday)"])
}

func removeAllReminders() {
    let center = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests { pending in
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(idPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
}
