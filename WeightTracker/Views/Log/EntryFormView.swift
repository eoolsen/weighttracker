import SwiftUI
import SwiftData

struct EntryFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Pass an existing entry to edit it; nil means "add new"
    var entry: WeightEntry?

    @State private var date: Date = .now
    @State private var weightText: String = ""
    @State private var showError = false

    @FocusState private var weightFocused: Bool

    var isEditing: Bool { entry != nil }

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

                Section {
                    Button(action: save) {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(weightText.trimmingCharacters(in: .whitespaces).isEmpty)

                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            .navigationTitle(isEditing ? "Edit Entry" : "Add Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") { weightFocused = false }
                }
            }
            .onAppear {
                if let entry {
                    date = entry.date
                    weightText = String(format: "%.1f", entry.weightKg)
                }
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
            let newEntry = WeightEntry(date: date, weightKg: kg)
            modelContext.insert(newEntry)
        }
        dismiss()
    }
}
