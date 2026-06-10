# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is a pure Xcode project — no package manager, no external dependencies.

- **Run in simulator:** Open `WeightTracker.xcodeproj`, select a simulator, press `Cmd+R`
- **Build only:** `Cmd+B`
- **Archive for App Store:** Set destination to "Any iOS Device (arm64)", then Product → Archive

There are no test targets and no lint configuration.

**Key build settings:**
- Swift 5.0, iOS 17.0 deployment target, iPhone only
- Bundle ID: `com.erikolsen.WeightTracker`

## Architecture

SwiftUI + SwiftData app with four tabs (Log, Stats, Charts, Settings). All data is stored locally on device — no networking.

### Data layer

Two `@Model` classes persisted by SwiftData, registered in `WeightTrackerApp.swift`:

- `WeightEntry` — a single weight measurement: `id`, `date`, `weightKg`
- `UserSettings` — singleton-pattern record (always use `.first`): `heightMeters`, `goalWeightKg`, `notificationsEnabled`, `logDays` (String), `reminderHour`, `reminderMinute`

All weights are stored and displayed in **kg**. Height is stored internally in **meters** but entered and displayed in **cm**. `logDays` is stored as a comma-separated string (e.g. `"2,5"`) — use the `logDaysSet: Set<Int>` computed property to read/write it. **Never use `[Int]` or any other collection type as a SwiftData model property** — it breaks automatic schema migration.

### View layer

```
ContentView (TabView)
├── EntryListView        — @Query-driven list, reverse-sorted by date; toolbar has + and share log
│   ├── EntryRowView     — pure display row
│   └── EntryFormView    — add/edit sheet; nil entry = add, non-nil = edit
├── StatsView            — owns StatsViewModel (@State), calls update() on appear/change; toolbar has share progress
├── ChartsTabView        — owns ChartsViewModel (@State), calls update() on appear/change
│   ├── GoalProgressView — linear gauge from start→goal using GoalProgressData
│   ├── WeightLineChart  — Swift Charts line+point, optional goal RuleMark
│   └── BMIChart         — Swift Charts line+point, dashed category RuleMarks
└── SettingsView         — reads/writes the single UserSettings record; includes Reminders section
```

### ViewModels

Both follow the same pattern — `@Observable` class, `update(entries:settings:)` method, driven by `onAppear`/`onChange` in the owning view:

- `ChartsViewModel` — produces `weightSeries`, `bmiSeries`, `goalProgress`
- `StatsViewModel` — produces 7-day and 6-week rolling averages for weight and BMI, kg/week rate of change for each window, total change from first entry, and projected goal date

### Utilities

- `Calculations.swift` — free functions: `bmi`, `bmiCategory`, `goalPercent`
- `DateHelpers.swift` — `Date.formatted_medium` extension
- `NotificationScheduler.swift` — free functions wrapping `UNUserNotificationCenter`: `requestNotificationPermission()`, `scheduleReminders(logDays:hour:minute:)`, `cancelTodayReminder()`, `removeAllReminders()`. `EntryFormView` calls `cancelTodayReminder()` on every save so the reminder doesn't fire on a day the user already logged.

## App Store

- **App name:** weighttracker.io
- **Privacy policy:** `docs/privacy-policy/index.html` (hosted on GitHub Pages)
- **Screenshots:** 6.9" display, 1320×2868 px, captured on iPhone 16/17 Pro Max simulator
- Submission checklist and archive/upload steps are in `docs/app-store-submission.md`
