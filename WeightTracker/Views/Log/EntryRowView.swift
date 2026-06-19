import SwiftUI

struct EntryRowView: View {
    let entry: WeightEntry

    var body: some View {
        HStack {
            Text(entry.date.mediumDate)
                .foregroundStyle(.secondary)
            Spacer()
            Text(entry.weightKg.kgString)
                .bold()
        }
    }
}
