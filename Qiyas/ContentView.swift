import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var tab = 1 // Today هو الافتراضي

    var body: some View {
        TabView(selection: $tab) {
            // Tab 0: Results (History)
            HistoryView()
                .tabItem {
                    Label("Results", systemImage: "list.bullet.rectangle")
                }
                .tag(0)

            // Tab 1: Today (Home)
            TodayView()
                .tabItem {
                    Image(systemName: "circle.fill")
                        .symbolRenderingMode(.monochrome)
                    Text("Today")
                }
                .tag(1)

            // Tab 2: User
            UserView()
                .tabItem {
                    Label("User", systemImage: "person.crop.circle")
                }
                .tag(2)
        }
        .tint(.blue) // لون التبويب المختار
    }
}

// MARK: - Today (Home) screen
struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Measurement.date, order: .reverse, animation: .default)
    private var items: [Measurement]

    @State private var weightText = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer(minLength: 8)

                // دائرة زرقاء لطيفة
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 160, height: 160)
                    VStack(spacing: 6) {
                        Text("Today")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Text(Date(), style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if let last = items.first?.weight {
                            Text("Last: \(String(format: "%.1f", last)) kg")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // إدخال الوزن السريع
                VStack(spacing: 12) {
                    HStack {
                        Text("Weight")
                        Spacer()
                        HStack(spacing: 6) {
                            TextField("", text: $weightText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .focused($focused)
                                .onChange(of: weightText) { _, new in
                                    weightText = numericFiltered(new)
                                }
                            Text("kg").foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                        )
                        .frame(minWidth: 140)
                    }

                    Button {
                        saveTodayWeight()
                    } label: {
                        Text("Log Weight")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(weightText.isEmpty)
                }
                .padding(.horizontal, 20)

                // روابط سريعة (اختياريتين)
                HStack(spacing: 12) {
                    NavigationLink {
                        DailyEntryView()
                    } label: {
                        Label("Daily Entry", systemImage: "sun.max.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    NavigationLink {
                        WeeklyEntryView()
                    } label: {
                        Label("Weekly Entry", systemImage: "calendar.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focused = false }
                }
            }
        }
    }

    // MARK: - Helpers
    private func numericFiltered(_ s: String) -> String {
        let allowed = "0123456789.,"
        var filtered = s.filter { allowed.contains($0) }
        filtered = filtered.replacingOccurrences(of: ",", with: ".")
        // نقطة واحدة فقط
        let parts = filtered.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
        if parts.count > 2 {
            filtered = parts[0] + "." + parts[1]
        }
        return String(filtered.prefix(8))
    }

    private func saveTodayWeight() {
        guard let w = Double(weightText) else { return }
        let today = Calendar.current.startOfDay(for: Date())

        if let existing = items.first(where: {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }) {
            existing.weight = w
        } else {
            let m = Measurement(date: today, unit: "cm", weight: w, notes: "Quick log")
            context.insert(m)
        }

        try? context.save()
        focused = false
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        weightText = ""
    }
}

