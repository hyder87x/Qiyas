import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Measurement.date, order: .reverse) private var items: [Measurement]

    @State private var range: RangeFilter = .all

    var body: some View {
        NavigationStack {
            VStack {
                // Filter bar
                Picker("Range", selection: $range) {
                    ForEach(RangeFilter.allCases, id: \.self) { r in
                        Text(r.title).tag(r)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 12)
                .padding(.top, 12)

                List {
                    ForEach(filtered(items)) { m in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(m.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.headline)
                                Spacer()
                                if let w = m.weight {
                                    Text("\(String(format: "%.1f", w)) kg")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Text(line1(m))
                                .font(.subheadline)
                            if hasArmsOrThighs(m) {
                                Text(line2(m))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            if let n = m.notes, !n.isEmpty {
                                Text(n).font(.footnote).foregroundStyle(.tertiary).lineLimit(2)
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("Results")
            .toolbar { EditButton() }
        }
    }

    private func filtered(_ arr: [Measurement]) -> [Measurement] {
        switch range {
        case .all: return arr
        case .d7:  return arr.filter { $0.date >= Calendar.current.date(byAdding: .day, value: -7, to: Date())! }
        case .d30: return arr.filter { $0.date >= Calendar.current.date(byAdding: .day, value: -30, to: Date())! }
        case .d90: return arr.filter { $0.date >= Calendar.current.date(byAdding: .day, value: -90, to: Date())! }
        }
    }

    private func fmt(_ v: Double?) -> String { v.map { String(format: "%.1f", $0) } ?? "-" }

    private func line1(_ m: Measurement) -> String {
        "Waist: \(fmt(m.waist)) \(m.unit) | Hips: \(fmt(m.hips)) \(m.unit) | Chest: \(fmt(m.chest)) \(m.unit)"
    }
    private func line2(_ m: Measurement) -> String {
        "R-Arm: \(fmt(m.rightArm))  L-Arm: \(fmt(m.leftArm))  R-Thigh: \(fmt(m.rightThigh))  L-Thigh: \(fmt(m.leftThigh)) \(m.unit)"
    }
    private func hasArmsOrThighs(_ m: Measurement) -> Bool {
        m.rightArm != nil || m.leftArm != nil || m.rightThigh != nil || m.leftThigh != nil
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets { context.delete(items[i]) }
        try? context.save()
    }
}

enum RangeFilter: CaseIterable {
    case all, d7, d30, d90
    var title: String {
        switch self {
        case .all: return "All"
        case .d7:  return "7d"
        case .d30: return "30d"
        case .d90: return "90d"
        }
    }
}
