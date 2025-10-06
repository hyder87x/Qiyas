import SwiftUI
import SwiftData

@main
struct QiyasApp: App {
    @AppStorage("onboarding.done") private var onboardingDone: Bool = false

    var body: some Scene {
        WindowGroup {
            if onboardingDone {
                ContentView()
            } else {
                OnboardingView()
            }
        }
        .modelContainer(for: Measurement.self)
    }
}

