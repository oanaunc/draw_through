import SwiftUI

@main
struct DrawThroughApp: App {
    @StateObject private var store = ProjectStore()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if let screenshotScene = ScreenshotScene.launchScene {
                    ScreenshotShowcaseView(scene: screenshotScene)
                } else if hasSeenOnboarding {
                    HomeView()
                } else {
                    OnboardingView { hasSeenOnboarding = true }
                }
            }
            .environmentObject(store)
            .preferredColorScheme(.light)
            .tint(DTTheme.clay)
        }
    }
}
