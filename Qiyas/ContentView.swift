import SwiftUI
import SwiftData

// MARK: - Root tabs
struct ContentView: View {
    @State private var tab = 1

    var body: some View {
        TabView(selection: $tab) {
            HistoryView()
                .tabItem { Label("Results", systemImage: "list.bullet.rectangle") }
                .tag(0)

            TodayView()
                .tabItem { Label("Today", systemImage: "circle.fill") }
                .tag(1)

            MeView()
                .tabItem { Label("User", systemImage: "person.crop.circle") }
                .tag(2)
        }
        .tint(.blue)
    }
}

// MARK: - Today Screen
struct TodayView: View {
    @Query(sort: \BodyEntry.date, order: .reverse, animation: .default)
    private var entries: [BodyEntry]

    @Query(animation: .default)
    private var profiles: [UserProfile]

    private var latest: BodyEntry? { entries.first }
    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Today").font(.largeTitle).bold().padding(.top, 6)

                    MetricCard(title: "NAVY Body Fat",
                               value: navyString(),
                               hint: navyHint())

                    MetricCard(title: "BMI",
                               value: bmiString(),
                               hint: "Add weight + height")

                    HStack(spacing: 16) {
                        NavigationLink { WeeklyEntryView() } label: {
                            Text("Weekly").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        NavigationLink { DailyEntryView() } label: {
                            Text("Daily").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Calculations
    private func bmiString() -> String {
        guard let w = latest?.weight,
              let hCm = profile?.heightCm, hCm > 0 else { return "—" }
        let hM = hCm / 100.0
        return String(format: "%.1f", w / (hM*hM))
    }

    private func navyString() -> String {
        guard let hCm = profile?.heightCm,
              let neck = latest?.neck,
              let waist = latest?.waist else { return "—" }
        let hips = latest?.hips
        let s = profile?.sex ?? .male
        let bf = navyBF(sex: s, heightCm: hCm, neckCm: neck, waistCm: waist, hipsCm: hips)
        return bf.map { String(format: "%.1f%%", $0) } ?? "—"
    }

    private func navyHint() -> String {
        (profile?.sex ?? .male) == .female
        ? "Need: height + neck + waist + hips"
        : "Need: height + neck + waist"
    }

    private func navyBF(sex: Sex, heightCm: Double, neckCm: Double, waistCm: Double, hipsCm: Double?) -> Double? {
        let h = heightCm / 2.54, n = neckCm / 2.54, w = waistCm / 2.54, hp = hipsCm.map { $0/2.54 }
        switch sex {
        case .male:
            guard w > n, h > 0 else { return nil }
            return max(0, 86.010*log10(w-n) - 70.041*log10(h) + 36.76)
        case .female:
            guard let hips = hp, (w + hips) > n, h > 0 else { return nil }
            return max(0, 163.205*log10(w+hips-n) - 97.684*log10(h) - 78.387)
        }
    }
}

// MARK: - Small Card
struct MetricCard: View {
    let title: String
    let value: String
    let hint: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.title3).bold()
            Text(value).font(.system(size: 36, weight: .bold, design: .rounded))
            Text(hint).font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.gray.opacity(0.18), lineWidth: 1)
        )
    }
}

