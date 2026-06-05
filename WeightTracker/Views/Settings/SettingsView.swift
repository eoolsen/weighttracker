import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsRecords: [UserSettings]

    @State private var heightText: String = ""
    @State private var goalText: String = ""
    @State private var saved = false

    private var settings: UserSettings? { settingsRecords.first }

    var body: some View {
        NavigationStack {
            Form {
                Section("Body") {
                    HStack {
                        TextField("Height", text: $heightText)
                            .keyboardType(.decimalPad)
                        Text("m")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Goal") {
                    HStack {
                        TextField("Target weight", text: $goalText)
                            .keyboardType(.decimalPad)
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
            heightText = String(format: "%.2f", s.heightMeters)
            goalText = String(format: "%.1f", s.goalWeightKg)
        }
    }

    private func save() {
        guard let h = parseDouble(heightText), let g = parseDouble(goalText) else { return }
        if let existing = settings {
            existing.heightMeters = h
            existing.goalWeightKg = g
        } else {
            modelContext.insert(UserSettings(heightMeters: h, goalWeightKg: g))
        }
        saved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { saved = false }
    }

    private func parseDouble(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }
}
