import SwiftUI
import SwiftData

@main
struct QiyasApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // هذي هي الطريقة المختصرة والصحيحة
        .modelContainer(for: Measurement.self)
    }
}

