import AppIntents
import Foundation

// App Intent for starting a meditation timer
struct StartMeditationIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Meditation Timer"
    static var description = IntentDescription("Start a meditation timer for a specified duration")
    
    @Parameter(title: "Duration (minutes)", default: 5)
    var duration: Int
    
    @Parameter(title: "Play Sound on Completion", default: false)
    var playSound: Bool
    
    @Parameter(title: "Enable Vibration", default: true)
    var enableVibration: Bool
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Start the timer with the specified duration
        // This would need to communicate with your app
        
        // Post notification to app to start timer
        NotificationCenter.default.post(
            name: NSNotification.Name("StartTimerFromIntent"),
            object: nil,
            userInfo: [
                "duration": duration,
                "playSound": playSound,
                "enableVibration": enableVibration
            ]
        )
        
        return .result(dialog: "Starting \(duration) minute meditation timer")
    }
}

// App Intent for stopping the timer
struct StopMeditationIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Meditation Timer"
    static var description = IntentDescription("Stop the current meditation timer")
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        NotificationCenter.default.post(name: NSNotification.Name("StopTimerFromIntent"), object: nil)
        return .result(dialog: "Meditation timer stopped")
    }
}

// App Shortcuts Provider
struct ZenTimerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartMeditationIntent(),
            phrases: [
                "Start meditation in \(.applicationName)",
                "Begin meditation timer in \(.applicationName)",
                "Meditate with \(.applicationName)"
            ],
            shortTitle: "Start Meditation",
            systemImageName: "timer"
        )
        
        AppShortcut(
            intent: StopMeditationIntent(),
            phrases: [
                "Stop meditation in \(.applicationName)",
                "End meditation timer in \(.applicationName)"
            ],
            shortTitle: "Stop Meditation",
            systemImageName: "stop.circle"
        )
    }
}

// Extension to handle App Intents in TimerViewModel
extension TimerViewModel {
    func setupAppIntentsObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStartTimerIntent(_:)),
            name: NSNotification.Name("StartTimerFromIntent"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStopTimerIntent(_:)),
            name: NSNotification.Name("StopTimerFromIntent"),
            object: nil
        )
    }
    
    @objc private func handleStartTimerIntent(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo["duration"] as? Int else { return }
        
        DispatchQueue.main.async {
            // Set preferences from intent
            if let playSound = userInfo["playSound"] as? Bool {
                self.soundEnabled = playSound
            }
            if let enableVibration = userInfo["enableVibration"] as? Bool {
                self.vibrationEnabled = enableVibration
            }
            
            // Set duration and start
            self.minutes = duration
            self.totalSeconds = duration * 60
            self.timeLeft = duration * 60
            
            if !self.isRunning {
                self.toggleTimer()
            }
        }
    }
    
    @objc private func handleStopTimerIntent(_ notification: Notification) {
        DispatchQueue.main.async {
            if self.isRunning {
                self.stopTimer()
            }
        }
    }
}
