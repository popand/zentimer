import SwiftUI
import Combine
import AVFoundation
import UserNotifications
import AudioToolbox
import Intents
import BackgroundTasks
import UIKit

class TimerViewModel: ObservableObject {
    @Published var minutes: Int = 5
    @Published var totalSeconds: Int = 5 * 60
    @Published var timeLeft: Int = 5 * 60
    @Published var isRunning: Bool = false
    @Published var isDragging: Bool = false
    @Published var dragProgress: Double? = nil
    
    // Notification preferences
    @Published var flashEnabled: Bool = false
    @Published var vibrationEnabled: Bool = true
    @Published var soundEnabled: Bool = false
    @Published var doNotDisturbEnabled: Bool = false
    
    // Notification message state
    @Published var showNotificationMessage: Bool = false
    @Published var notificationMessage: String = ""
    
    private var timer: Timer?
    private var messageTimer: Timer?
    private var timerEndDate: Date?
    private let userDefaults = UserDefaults.standard
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid

    // Constants for UserDefaults keys
    private struct UserDefaultsKeys {
        static let timerEndDate = "timerEndDate"
        static let timerTotalSeconds = "timerTotalSeconds"
        static let timerStartDate = "timerStartDate"
        static let flashEnabled = "flashEnabled"
        static let vibrationEnabled = "vibrationEnabled"
        static let soundEnabled = "soundEnabled"
        static let doNotDisturbEnabled = "doNotDisturbEnabled"
        static let appVersion = "appVersion"
    }
    
    init() {
        // Load saved preferences first
        loadUserPreferences()
        // Request notification permissions on initialization
        requestNotificationPermissions()
        // Restore timer state if app was terminated while timer was running
        restoreTimerStateIfNeeded()
        // Setup app lifecycle observers
        setupAppLifecycleObservers()
    }
    
    var progress: Double {
        guard totalSeconds > 0 else { return 1.0 }
        return Double(timeLeft) / Double(totalSeconds)
    }
    
    var setTimeProgress: Double {
        // Use dragProgress when dragging for smooth movement, otherwise use minutes
        if isDragging, let dragProgress = dragProgress {
            return dragProgress
        }
        // Progress based on the set time (minutes), not remaining time
        return Double(minutes) / 60.0
    }
    
    var formattedTime: String {
        let mins = timeLeft / 60
        let secs = timeLeft % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    var statusText: String {
        if isRunning {
            return "Running"
        } else if timeLeft == 0 {
            return "Finished"
        } else {
            return "Drag to set time"
        }
    }
    
    func toggleTimer() {
        isRunning.toggle()
        
        if isRunning {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    func resetTimer() {
        stopTimer()
        isRunning = false
        timeLeft = totalSeconds
    }
    
    func adjustMinutes(by delta: Int) {
        guard !isRunning else { return }
        
        let newMinutes = max(1, min(99, minutes + delta))
        minutes = newMinutes
        let newTotal = newMinutes * 60
        totalSeconds = newTotal
        timeLeft = newTotal
    }
    
    func setTime(fromProgress progress: Double) {
        guard !isRunning else { return }
        
        // Store the exact drag progress for smooth handle movement
        dragProgress = progress
        
        // Convert progress (0-1) to minutes (1-60)
        let newMinutes = max(1, min(60, Int(round(progress * 60))))
        minutes = newMinutes
        let newTotal = newMinutes * 60
        totalSeconds = newTotal
        timeLeft = newTotal
    }
    
    private func startTimer() {
        // Calculate and save the timer end date
        let startDate = Date()
        timerEndDate = startDate.addingTimeInterval(TimeInterval(timeLeft))
        saveTimerState(startDate: startDate)

        // Start background task to ensure timer accuracy
        startBackgroundTask()

        // Schedule a local notification for timer completion
        scheduleTimerCompletionNotification()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            // Update time based on the end date to stay accurate
            if let endDate = self.timerEndDate {
                let remainingTime = Int(endDate.timeIntervalSinceNow)
                if remainingTime > 0 {
                    self.timeLeft = remainingTime
                } else {
                    self.timeLeft = 0
                    self.stopTimer()
                    self.isRunning = false
                    self.triggerNotifications()
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        timerEndDate = nil
        clearTimerState()
        cancelTimerNotification()
        endBackgroundTask()
    }
    
    private func showTemporaryMessage(_ message: String, duration: TimeInterval = 3.0) {
        notificationMessage = message
        showNotificationMessage = true
        
        messageTimer?.invalidate()
        messageTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.showNotificationMessage = false
                self?.notificationMessage = ""
            }
        }
    }
    
    // MARK: - Notification Methods
    
    private func triggerNotifications() {
        // Check if we should trigger notifications based on Do Not Disturb settings
        if !shouldTriggerNotifications() {
            print("🔕 Do Not Disturb active - limited notifications:")
            // In Do Not Disturb mode, only trigger the most gentle notification
            if vibrationEnabled {
                print("  📳 Triggering gentle vibration (DND mode)")
                triggerCalmingVibration()
            } else {
                print("  📳 Vibration skipped (disabled)")
            }
            print("  📸 Flash suppressed (DND mode)")
            print("  🔊 Sound suppressed (DND mode)")
            return
        }
        
        // Normal notification behavior
        print("🔔 Timer completed - triggering enabled notifications:")
        if vibrationEnabled {
            print("  📳 Triggering vibration")
            triggerCalmingVibration()
        } else {
            print("  📳 Vibration skipped (disabled)")
        }
        
        if flashEnabled {
            print("  📸 Triggering flash")
            triggerFlash()
        } else {
            print("  📸 Flash skipped (disabled)")
        }
        
        if soundEnabled {
            print("  🔊 Triggering sound")
            triggerCalmingSound()
        } else {
            print("  🔊 Sound skipped (disabled)")
        }
    }
    
    private func triggerCalmingVibration() {
        // Gentle, calming vibration pattern
        DispatchQueue.main.async {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.prepare()
            
            // Create a gentle triple pulse pattern
            impactFeedback.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                impactFeedback.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    impactFeedback.impactOccurred()
                }
            }
        }
    }
    
    private func triggerFlash() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        
        DispatchQueue.main.async {
            self.performFlashSequence(device: device, flashCount: 0)
        }
    }
    
