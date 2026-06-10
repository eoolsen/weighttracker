import SwiftUI
import SwiftData

struct EntryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeightEntry.date, order: .reverse) private var entries: [WeightEntry]

    @State private var showingAddSheet = false
    @State private var selectedEntry: WeightEntry?
    @State private var entryToDelete: WeightEntry?

    private var shareText: String {
        let sorted = entries.sorted { $0.date < $1.date }
        let rows = sorted.map { "\($0.date.formatted_medium)\t\(String(format: "%.1f kg", $0.weightKg))" }
        return (["weighttracker.io — Weight Log", ""] + rows).joined(separator: "\n")
    }

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Entries Yet",
                        systemImage: "scalemass",
                        description: Text("Tap + to log your first weight.")
                    )
                } else {
                    List {
                        ForEach(entries) { entry in
                            EntryRowView(entry: entry)
                                .contentShape(Rectangle())
                                .onTapGesture { selectedEntry = entry }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        entryToDelete = entry
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("Weight Log")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ShareLink(item: shareText) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(entries.isEmpty)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                EntryFormView()
            }
            .sheet(item: $selectedEntry) { entry in
                EntryFormView(entry: entry)
            }
            .alert(
                "Delete Entry?",
                isPresented: .init(
                    get: { entryToDelete != nil },
                    set: { if !$0 { entryToDelete = nil } }
                ),
                presenting: entryToDelete
            ) { entry in
                Button("Delete", role: .destructive) {
                    modelContext.delete(entry)
                    entryToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    entryToDelete = nil
                }
            } message: { entry in
                Text("\(entry.date.formatted_medium) — \(String(format: "%.1f kg", entry.weightKg))")
            }
        }
    }
}
