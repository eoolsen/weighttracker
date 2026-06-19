import SwiftUI
import SwiftData

struct EntryFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let entry: WeightEntry?

    @State private var date: Date
    @State private var weightText: String
    @State private var showError = false

    @FocusState private var weightFocused: Bool

    init(entry: WeightEntry? = nil) {
        self.entry = entry
        _date = State(initialValue: entry?.date ?? .now)
        _weightText = State(initialValue: entry.map { String(format: "%.1f", $0.weightKg) } ?? "")
    }

    private var isEditing: Bool { entry != nil }
    private var hasInput: Bool { !weightText.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)

                Section {
                    HStack {
                        TextField("Weight", text: $weightText)
                            .keyboardType(.decimalPad)
                            .focused($weightFocused)
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }
                    if showError {
                        Text("Enter a valid weight (0–999 kg)")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Entry" : "Add Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save", action: save)
                        .disabled(!hasInput)
                }
            }
            .onChange(of: weightText) { _, _ in
                if showError { showError = false }
            }
        }
    }

    private func save() {
        weightFocused = false
        guard let kg = Double(weightText.replacingOccurrences(of: ",", with: ".")),
              kg > 0, kg < 1000 else {
            showError = true
            return
        }
        if let entry {
            entry.date = date
            entry.weightKg = kg
        } else {
            modelContext.insert(WeightEntry(date: date, weightKg: kg))
        }
        dismiss()
    }
}
