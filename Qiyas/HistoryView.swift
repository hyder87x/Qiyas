import SwiftUI
import SwiftData

// MARK: - Results screen (cards per metric)
struct HistoryView: View {
    @Query(sort: \Measurement.date, order: .reverse, animation: .default)
    private var items: [Measurement]

    @State private var selectedMetric: ResultsMetric?
    @State private var showLast7 = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(ResultsMetric.allCases) { metric in
                        ResultsMetricCard(metric: metric, items: items) {
                            selectedMetric = metric
                            showLast7 = true
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Results")
            .sheet(isPresented: $showLast7) {
                if let metric = selectedMetric {
                    ResultsLast7Sheet(metric: metric, items: items)
                }
            }
        }
    }
}

// MARK: - Metric model
struct ResultsMetric: Identifiable {
    let id: String
    let title: String
    /// Unit label for a given entry (e.g. "kg" or entry.unit)
    let unitFor: (Measurement) -> String
    /// Extract numeric value from Measurement
    let getter: (Measurement) -> Double?

    static func == (lhs: ResultsMetric, rhs: ResultsMetric) -> Bool { lhs.id == rhs.id }
}
extension ResultsMetric: Equatable {}
extension ResultsMetric: Hashable { func hash(into h: inout Hasher) { h.combine(id) } }

extension ResultsMetric {
    static let allCases: [ResultsMetric] = [
        .init(id: "weight",   title: "WEIGHT",        unitFor: { _ in "kg" }, getter: { $0.weight }),
        .init(id: "waist",    title: "WAIST",         unitFor: { $0.unit },   getter: { $0.waist }),
        .init(id: "hips",     title: "HIPS",          unitFor: { $0.unit },   getter: { $0.hips }),
        .init(id: "chest",    title: "CHEST",         unitFor: { $0.unit },   getter: { $0.chest }),
        .init(id: "neck",     title: "NECK",          unitFor: { $0.unit },   getter: { $0.neck }),
        .init(id: "rArm",     title: "RIGHT ARM",     unitFor: { $0.unit },   getter: { $0.rightArm }),
        .init(id: "lArm",     title: "LEFT ARM",      unitFor: { $0.unit },   getter: { $0.leftArm }),
        .init(id: "rThigh",   title: "RIGHT THIGH",   unitFor: { $0.unit },   getter: { $0.rightThigh }),
        .init(id: "lThigh",   title: "LEFT THIGH",    unitFor: { $0.unit },   getter: { $0.leftThigh }),
    ]
}

// MARK: - Card
private struct ResultsMetricCard: View {
    let metric: ResultsMetric
    let items: [Measurement]
    var onTap: () -> Void

    private var latest: (val: Double, unit: String, date: Date)? {
        guard let first = items.first(where: { metric.getter($0) != nil }),
              let v = metric.getter(first) else { return nil }
        return (v, metric.unitFor(first), first.date)
    }

    private var delta7: Double? {
        guard let latest = latest else { return nil }
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: latest.date)!
        // أقرب قيمة قبل/على تاريخ القطع
        if let older = items.first(where: { $0.date <= cutoff && metric.getter($0) != nil }),
           let vOld = metric.getter(older) {
            return latest.val - vOld
        }
        return nil
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                Text(metric.title)
                    .font(.headline)

                HStack(spacing: 10) {
                    if let latest {
                        Text(formatted(latest.val))
                            .font(.title2).bold()
                        Text(latest.unit)
                            .foregroundStyle(.secondary)

                        Spacer()

                        if let d = delta7 {
                            let sign = signed(d)
                            Text(sign)
                                .font(.subheadline).bold()
                                .foregroundStyle(d < 0 ? .green : (d > 0 ? .red : .secondary))
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(
                                    Capsule().fill((d < 0 ? Color.green.opacity(0.12) :
                                                    d > 0 ? Color.red.opacity(0.12) :
                                                    Color.secondary.opacity(0.12)))
                                )
                        }
                    } else {
                        Text("—")
                            .font(.title2).bold()
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Last 7 sheet (+ All)
private struct ResultsLast7Sheet: View {
    let metric: ResultsMetric
    let items: [Measurement]

    @State private var showAll = false
    @Environment(\.dismiss) private var dismiss

    private var recent7: [(d: Date, v: Double, u: String)] {
        items.compactMap { m in
            guard let v = metric.getter(m) else { return nil }
            return (m.date, v, metric.unitFor(m))
        }
        .prefix(7)
        .map { $0 }
    }

    private var allValues: [(d: Date, v: Double, u: String)] {
        items.compactMap { m in
            guard let v = metric.getter(m) else { return nil }
            return (m.date, v, metric.unitFor(m))
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if !showAll {
                    Section("Last 7") {
                        ForEach(Array(recent7.enumerated()), id: \.offset) { _, row in
                            HStack {
                                Text(row.d, style: .date)
                                Spacer()
                                Text(formatted(row.v))
                                Text(row.u).foregroundStyle(.secondary)
                            }
                        }
                    }
                } else {
                    Section("All") {
                        ForEach(Array(allValues.enumerated()), id: \.offset) { _, row in
                            HStack {
                                Text(row.d, style: .date)
                                Spacer()
                                Text(formatted(row.v))
                                Text(row.u).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(metric.title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(showAll ? "Last 7" : "All") {
                        withAnimation { showAll.toggle() }
                    }
                }
            }
        }
    }
}

// MARK: - Helpers
private func formatted(_ v: Double) -> String {
    String(format: "%.1f", v)
}

private func signed(_ d: Double) -> String {
    if d > 0 { return "+\(formatted(d))" }
    if d < 0 { return "−\(formatted(abs(d)))" }
    return formatted(0)
}

