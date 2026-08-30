import SwiftUI

@main
struct DrawThroughApp: App {
    @StateObject private var store = ProjectStore()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding {
                    HomeView()
                } else {
                    OnboardingView { hasSeenOnboarding = true }
                }
            }
            .environmentObject(store)
            .preferredColorScheme(store.settings.appearance.colorScheme)
            .tint(DTTheme.clay)
        }
    }
}
