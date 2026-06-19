import SwiftUI
import SwiftData

struct ChartsTabView: View {
    @Query(sort: \WeightEntry.date, order: .forward) private var entries: [WeightEntry]
    @Query private var settingsRecords: [UserSettings]

    private var settings: UserSettings? { settingsRecords.first }

    private var charts: ChartsData {
        Charts.compute(entries: entries, settings: settings)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    GoalProgressView(data: charts.goalProgress)

                    WeightLineChart(
                        entries: entries,
                        goalKg: settings?.goalWeightKg
                    )

                    BMIChart(
                        bmiSeries: charts.bmiSeries,
                        hasSettings: (settings?.heightMeters ?? 0) > 0
                    )
                }
                .padding()
            }
            .navigationTitle("Charts")
        }
    }
}