    private func performFlashSequence(device: AVCaptureDevice, flashCount: Int) {
        guard flashCount < 3 else { return }
        
        do {
            try device.lockForConfiguration()
            try device.setTorchModeOn(level: 0.5)
            device.unlockForConfiguration()
            
            // Turn off after 150ms
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                do {
                    try device.lockForConfiguration()
                    device.torchMode = .off
                    device.unlockForConfiguration()
                } catch {
                    print("Flash off error: \(error)")
                }
                
                // Schedule next flash after 400ms total interval
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.performFlashSequence(device: device, flashCount: flashCount + 1)
                }
            }
        } catch {
            print("Flash error: \(error)")
        }
    }
    
    private func triggerCalmingSound() {
        // Play a very gentle, low chime sound
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(1016) // Low power chime
        }
    }
    
    func toggleFlash() {
        flashEnabled.toggle()
        saveUserPreferences()
        print("📸 Flash notification: \(flashEnabled ? "ENABLED" : "DISABLED")")
    }

    func toggleVibration() {
        vibrationEnabled.toggle()
        saveUserPreferences()
        print("📳 Vibration notification: \(vibrationEnabled ? "ENABLED" : "DISABLED")")
    }

    func toggleSound() {
        soundEnabled.toggle()
        saveUserPreferences()
        print("🔊 Sound notification: \(soundEnabled ? "ENABLED" : "DISABLED")")
    }

    func toggleDoNotDisturb() {
        doNotDisturbEnabled.toggle()
        saveUserPreferences()
        print("🔕 Do Not Disturb mode: \(doNotDisturbEnabled ? "ENABLED" : "DISABLED")")
        if doNotDisturbEnabled {
            enableDoNotDisturbFeatures()
            showTemporaryMessage("Do Not Disturb enabled. Only vibration will be active - flash and sound are suppressed.")
        } else {
            disableDoNotDisturbFeatures()
        }
    }
    
    private func enableDoNotDisturbFeatures() {
        // Implement app-level Do Not Disturb features
        
        // 1. Request notification permissions if needed
        requestNotificationPermissions()
        
        // 2. Check if system Focus is already active
        checkSystemFocusStatus()
        
        // 3. Suppress our app's notifications during timer
        // 4. Provide user guidance for manual Focus setup
        
        print("✅ Zen Timer Do Not Disturb enabled")
        print("💡 Tip: Enable iOS Focus mode manually for system-wide quiet time")
    }
    
    private func disableDoNotDisturbFeatures() {
        print("❌ Zen Timer Do Not Disturb disabled")
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("📱 Notification permissions granted")
                } else {
                    print("🚫 Notification permissions denied")
                }
            }
        }
    }
    
    private func checkSystemFocusStatus() {
        // Check if system Focus mode is active (iOS 15+)
        if #available(iOS 15.0, *) {
            let focusStatus = INFocusStatusCenter.default.focusStatus
            if focusStatus.isFocused == true {
                print("🎯 System Focus mode is active")
                // When system Focus is active, we can be extra quiet
                suppressAllNotifications()
            } else {
                print("🎯 System Focus mode is not active")
            }
        }
    }
    
    private func suppressAllNotifications() {
        // Remove any pending notifications from our app
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🔕 All notifications suppressed")
    }
    
    // Enhanced notification method that respects Do Not Disturb
    private func shouldTriggerNotifications() -> Bool {
        if doNotDisturbEnabled {
            // Check if system Focus is active
            if #available(iOS 15.0, *) {
                let focusStatus = INFocusStatusCenter.default.focusStatus
                if focusStatus.isFocused == true {
                    // System Focus is active, be completely silent
                    return false
                }
            }
            // App-level DND is on, only allow vibration (most gentle)
            return false
        }
        return true
    }
    
    // MARK: - Timer State Persistence

    private func saveTimerState(startDate: Date) {
        guard let endDate = timerEndDate else { return }
        userDefaults.set(endDate, forKey: UserDefaultsKeys.timerEndDate)
        userDefaults.set(totalSeconds, forKey: UserDefaultsKeys.timerTotalSeconds)
        userDefaults.set(startDate, forKey: UserDefaultsKeys.timerStartDate)
        userDefaults.set(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0", forKey: UserDefaultsKeys.appVersion)
        print("💾 Timer state saved: endDate=\(endDate), totalSeconds=\(totalSeconds)")
    }

    private func clearTimerState() {
        userDefaults.removeObject(forKey: UserDefaultsKeys.timerEndDate)
        userDefaults.removeObject(forKey: UserDefaultsKeys.timerTotalSeconds)
        userDefaults.removeObject(forKey: UserDefaultsKeys.timerStartDate)
        print("🗑️ Timer state cleared")
    }

    private func saveUserPreferences() {
        userDefaults.set(flashEnabled, forKey: UserDefaultsKeys.flashEnabled)
        userDefaults.set(vibrationEnabled, forKey: UserDefaultsKeys.vibrationEnabled)
        userDefaults.set(soundEnabled, forKey: UserDefaultsKeys.soundEnabled)
        userDefaults.set(doNotDisturbEnabled, forKey: UserDefaultsKeys.doNotDisturbEnabled)
    }

    private func loadUserPreferences() {
        // Load preferences with defaults
        flashEnabled = userDefaults.bool(forKey: UserDefaultsKeys.flashEnabled)
        vibrationEnabled = userDefaults.object(forKey: UserDefaultsKeys.vibrationEnabled) as? Bool ?? true // Default to true
        soundEnabled = userDefaults.bool(forKey: UserDefaultsKeys.soundEnabled)
        doNotDisturbEnabled = userDefaults.bool(forKey: UserDefaultsKeys.doNotDisturbEnabled)
    }

    func restoreTimerStateIfNeeded() {
        guard let endDate = userDefaults.object(forKey: UserDefaultsKeys.timerEndDate) as? Date,
              let startDate = userDefaults.object(forKey: UserDefaultsKeys.timerStartDate) as? Date else {
            print("📱 No timer state to restore")
            return
        }

        // Validate that the saved state is reasonable (not from too long ago)
        let timeSinceStart = Date().timeIntervalSince(startDate)
        guard timeSinceStart < 24 * 60 * 60 else { // 24 hours max
            print("⚠️ Timer state is too old, clearing")
            clearTimerState()
            return
        }

        let remainingTime = Int(endDate.timeIntervalSinceNow)
        let savedTotalSeconds = userDefaults.integer(forKey: UserDefaultsKeys.timerTotalSeconds)

        if remainingTime > 0 {
            // Timer is still running
            print("🔄 Restoring running timer: \(remainingTime)s remaining")
            timerEndDate = endDate
            timeLeft = remainingTime
            totalSeconds = savedTotalSeconds > 0 ? savedTotalSeconds : remainingTime
            minutes = max(1, (totalSeconds + 59) / 60) // Round up, minimum 1
            isRunning = true

            // Start the timer without calling startTimer() to avoid double-saving state
            startBackgroundTask()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }

                if let endDate = self.timerEndDate {
                    let remainingTime = Int(endDate.timeIntervalSinceNow)
                    if remainingTime > 0 {
                        self.timeLeft = remainingTime
                    } else {
                        self.timeLeft = 0
                        self.stopTimer()
                        self.isRunning = false
                        self.triggerNotifications()
                    }
                }
            }
        } else if remainingTime > -60 { // Timer finished recently (within last minute)
            print("⏰ Timer recently completed")
            clearTimerState()
            timeLeft = 0
            isRunning = false
            totalSeconds = savedTotalSeconds > 0 ? savedTotalSeconds : 5 * 60
            minutes = max(1, (totalSeconds + 59) / 60)
            // Trigger completion notifications since user missed them
            triggerNotifications()
        } else {
            // Timer expired a while ago
            print("⏰ Timer expired, clearing state")
            clearTimerState()
            timeLeft = 0
            isRunning = false
            totalSeconds = savedTotalSeconds > 0 ? savedTotalSeconds : 5 * 60
            minutes = max(1, (totalSeconds + 59) / 60)
        }
    }
    
    // MARK: - Local Notifications
    
    private func scheduleTimerCompletionNotification() {
        guard let endDate = timerEndDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Timer Complete"
        content.body = "Your \(minutes) minute timer has finished."
        content.sound = .default
        content.categoryIdentifier = "TIMER_COMPLETE"
        
        let timeInterval = endDate.timeIntervalSinceNow
        guard timeInterval > 0 else { return }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "timer.completion", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("✅ Timer completion notification scheduled for \(endDate)")
            }
        }
    }
    
    private func cancelTimerNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timer.completion"])
        print("❌ Timer notification cancelled")
    }

    // MARK: - Public Methods for App Lifecycle

    /// Call this when the app becomes active to ensure timer accuracy
    func handleAppBecameActive() {
        if isRunning, let endDate = timerEndDate {
            let remainingTime = Int(endDate.timeIntervalSinceNow)
            if remainingTime > 0 {
                timeLeft = remainingTime
            } else {
                timeLeft = 0
                stopTimer()
                isRunning = false
                triggerNotifications()
            }
        }
    }

    /// Call this when the app is about to terminate to ensure cleanup
    func handleAppWillTerminate() {
        cleanupResources()
    }

    // MARK: - Background Task Management

    private func startBackgroundTask() {
        guard backgroundTaskIdentifier == .invalid else { return }

        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask { [weak self] in
            print("⚠️ Background task expired, ending task")
            self?.endBackgroundTask()
        }

        if backgroundTaskIdentifier != .invalid {
            print("🏃 Background task started: \(backgroundTaskIdentifier.rawValue)")
        } else {
            print("❌ Failed to start background task")
        }
    }

    private func endBackgroundTask() {
        guard backgroundTaskIdentifier != .invalid else { return }

        print("🛑 Ending background task: \(backgroundTaskIdentifier.rawValue)")
        UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        backgroundTaskIdentifier = .invalid
    }

    // MARK: - App Lifecycle Management

    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }

    @objc private func appWillEnterForeground() {
        print("📱 App entering foreground")
        // Verify timer accuracy when returning from background
        if isRunning, let endDate = timerEndDate {
            let remainingTime = Int(endDate.timeIntervalSinceNow)
            if remainingTime <= 0 {
                // Timer expired while in background
                timeLeft = 0
                stopTimer()
                isRunning = false
                triggerNotifications()
            } else {
                // Update time to ensure accuracy
                timeLeft = remainingTime
            }
        }
    }

    @objc private func appDidEnterBackground() {
        print("📱 App entering background")
        // Background task is already running if timer is active
        // No additional action needed here
    }

    @objc private func appWillTerminate() {
        print("📱 App terminating")
        cleanupResources()
    }

    private func cleanupResources() {
        timer?.invalidate()
        timer = nil
        messageTimer?.invalidate()
        messageTimer = nil
        endBackgroundTask()
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        print("♻️ TimerViewModel deallocating")
        cleanupResources()
    }
}