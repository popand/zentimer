import SwiftUI
import UserNotifications

@main
struct ZenTimerApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var timerViewModel = TimerViewModel()
    @StateObject private var notificationDelegate = NotificationDelegate()
    @State private var showSplash = false // Temporarily disabled for testing

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                } else {
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
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .onAppear {
                // Check for testing reset flag
                handleTestingArguments()
                setupNotifications()
                // Show splash screen for 1 second
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        showSplash = false
                    }
                }
            }
        }
    }

    private func handleTestingArguments() {
        // Check if app was launched with reset flag for UI testing
        if CommandLine.arguments.contains("--reset-for-testing") {
            print("🧪 UI Testing mode detected - resetting app state")
            // Clear all UserDefaults data
            let userDefaults = UserDefaults.standard
            let dictionary = userDefaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                userDefaults.removeObject(forKey: key)
            }
            userDefaults.synchronize()

            // Clear all notifications
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()

            print("🗑️ All app data cleared for testing")
        }
    }

    private func setupNotifications() {
        // Set up the notification delegate
        UNUserNotificationCenter.current().delegate = notificationDelegate

        // Configure notification categories
        setupNotificationCategories()

        // Link the notification delegate to the timer view model
        notificationDelegate.timerViewModel = timerViewModel

        print("📱 Notification system configured")
    }

    private func setupNotificationCategories() {
        let stopAction = UNNotificationAction(
            identifier: "STOP_TIMER",
            title: "Stop Timer",
            options: [.foreground]
        )

        let restartAction = UNNotificationAction(
            identifier: "RESTART_TIMER",
            title: "Restart",
            options: [.foreground]
        )

        let timerCompleteCategory = UNNotificationCategory(
            identifier: "TIMER_COMPLETE",
            actions: [stopAction, restartAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        UNUserNotificationCenter.current().setNotificationCategories([timerCompleteCategory])
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

// MARK: - NotificationDelegate
class NotificationDelegate: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    weak var timerViewModel: TimerViewModel?

    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("📱 Handling foreground notification: \(notification.request.identifier)")

        if notification.request.identifier == "timer.completion" {
            // For timer completion, always show full notification even in foreground
            // This ensures consistent behavior regardless of app state
            if #available(iOS 14.0, *) {
                completionHandler([.banner, .list, .sound, .badge])
            } else {
                completionHandler([.alert, .sound, .badge])
            }
            print("   🔔 Displaying full timer completion notification in foreground")
        } else {
            // For other notifications, use default behavior
            completionHandler([.banner, .sound, .badge])
        }
    }

    // Handle notification response (user tapped on notification)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("📱 Handling notification response: \(response.actionIdentifier)")

        guard let viewModel = timerViewModel else {
            completionHandler()
            return
        }

        // Clear badge number when user interacts with notification
        viewModel.clearAppBadge()

        switch response.actionIdentifier {
        case "STOP_TIMER":
            viewModel.stopTimer()
        case "RESTART_TIMER":
            viewModel.resetTimer()
            viewModel.toggleTimer()
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification itself, just open the app
            break
        default:
            break
        }

        completionHandler()
    }
}