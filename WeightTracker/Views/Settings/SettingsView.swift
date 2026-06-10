import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsRecords: [UserSettings]

    @State private var heightText: String = ""
    @State private var goalText: String = ""
    @State private var saved = false

    // Notification UI state
    @State private var notificationsEnabled: Bool = false
    @State private var logDays: Set<Int> = []
    @State private var reminderTime: Date = defaultReminderTime()
    @State private var notificationsDenied = false

    private var settings: UserSettings? { settingsRecords.first }

    private static func defaultReminderTime() -> Date {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        c.hour = 22; c.minute = 0
        return Calendar.current.date(from: c) ?? .now
    }

    // Abbreviated weekday labels, Sun=1 … Sat=7
    private let weekdayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Body") {
                    HStack {
                        TextField("Height", text: $heightText)
                            .keyboardType(.decimalPad)
                        Text("cm")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Goal") {
                    HStack {
                        TextField("Target weight", text: $goalText)
                            .keyboardType(.decimalPad)
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Reminders") {
                    Toggle("Weigh-in reminders", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { handleNotificationToggle() }

                    if notificationsDenied {
                        Text("Enable notifications in Settings → Notifications → weighttracker.io")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if notificationsEnabled {
                        HStack(spacing: 0) {
                            ForEach(1...7, id: \.self) { day in
                                let selected = logDays.contains(day)
                                Button {
                                    if selected { logDays.remove(day) } else { logDays.insert(day) }
                                    saveNotificationSettings()
                                } label: {
                                    Text(weekdayLabels[day - 1])
                                        .font(.subheadline.bold())
                                        .frame(maxWidth: .infinity, minHeight: 36)
                                        .background(selected ? Color.accentColor : Color.clear)
                                        .foregroundStyle(selected ? .white : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3)))

                        DatePicker("Reminder time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: reminderTime) { saveNotificationSettings() }
                    }
                }

                Section {
                    Button(action: save) {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValid)

                    if saved {
                        Label("Saved", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear { loadFromSettings() }
        }
    }

    private var isValid: Bool {
        guard let h = parseDouble(heightText), let g = parseDouble(goalText) else { return false }
        return h > 0 && g > 0
    }

    private func loadFromSettings() {
        if let s = settings {
            heightText = String(format: "%.0f", s.heightMeters * 100)
            goalText = String(format: "%.1f", s.goalWeightKg)
            notificationsEnabled = s.notificationsEnabled
            logDays = s.logDaysSet
            var c = Calendar.current.dateComponents([.year, .month, .day], from: .now)
            c.hour = s.reminderHour; c.minute = s.reminderMinute
            reminderTime = Calendar.current.date(from: c) ?? reminderTime
        }
    }

    private func save() {
        guard let hCm = parseDouble(heightText), let g = parseDouble(goalText) else { return }
        let h = hCm / 100
        if let existing = settings {
            existing.heightMeters = h
            existing.goalWeightKg = g
        } else {
            let hour = Calendar.current.component(.hour, from: reminderTime)
            let minute = Calendar.current.component(.minute, from: reminderTime)
            let newSettings = UserSettings(
                heightMeters: h,
                goalWeightKg: g,
                notificationsEnabled: notificationsEnabled,
                reminderHour: hour,
                reminderMinute: minute
            )
            newSettings.logDaysSet = logDays
            modelContext.insert(newSettings)
        }
        saved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { saved = false }
    }

    private func handleNotificationToggle() {
        guard notificationsEnabled else {
            settings?.notificationsEnabled = false
            removeAllReminders()
            return
        }
        Task {
            let granted = await requestNotificationPermission()
            await MainActor.run {
                if granted {
                    notificationsDenied = false
                    settings?.notificationsEnabled = true
                    saveNotificationSettings()
                } else {
                    notificationsEnabled = false
                    notificationsDenied = true
                }
            }
        }
    }

    private func saveNotificationSettings() {
        guard let s = settings else { return }
        s.logDaysSet = logDays
        s.reminderHour = Calendar.current.component(.hour, from: reminderTime)
        s.reminderMinute = Calendar.current.component(.minute, from: reminderTime)
        if notificationsEnabled {
            scheduleReminders(logDays: s.logDays, hour: s.reminderHour, minute: s.reminderMinute)
        }
    }

    private func parseDouble(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }
}
