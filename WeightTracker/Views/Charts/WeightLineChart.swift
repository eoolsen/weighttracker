import SwiftUI
import Charts

struct WeightLineChart: View {
    let entries: [WeightEntry]
    let goalKg: Double?

    private var yDomain: ClosedRange<Double> {
        let weights = entries.map(\.weightKg)
        guard let minW = weights.min(), let maxW = weights.max() else { return 50...100 }
        let pad = max((maxW - minW) * 0.2, 5)
        var lo = minW - pad
        var hi = maxW + pad
        if let g = goalKg {
            lo = min(lo, g - pad)
            hi = max(hi, g + pad)
        }
        return lo...hi
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weight Over Time")
                .font(.headline)

            if entries.isEmpty {
                emptyState
            } else {
                Chart {
                    ForEach(entries) { entry in
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weightKg)
                        )
                        .foregroundStyle(.blue)

                        PointMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weightKg)
                        )
                        .foregroundStyle(.blue)
                    }

                    if let goal = goalKg {
                        RuleMark(y: .value("Goal", goal))
                            .foregroundStyle(.green)
                            .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [6]))
                    }
                }
                .chartYScale(domain: yDomain)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
                }
                .frame(height: 220)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var emptyState: some View {
        Text("No data yet. Add entries in the Log tab.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 80)
    }
}
