import SwiftUI
import SwiftData

struct StatsView: View {
    @Query(sort: \WeightEntry.date, order: .forward) private var entries: [WeightEntry]
    @Query private var settingsRecords: [UserSettings]

    private var settings: UserSettings? { settingsRecords.first }

    private var stats: StatsResult {
        Stats.compute(entries: entries, settings: settings)
    }

    private var shareText: String {
        var lines = ["My weight progress (weighttracker.io):"]
        let sorted = entries.sorted { $0.date < $1.date }
        if let first = sorted.first, let last = sorted.last {
            let goal = (settings?.goalWeightKg ?? 0.0).kgString
            lines.append("• Started: \(first.weightKg.kgString)  Current: \(last.weightKg.kgString)  Goal: \(goal)")
        }
        if let change = stats.totalChange {
            let verb = change <= 0 ? "Lost" : "Gained"
            lines.append("• \(verb) \(abs(change).kgString) total")
        }
        if let avg6w = stats.avg6wWeight, let avg7d = stats.avg7dWeight {
            lines.append("• 6-week avg: \(avg6w.kgString)  |  7-day avg: \(avg7d.kgString)")
        }
        if let date = stats.projectedGoalDate {
            lines.append("• On track to reach goal by \(date.mediumDate)")
        }
        return lines.joined(separator: "\n")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    averagesCard
                    trendCard
                    overallCard
                }
                .padding()
            }
            .navigationTitle("Stats")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: shareText) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(entries.isEmpty)
                }
            }
        }
    }

    // MARK: - Cards

    private var averagesCard: some View {
        StatCard(title: "Averages") {
            if entries.isEmpty {
                emptyHint("Add entries to see averages.")
            } else {
                let heightUnset = (settings?.heightMeters ?? 0) <= 0
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    statCell("7-day weight", value: stats.avg7dWeight?.kgString)
                    statCell("6-week weight", value: stats.avg6wWeight?.kgString)
                    statCell("7-day BMI", value: stats.avg7dBMI.map { String(format: "%.1f", $0) },
                             fallback: heightUnset ? "Set height" : "–")
                    statCell("6-week BMI", value: stats.avg6wBMI.map { String(format: "%.1f", $0) },
                             fallback: heightUnset ? "Set height" : "–")
                }
            }
        }
    }

    private var trendCard: some View {
        StatCard(title: "Trend") {
            if entries.isEmpty {
                emptyHint("Add entries to see trends.")
            } else {
                VStack(spacing: 10) {
                    rateRow("7-day rate", rate: stats.rate7d)
                    Divider()
                    rateRow("6-week rate", rate: stats.rate6w)
                }
            }
        }
    }

    private var overallCard: some View {
        StatCard(title: "Overall") {
            if entries.isEmpty {
                emptyHint("Add entries to see overall progress.")
            } else {
                VStack(spacing: 10) {
                    if let change = stats.totalChange {
                        HStack {
                            Text(change <= 0 ? "Total lost" : "Total gained")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(abs(change).kgString)
                                .bold()
                                .foregroundStyle(change <= 0 ? .green : .orange)
                        }
                    }
                    if settings != nil {
                        Divider()
                        HStack {
                            Text("Projected goal date")
                                .foregroundStyle(.secondary)
                            Spacer()
                            if let date = stats.projectedGoalDate {
                                Text(date.mediumDate).bold()
                            } else {
                                Text("–").foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func statCell(_ label: String, value: String?, fallback: String = "–") -> some View {
        VStack(spacing: 4) {
            Text(value ?? fallback)
                .font(.title3)
                .bold()
                .foregroundStyle(value == nil ? .secondary : .primary)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func rateRow(_ label: String, rate: Double?) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            if let rate {
                let sign = rate < 0 ? "" : "+"
                Text(String(format: "%@%.2f kg/wk", sign, rate))
                    .bold()
                    .foregroundStyle(rate < 0 ? .green : .orange)
            } else {
                Text("Not enough data")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func emptyHint(_ message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 60)
    }
}

// MARK: - Shared card container

private struct StatCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
