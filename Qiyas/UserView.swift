import SwiftUI
import SwiftData

struct UserView: View {
    @Environment(\.modelContext) private var context
    @Query private var items: [Measurement]

    @AppStorage("unit") private var defaultUnit = "cm"
    @State private var showConfirmDeleteAll = false

    var body: some View {
        NavigationStack {
            List {
                Section("Defaults") {
                    Picker("Default Unit", selection: $defaultUnit) {
                        Text("cm").tag("cm")
                        Text("in").tag("in")
                    }
                    .pickerStyle(.segmented)
                }

                Section("Stats") {
                    HStack {
                        Text("Total Entries")
                        Spacer()
                        Text("\(items.count)")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showConfirmDeleteAll = true
                    } label: {
                        Label("Delete ALL Data", systemImage: "trash")
                    }
                }

                Section("About") {
                    HStack {
                        Text("App")
                        Spacer()
                        Text("Qiyas").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("User")
            .alert("Delete all entries?", isPresented: $showConfirmDeleteAll) {
                Button("Delete", role: .destructive) { deleteAll() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This cannot be undone.")
            }
        }
    }

    private func deleteAll() {
        items.forEach { context.delete($0) }
        try? context.save()
    }
}
