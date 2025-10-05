import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Measurement.date, order: .reverse) private var rows: [Measurement]

    private let dateFmt: DateFormatter = {
        let d = DateFormatter()
        d.dateStyle = .medium
        d.timeStyle = .none
        return d
    }()

    private let numFmt: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 1
        return f
    }()

    private let columns: [(abbr: String, key: KeyPath<Measurement, Double?>)] = [
        ("Wt", \.weight),
        ("Ch", \.chest),
        ("Hp", \.hips),
        ("Ws", \.waist),
        ("LA", \.leftArm),
        ("RA", \.rightArm),
        ("LT", \.leftThigh),
        ("RT", \.rightThigh)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if rows.isEmpty {
                    ContentUnavailableView("No Data", systemImage: "table",
                        description: Text("Add entries to see your history here."))
                } else {
                    ScrollView(.horizontal) {
                        VStack(spacing: 0) {
                            headerRow().background(.ultraThinMaterial)
                            Divider()

                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(rows) { m in
                                        NavigationLink {
                                            EditEntryView(entry: m)
                                        } label: {
                                            tableRow(m)
                                                .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Results")
        }
    }

    private func headerRow() -> some View {
        HStack(spacing: 0) {
            cell(title: "Date", isHeader: true, width: 150, alignment: .leading)
            ForEach(columns, id: \.abbr) { col in
                cell(title: col.abbr, isHeader: true)
            }
        }
        .overlay(Rectangle().frame(height: 0.5).foregroundColor(.separator), alignment: .bottom)
    }

    private func tableRow(_ m: Measurement) -> some View {
        HStack(spacing: 0) {
            cell(title: dateFmt.string(from: m.date),
                 isHeader: false, width: 150, alignment: .leading)
            ForEach(columns, id: \.abbr) { col in
                let v = m[keyPath: col.key]
                cell(title: formatted(v), isHeader: false)
            }
        }
        .padding(.vertical, 2)
    }

    private func cell(title: String,
                      isHeader: Bool,
                      width: CGFloat = 72,
                      alignment: Alignment = .trailing) -> some View {
        Text(title)
            .font(isHeader ? .subheadline.weight(.semibold) : .subheadline)
            .foregroundColor(isHeader ? .primary : .secondary)
            .frame(width: width, alignment: alignment)
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
    }

    private func formatted(_ value: Double?) -> String {
        guard let value = value else { return "–" }
        return numFmt.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

private extension Color {
    static var separator: Color { Color(UIColor.separator) }
}

