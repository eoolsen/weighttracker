import SwiftUI

struct EntryRowView: View {
    let entry: WeightEntry

    var body: some View {
        HStack {
            Text(entry.date.formatted_medium)
                .foregroundStyle(.secondary)
            Spacer()
            Text(String(format: "%.1f kg", entry.weightKg))
                .bold()
        }
    }
}
