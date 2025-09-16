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
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                    timerViewModel.handleAppWillTerminate()
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
            timerViewModel.handleAppBecameActive()
        @unknown default:
            break
        }
    }
}