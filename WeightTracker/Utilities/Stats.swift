import Foundation

enum Stats {
    private static let shortWindowDays = 7
    private static let longWindowDays = 42

    // Projection guardrails: avoid wildly noisy estimates from tiny samples
    private static let projectionMinSamples = 3
    private static let projectionMinSpanDays = 14

    static func compute(
        entries: [WeightEntry],
        settings: UserSettings?,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> StatsResult {
        var result = StatsResult()
        let sorted = entries.sorted { $0.date < $1.date }

        let shortCut = calendar.date(byAdding: .day, value: -shortWindowDays, to: now) ?? now
        let longCut = calendar.date(byAdding: .day, value: -longWindowDays, to: now) ?? now

        let window7d = sorted.filter { $0.date >= shortCut }
        let window6w = sorted.filter { $0.date >= longCut }

        result.avg7dWeight = mean(window7d.map(\.weightKg))
        result.avg6wWeight = mean(window6w.map(\.weightKg))

        if let h = settings?.heightMeters, h > 0 {
            result.avg7dBMI = mean(window7d.map { BMI.value(weightKg: $0.weightKg, heightMeters: h) })
            result.avg6wBMI = mean(window6w.map { BMI.value(weightKg: $0.weightKg, heightMeters: h) })
        }

        result.rate7d = rateKgPerWeek(window7d)
        result.rate6w = rateKgPerWeek(window6w)

        if let first = sorted.first, let last = sorted.last {
            result.totalChange = last.weightKg - first.weightKg
        }

        result.projectedGoalDate = projectGoalDate(
            sorted: sorted,
            window: window6w,
            rate: result.rate6w,
            goalKg: settings?.goalWeightKg,
            now: now
        )

        return result
    }

    private static func projectGoalDate(
        sorted: [WeightEntry],
        window: [WeightEntry],
        rate: Double?,
        goalKg: Double?,
        now: Date
    ) -> Date? {
        guard let goal = goalKg,
              let current = sorted.last?.weightKg,
              let rate, abs(rate) > 0.001,
              window.count >= projectionMinSamples,
              let first = window.first, let last = window.last,
              last.date.timeIntervalSince(first.date) >= Double(projectionMinSpanDays) * 86400
        else { return nil }

        let remaining = goal - current
        // Only project when rate is moving toward the goal
        guard (remaining > 0 && rate > 0) || (remaining < 0 && rate < 0) else { return nil }

        let daysToGoal = (remaining / rate) * 7
        return now.addingTimeInterval(daysToGoal * 86400)
    }

    private static func mean(_ values: [Double]) -> Double? {
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    private static func rateKgPerWeek(_ window: [WeightEntry]) -> Double? {
        guard window.count >= 2,
              let first = window.first,
              let last = window.last else { return nil }
        let days = last.date.timeIntervalSince(first.date) / 86400
        guard days > 0 else { return nil }
        return (last.weightKg - first.weightKg) / days * 7
    }
}
