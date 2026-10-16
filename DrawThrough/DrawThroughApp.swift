import SwiftUI

@main
struct DrawThroughApp: App {
    @StateObject private var store = ProjectStore()
    @StateObject private var learning = LearningStore()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding {
                    StudioRootView()
                } else {
                    OnboardingView { hasSeenOnboarding = true }
                }
            }
            .environmentObject(store)
            .environmentObject(learning)
            .preferredColorScheme(.light)
            .tint(DTTheme.clay)
        }
    }
}
