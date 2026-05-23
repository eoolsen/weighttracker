import SwiftUI

struct GoalProgressView: View {
    let data: GoalProgressData?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goal Progress")
                .font(.headline)

            if let data {
                let clampedPercent = min(max(data.percent, 0), 100)

                VStack(spacing: 16) {
                    Gauge(value: clampedPercent, in: 0...100) {
                        Text("Progress")
                    } currentValueLabel: {
                        Text(String(format: "%.0f%%", clampedPercent))
                            .bold()
                    } minimumValueLabel: {
                        Text(String(format: "%.1f", data.startKg))
                            .font(.caption)
                    } maximumValueLabel: {
                        Text(String(format: "%.1f", data.goalKg))
                            .font(.caption)
                    }
                    .gaugeStyle(.accessoryLinear)
                    .tint(.green)

                    HStack {
                        statLabel("Start", value: data.startKg)
                        Spacer()
                        statLabel("Current", value: data.currentKg)
                        Spacer()
                        statLabel("Goal", value: data.goalKg)
                    }

                    let remaining = data.goalKg - data.currentKg
                    if abs(remaining) > 0.05 {
                        Text(String(format: "%+.1f kg to goal", remaining))
                            .font(.subheadline)
                            .foregroundStyle(remaining > 0 ? .blue : .orange)
                    } else {
                        Label("Goal reached!", systemImage: "star.fill")
                            .foregroundStyle(.yellow)
                    }
                }
            } else {
                Text("Set a goal weight in Settings and add entries to track progress.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 80)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func statLabel(_ title: String, value: Double) -> some View {
        VStack(spacing: 2) {
            Text(String(format: "%.1f kg", value))
                .bold()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
