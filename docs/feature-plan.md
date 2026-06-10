# Plan: Stats Tab + Sharing + Log-day Reminders

## Context
App Store review was rejected. Adding a Stats tab with rolling averages and trend insights, sharing capabilities, and optional push notification reminders on user-configured weigh-in days.

---

## New Tab: Stats
Position: **Log → Stats → Charts → Settings** (second tab).

### StatsViewModel (`ViewModels/StatsViewModel.swift`)
New `@Observable` class, same pattern as `ChartsViewModel`. Accepts `([WeightEntry], UserSettings?)` via an `update()` method and computes:

- **7-day avg weight** — mean of entries with `date >= now - 7 days`
- **6-week avg weight** — mean of entries with `date >= now - 42 days`
- **7-day avg BMI** — same windows, reuses `bmi()` from `Utilities/Calculations.swift`
- **6-week avg BMI** — same
- **Rate of change** — kg/week for each window: `(lastEntry - firstEntry) / days * 7`; nil if fewer than 2 entries
- **Total change** — `currentKg - firstEntry.weightKg` (signed; "lost X kg" / "gained X kg")
- **Projected goal date** — uses 6-week rate: `daysToGoal = (goalKg - currentKg) / (ratePerWeek / 7)` → `Date.now + daysToGoal`; nil if rate is zero, wrong direction, or no goal set

### StatsView (`Views/Stats/StatsView.swift`)
`NavigationStack` + `ScrollView` of material cards (same `RoundedRectangle(cornerRadius: 16)` + `.regularMaterial` as existing chart cards). Three cards:
1. **Averages** — 2×2 grid: 7-day weight, 6-week weight, 7-day BMI, 6-week BMI
2. **Trend** — rate of change for both windows ("−0.4 kg/wk over 7 days")
3. **Overall** — total change from first entry + projected goal date

Wiring: `@Query` for entries and settings (same as `ChartsTabView`), `@State private var viewModel = StatsViewModel()`, `onAppear`/`onChange` calls `viewModel.update()`.

### ContentView change
```swift
StatsView().tabItem { Label("Stats", systemImage: "chart.bar.xaxis") }
```

---

## Sharing

### Share Log (EntryListView toolbar)
Second `ToolbarItem` (share icon). Builds plain text:
```
weighttracker.io — Weight Log
Jun 1, 2026    82.5 kg
Jun 4, 2026    82.1 kg
```
Wrapped in `ShareLink(item: logText)`.

### Share Progress (StatsView toolbar)
`ShareLink` in Stats nav bar. Summary text:
```
My weight progress (weighttracker.io):
• Started: 85.0 kg  Current: 82.5 kg  Goal: 78.0 kg
• Lost 2.5 kg total
• 6-week avg: 83.1 kg  |  7-day avg: 82.3 kg
• On track to reach goal by Aug 14, 2026
```

Both use plain `String` — iOS share sheet handles Mail, Messages, copy, etc. natively.

---

## Log-day Reminders (Push Notifications)

### UserSettings model additions
Four new stored properties (SwiftData handles `[Int]` arrays natively):
- `notificationsEnabled: Bool = false`
- `logDays: [Int] = []` — weekday numbers using `Calendar` convention (1=Sun, 2=Mon … 7=Sat)
- `reminderHour: Int = 20` — stored as hour int to avoid timezone drift
- `reminderMinute: Int = 0`

### NotificationScheduler (`Utilities/NotificationScheduler.swift`)
Free-function module wrapping `UNUserNotificationCenter`:

- `requestPermission() async -> Bool` — calls `requestAuthorization(options: [.alert, .sound])`
- `scheduleReminders(logDays: [Int], hour: Int, minute: Int)` — removes all pending reminders with identifier prefix `"weigh-in-"`, then schedules one weekly `UNCalendarNotificationTrigger` per log day (body: "Time to log your weight!")
- `cancelTodayReminder()` — removes the pending notification for the current weekday (called after a new entry is saved)

### SettingsView additions
New **Reminders** section below the existing Goal section:
- `Toggle("Weigh-in reminders", isOn: ...)` — on toggle-on, calls `requestPermission()`; if denied shows a brief "Enable in Settings → Notifications" message
- When enabled: multi-select day picker (abbreviated day names, tap to toggle highlight) and a `DatePicker(.hourAndMinute)` for reminder time
- Changes immediately call `scheduleReminders(...)` to keep notifications in sync

### EntryFormView change
After `modelContext.insert(newEntry)` / saving edits, call `NotificationScheduler.cancelTodayReminder()` so the reminder doesn't fire if the user already logged today.

---

## Files to Create
- `WeightTracker/ViewModels/StatsViewModel.swift`
- `WeightTracker/Views/Stats/StatsView.swift`
- `WeightTracker/Utilities/NotificationScheduler.swift`

## Files to Modify
- `WeightTracker/Models/UserSettings.swift` — add 4 notification properties
- `WeightTracker/Views/Settings/SettingsView.swift` — add Reminders section
- `WeightTracker/Views/Log/EntryListView.swift` — add share toolbar button
- `WeightTracker/Views/Log/EntryFormView.swift` — cancel today's reminder on save
- `WeightTracker/ContentView.swift` — add Stats tab

## Reuse
- `bmi(weightKg:heightMeters:)` — `Utilities/Calculations.swift`
- `Date.formatted_medium` — `Utilities/DateHelpers.swift`
- Card style — match `WeightLineChart`/`BMIChart` padding + `.regularMaterial` background

---

## Verification
1. Build and run on simulator (iOS 17+)
2. Stats tab: add entries across >42 days — confirm all averages, rates, and projected date update correctly
3. Stats tab: no entries → empty-state text, no crashes; no height set → BMI rows show "Set height in Settings"
4. Share log: tap button → share sheet with correctly formatted entry list
5. Share progress: tap button → share sheet with summary including goal/rate/projected date
6. Reminders: enable in Settings, pick Mon+Thu, set time → verify `UNUserNotificationCenter.pendingNotificationRequests()` contains 2 requests
7. Save a new entry → confirm today's notification is cancelled from pending list
8. Deny notification permission → Settings shows inline prompt to enable in iOS Settings
