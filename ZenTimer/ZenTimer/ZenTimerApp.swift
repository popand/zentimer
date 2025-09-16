import SwiftUI

@main
struct ZenTimerApp: App {
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .onChange(of: scenePhase) { newPhase in
                    handleScenePhaseChange(newPhase)
                }
        }
    }

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            print("📱 App moved to background")
        case .inactive:
            print("📱 App is inactive")
        case .active:
            print("📱 App is active")
        @unknown default:
            break
        }
    }
}