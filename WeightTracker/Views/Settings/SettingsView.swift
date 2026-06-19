import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsRecords: [UserSettings]

    @State private var heightText: String = ""
    @State private var goalText: String = ""
    @State private var saved = false
    @FocusState private var focusedField: Field?
    private enum Field { case height, goal }

    private var settings: UserSettings? { settingsRecords.first }

    var body: some View {
        NavigationStack {
            Form {
                Section("Body") {
                    HStack {
                        TextField("Height", text: $heightText)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .height)
                        Text("cm")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Goal") {
                    HStack {
                        TextField("Target weight", text: $goalText)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .goal)
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button(action: save) {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValid)

                    if saved {
                        Label("Saved", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear { loadFromSettings() }
        }
    }

    private var isValid: Bool {
        guard let h = parseDouble(heightText), let g = parseDouble(goalText) else { return false }
        return h > 0 && g > 0
    }

    private func loadFromSettings() {
        if let s = settings {
            heightText = String(format: "%.0f", s.heightMeters * 100)
            goalText = String(format: "%.1f", s.goalWeightKg)
        }
    }

    private func save() {
        focusedField = nil
        guard let hCm = parseDouble(heightText), let g = parseDouble(goalText) else { return }
        let row = UserSettings.resolved(in: modelContext)
        row.heightMeters = hCm / 100
        row.goalWeightKg = g
        saved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { saved = false }
    }

    private func parseDouble(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }
}
