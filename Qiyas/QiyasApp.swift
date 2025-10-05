import SwiftUI
import SwiftData

@main
struct QiyasApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: Measurement.self)
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        ContentView()
            .task {
                // شغّل تعبئة الشهر الأول فقط في وضع التطوير
                #if DEBUG
                await SeedData.seedIfNeeded(in: context)
                #endif
            }
    }
}

// MARK: - Seeder (Debug only)
enum SeedData {
    @MainActor
    static func seedIfNeeded(in context: ModelContext) async {
        do {
            var desc = FetchDescriptor<Measurement>()
            desc.fetchLimit = 1
            let existing = try context.fetch(desc)
            if !existing.isEmpty { return }
        } catch { }

        let cal = Calendar.current
        let today = Date()

        let startWeight = 100.0
        let startChest  = 100.0
        let startHips   = 110.0
        let startWaist  = 100.0
        let startLArm   = 35.0
        let startRArm   = 34.0
        let startRThigh = 65.0
        let startLThigh = 67.0

        let dWeight = -0.30
        let dChest  = -0.10
        let dHips   = -0.15
        let dWaist  = -0.20
        let dArms   = -0.05
        let dThighs = -0.10

        for i in stride(from: 29, through: 0, by: -1) {
            guard let date = cal.date(byAdding: .day, value: -i, to: today) else { continue }
            let t = Double(29 - i)
            let weight = max(0, startWeight + dWeight * t)

            if i % 7 == 0 {
                let chest  = max(0, startChest  + dChest  * t)
                let hips   = max(0, startHips   + dHips   * t)
                let waist  = max(0, startWaist  + dWaist  * t)
                let lArm   = max(0, startLArm   + dArms   * t)
                let rArm   = max(0, startRArm   + dArms   * t)
                let rThigh = max(0, startRThigh + dThighs * t)
                let lThigh = max(0, startLThigh + dThighs * t)

                context.insert(Measurement(
                    date: date, unit: "cm", weight: weight,
                    chest: chest, hips: hips, waist: waist,
                    leftArm: lArm, rightArm: rArm,
                    leftThigh: lThigh, rightThigh: rThigh,
                    notes: "Auto-seeded weekly"
                ))
            } else {
                context.insert(Measurement(
                    date: date, unit: "cm", weight: weight,
                    notes: "Auto-seeded daily"
                ))
            }
        }
        try? context.save()
    }
}

