import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \BodyEntry.date, order: .reverse, animation: .default)
    private var items: [BodyEntry]

    // آخر 7 سجلات
    private var last7: [BodyEntry] {
        Array(items.prefix(7))
    }

    var body: some View {
        NavigationStack {
            List {
                if items.isEmpty {
                    Section {
                        Text("No entries yet.")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Section("Last 7 entries") {
                        ForEach(last7, id: \.persistentModelID) { e in
                            NavigationLink {
                                EditEntryView(entry: e)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(e.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.headline)

                                        HStack(spacing: 14) {
                                            if let w = e.weight {
                                                Label(String(format: "%.1f kg", w), systemImage: "scalemass")
                                            }
                                            if let wst = e.waist {
                                                Label("\(formatOne(wst)) \(e.unit)", systemImage: "ruler")
                                            }
                                            if let n = e.neck {
                                                Label("\(formatOne(n)) \(e.unit)", systemImage: "person.crop.circle.badge")
                                            }
                                        }
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.tertiary)
                                }
                                .contentShape(Rectangle())
                            }
                        }
                    }

                    Section("All") {
                        ForEach(items, id: \.persistentModelID) { e in
                            HStack {
                                Text(e.date.formatted(date: .abbreviated, time: .omitted))
                                Spacer()
                                if let w = e.weight {
                                    Text(String(format: "%.1f kg", w))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Results")
        }
    }

    // MARK: - Helpers
    private func formatOne(_ v: Double) -> String {
        String(format: "%.1f", v)
    }
}

