import SwiftUI

@main
struct ZenTimerApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var timerViewModel = TimerViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerViewModel)
                .preferredColorScheme(.light)
                .onChange(of: scenePhase) { newPhase in
                    handleScenePhaseChange(newPhase)
                }
        }
    }

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            print("📱 App moved to background - timer will continue running")
            // Timer continues running due to background task
        case .inactive:
            print("📱 App is inactive")
        case .active:
            print("📱 App is active")
        @unknown default:
            break
        }
    }
}