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

SwiftUI + SwiftData app with three tabs (Log, Charts, Settings). All data is stored locally on device — no networking.

### Data layer

Two `@Model` classes persisted by SwiftData, registered in `WeightTrackerApp.swift`:

- `WeightEntry` — a single weight measurement: `id`, `date`, `weightKg`
- `UserSettings` — singleton-pattern record (always use `.first`): `heightMeters`, `goalWeightKg`

All weights are stored and displayed in **kg**. Height is stored in **meters**.

### View layer

```
ContentView (TabView)
├── EntryListView        — @Query-driven list, reverse-sorted by date
│   ├── EntryRowView     — pure display row
│   └── EntryFormView    — add/edit sheet; nil entry = add, non-nil = edit
├── ChartsTabView        — owns ChartsViewModel (@State), calls update() on appear/change
│   ├── GoalProgressView — linear gauge from start→goal using GoalProgressData
│   ├── WeightLineChart  — Swift Charts line+point, optional goal RuleMark
│   └── BMIChart         — Swift Charts line+point, dashed category RuleMarks
└── SettingsView         — reads/writes the single UserSettings record
```

### ViewModel

`ChartsViewModel` (`@Observable`) is a pure transformation layer — it takes `[WeightEntry]` and `UserSettings?` and produces `weightSeries`, `bmiSeries`, and `goalProgress`. `ChartsTabView` drives it by calling `update()` in `onAppear` and `onChange`.

### Utilities

Free functions in `Calculations.swift` (`bmi`, `bmiCategory`, `goalPercent`) and a `Date.formatted_medium` extension in `DateHelpers.swift`. These have no SwiftUI or SwiftData dependencies and are straightforward to unit test if a test target is ever added.

## App Store

- **App name:** weighttracker.io
- **Privacy policy:** `docs/privacy-policy/index.html` (hosted on GitHub Pages)
- **Screenshots:** 6.9" display, 1320×2868 px, captured on iPhone 16/17 Pro Max simulator
- Submission checklist and archive/upload steps are in `docs/app-store-submission.md`
