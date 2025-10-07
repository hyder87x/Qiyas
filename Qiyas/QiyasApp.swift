import SwiftUI
import SwiftData

@main
struct QiyasApp: App {

    // ModelContainer موحّد لكل التطبيق
    static let sharedModelContainer: ModelContainer = {
        // ✅ حدّد كل الموديلات المستخدمة هنا
        let schema = Schema([
            BodyEntry.self,
            UserProfile.self
        ])

        // للنسخة التطويرية خليه الافتراضي. لو تبغى تغيّر مكان التخزين أضف URL هنا
        let configuration = ModelConfiguration() // .init(url: ...) إذا احتجت

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // ✅ اربط نفس الكونتينر
        .modelContainer(Self.sharedModelContainer)
    }
}

