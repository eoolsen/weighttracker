import SwiftUI
import SwiftData

struct StatsView: View {
    @Query(sort: \WeightEntry.date, order: .forward) private var entries: [WeightEntry]
    @Query private var settingsRecords: [UserSettings]

    @State private var viewModel = StatsViewModel()

    private var settings: UserSettings? { settingsRecords.first }

    private var shareText: String {
        var lines = ["My weight progress (weighttracker.io):"]
        let sorted = entries.sorted { $0.date < $1.date }
        if let first = sorted.first, let last = sorted.last {
            lines.append(String(format: "• Started: %.1f kg  Current: %.1f kg  Goal: %.1f kg",
                                first.weightKg, last.weightKg, settings?.goalWeightKg ?? 0))
        }
        if let change = viewModel.totalChange {
            let verb = change <= 0 ? "Lost" : "Gained"
            lines.append(String(format: "• %@ %.1f kg total", verb, abs(change)))
        }
        if let avg6w = viewModel.avg6wWeight, let avg7d = viewModel.avg7dWeight {
            lines.append(String(format: "• 6-week avg: %.1f kg  |  7-day avg: %.1f kg", avg6w, avg7d))
        }
        if let date = viewModel.projectedGoalDate {
            lines.append("• On track to reach goal by \(date.formatted_medium)")
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
        .onAppear { viewModel.update(entries: entries, settings: settings) }
        .onChange(of: entries) { viewModel.update(entries: entries, settings: settings) }
        .onChange(of: settingsRecords) { viewModel.update(entries: entries, settings: settings) }
    }

    // MARK: - Cards

    private var averagesCard: some View {
        StatCard(title: "Averages") {
            if entries.isEmpty {
                emptyHint("Add entries to see averages.")
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    statCell("7-day weight", value: viewModel.avg7dWeight.map { String(format: "%.1f kg", $0) })
                    statCell("6-week weight", value: viewModel.avg6wWeight.map { String(format: "%.1f kg", $0) })
                    statCell("7-day BMI", value: viewModel.avg7dBMI.map { String(format: "%.1f", $0) },
                             fallback: settings == nil || settings?.heightMeters == 0 ? "Set height" : "–")
                    statCell("6-week BMI", value: viewModel.avg6wBMI.map { String(format: "%.1f", $0) },
                             fallback: settings == nil || settings?.heightMeters == 0 ? "Set height" : "–")
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
                    rateRow("7-day rate", rate: viewModel.rate7d)
                    Divider()
                    rateRow("6-week rate", rate: viewModel.rate6w)
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
                    if let change = viewModel.totalChange {
                        HStack {
                            Text(change <= 0 ? "Total lost" : "Total gained")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(String(format: "%.1f kg", abs(change)))
                                .bold()
                                .foregroundStyle(change <= 0 ? .green : .orange)
                        }
                    }
                    if let date = viewModel.projectedGoalDate {
                        Divider()
                        HStack {
                            Text("Projected goal date")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(date.formatted_medium)
                                .bold()
                        }
                    } else if settings?.goalWeightKg != nil {
                        Divider()
                        HStack {
                            Text("Projected goal date")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("–")
                                .foregroundStyle(.secondary)
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
