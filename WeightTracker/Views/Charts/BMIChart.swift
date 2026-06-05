import SwiftUI
import Charts

struct BMIChart: View {
    let bmiSeries: [BMIPoint]
    let hasSettings: Bool

    private let categories: [(value: Double, label: String, color: Color)] = [
        (18.5, "Underweight", .blue),
        (25.0, "Normal", .green),
        (30.0, "Overweight", .orange),
    ]

    private var yDomain: ClosedRange<Double> {
        let values = bmiSeries.map(\.bmiValue)
        guard let minV = values.min(), let maxV = values.max() else { return 10...40 }
        let pad = max((maxV - minV) * 0.2, 3)
        return max(10, minV - pad)...min(60, maxV + pad)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("BMI")
                .font(.headline)

            if !hasSettings {
                Text("Enter your height in Settings to see BMI.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else if bmiSeries.isEmpty {
                Text("No data yet. Add entries in the Log tab.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                Chart {
                    ForEach(bmiSeries) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("BMI", point.bmiValue)
                        )
                        .foregroundStyle(.purple)

                        PointMark(
                            x: .value("Date", point.date),
                            y: .value("BMI", point.bmiValue)
                        )
                        .foregroundStyle(.purple)
                    }

                    ForEach(categories, id: \.value) { cat in
                        RuleMark(y: .value(cat.label, cat.value))
                            .foregroundStyle(cat.color.opacity(0.6))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    }
                }
                .chartYScale(domain: yDomain)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
                }
                .frame(height: 220)

                // Current BMI label
                if let latest = bmiSeries.last {
                    HStack {
                        Text(String(format: "Current BMI: %.1f", latest.bmiValue))
                            .font(.subheadline)
                        Text("(\(bmiCategory(latest.bmiValue)))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
