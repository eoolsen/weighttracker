import SwiftUI
import SwiftData

struct ChartsTabView: View {
    @Query(sort: \WeightEntry.date, order: .forward) private var entries: [WeightEntry]
    @Query private var settingsRecords: [UserSettings]

    @State private var viewModel = ChartsViewModel()

    private var settings: UserSettings? { settingsRecords.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    GoalProgressView(data: viewModel.goalProgress)

                    WeightLineChart(
                        entries: viewModel.weightSeries,
                        goalKg: settings?.goalWeightKg
                    )

                    BMIChart(
                        bmiSeries: viewModel.bmiSeries,
                        hasSettings: settings != nil && settings!.heightMeters > 0
                    )
                }
                .padding()
            }
            .navigationTitle("Charts")
        }
        .onChange(of: entries) { update() }
        .onChange(of: settingsRecords) { update() }
        .onAppear { update() }
    }

    private func update() {
        viewModel.update(entries: entries, settings: settings)
    }
}
