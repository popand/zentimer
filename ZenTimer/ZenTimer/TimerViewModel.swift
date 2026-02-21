import SwiftUI
import Combine
import AVFoundation
import UserNotifications
import AudioToolbox
import Intents
import UIKit

class TimerViewModel: ObservableObject {
    @Published var minutes: Int = 5
    @Published var totalSeconds: Int = 5 * 60
    @Published var timeLeft: Int = 5 * 60
    @Published var isRunning: Bool = false
    @Published var isDragging: Bool = false
    @Published var dragProgress: Double? = nil
    
    // Presets
    @Published var presets: [TimerPreset] = []

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
    private(set) var timerEndDate: Date?
    private let userDefaults = UserDefaults.standard

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
        static let presets = "timerPresets"
    }
    
    init() {
        // Load saved preferences and presets first
        loadUserPreferences()
        loadPresets()
        // Request notification permissions on initialization
        requestNotificationPermissions()
        // Restore timer state if app was terminated while timer was running
        restoreTimerStateIfNeeded()
        // Setup app lifecycle observers
        setupAppLifecycleObservers()
        // Setup App Intents observers for Siri/Shortcuts integration
        setupAppIntentsObservers()
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
    
    var accessibleTimeDescription: String {
        let mins = timeLeft / 60
        let secs = timeLeft % 60
        
        if mins > 0 && secs > 0 {
            return "\(mins) minute\(mins == 1 ? "" : "s") and \(secs) second\(secs == 1 ? "" : "s")"
        } else if mins > 0 {
            return "\(mins) minute\(mins == 1 ? "" : "s")"
        } else {
            return "\(secs) second\(secs == 1 ? "" : "s")"
        }
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

        // Schedule a local notification for timer completion
        scheduleTimerCompletionNotification()

        // Start Live Activity for Dynamic Island and Lock Screen
        startLiveActivity()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            // Update time based on the end date to stay accurate
            if let endDate = self.timerEndDate {
                let remainingTime = Int(endDate.timeIntervalSinceNow)
                if remainingTime > 0 {
                    self.timeLeft = remainingTime
                } else {
                    self.timeLeft = 0
                    self.completeTimer() // Use completeTimer instead of stopTimer
                    self.isRunning = false
                }
            }
        }
    }
    
    func stopTimer() {
        // User-initiated stop - cancel everything
        timer?.invalidate()
        timer = nil
        timerEndDate = nil
        clearTimerState()
        cancelTimerNotification()
        endLiveActivity()
    }

    private func completeTimer() {
        // Natural timer completion - don't cancel notification, let it fire
        timer?.invalidate()
        timer = nil
        timerEndDate = nil
        clearTimerState() // Still clear state since timer is done
        endLiveActivity()
        // Don't cancel notification - let it fire naturally
        triggerNotifications() // Trigger foreground notifications if app is active
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
        let appState = UIApplication.shared.applicationState
        print("🔔 Timer completed - app state: \(appState == .active ? "foreground" : appState == .background ? "background" : "inactive")")

        // If app is in background, the local notification should handle everything
        // Only trigger in-app notifications when app is active
        if appState == .active {
            triggerForegroundNotifications()
        } else {
            print("📱 App in background - relying on scheduled local notification")
            // Verify that we have a scheduled notification
            checkPendingNotifications()
        }
    }

    private func triggerForegroundNotifications() {
        // Check if we should trigger notifications based on Do Not Disturb settings
        if !shouldTriggerNotifications() {
            print("🔕 Do Not Disturb active - limited foreground notifications:")
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

        // Normal foreground notification behavior
        print("🔔 Timer completed - triggering enabled foreground notifications:")
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

    private func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let timerNotifications = requests.filter { $0.identifier == "timer.completion" }
            print("📱 Pending timer notifications: \(timerNotifications.count)")

            if timerNotifications.isEmpty {
                print("⚠️ No pending timer notification found - this might be why background notifications aren't working")
            } else {
                for request in timerNotifications {
                    if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                        print("   ⏰ Notification scheduled to fire in \(trigger.timeInterval) seconds")
                    }
                }
            }
        }
    }
    
    private func triggerCalmingVibration() {
        // Extended vibration pattern: 3 rounds of triple pulses with pauses between rounds
        DispatchQueue.main.async {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.prepare()

            let totalRounds = 3
            let pulsesPerRound = 3
            let pulseInterval: TimeInterval = 0.25
            let roundPause: TimeInterval = 0.6

            for round in 0..<totalRounds {
                let roundDelay = Double(round) * (Double(pulsesPerRound) * pulseInterval + roundPause)
                for pulse in 0..<pulsesPerRound {
                    let pulseDelay = roundDelay + Double(pulse) * pulseInterval
                    DispatchQueue.main.asyncAfter(deadline: .now() + pulseDelay) {
                        impactFeedback.impactOccurred()
                    }
                }
            }
        }
    }
    
    private func triggerFlash() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch,
              device.isTorchAvailable else {
            print("⚠️ Torch not available on this device")
            return
        }
        
        // Check if torch is currently in use
        guard !device.isTorchActive else {
            print("⚠️ Torch already active")
            return
        }
        
        DispatchQueue.main.async {
            self.performFlashSequence(device: device, flashCount: 0)
        }
    }
    
    private func performFlashSequence(device: AVCaptureDevice, flashCount: Int) {
        guard flashCount < 6 else { return }

        do {
            try device.lockForConfiguration()
            try device.setTorchModeOn(level: 1.0)
            device.unlockForConfiguration()

            // Turn off after 300ms (longer on-time for visibility)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                do {
                    try device.lockForConfiguration()
                    device.torchMode = .off
                    device.unlockForConfiguration()
                } catch {
                    print("Flash off error: \(error)")
                }

                // Schedule next flash after 500ms pause
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.performFlashSequence(device: device, flashCount: flashCount + 1)
                }
            }
        } catch {
            print("Flash error: \(error)")
        }
    }
    
    private func triggerCalmingSound() {
        // Play a reliable system sound that works across all devices
        DispatchQueue.main.async {
            // Play the tri-tone alert sound (reliable on all iOS devices)
            AudioServicesPlayAlertSound(SystemSoundID(1005))
            // Play a second chime after a short delay for emphasis
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                AudioServicesPlayAlertSound(SystemSoundID(1005))
            }
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

        // 1. Request notification permissions if needed (essential for background operation)
        requestNotificationPermissions()

        // 2. Check if system Focus is already active
        checkSystemFocusStatus()

        // 3. DO NOT suppress background notifications - they're needed for timer completion
        // 4. Only suppress in-app foreground notifications (flash, extra sounds)

        print("✅ Zen Timer Do Not Disturb enabled")
        print("📱 Background notifications will still work for timer completion")
        print("💡 Tip: Enable iOS Focus mode manually for system-wide quiet time")
    }
    
    private func disableDoNotDisturbFeatures() {
        print("❌ Zen Timer Do Not Disturb disabled")
    }
    
    private func requestNotificationPermissions() {
        // First check current authorization status
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("📱 Current notification settings: \(settings.authorizationStatus.rawValue)")

            switch settings.authorizationStatus {
            case .notDetermined:
                // First time - request permission with critical options for background notifications
                UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .sound, .badge, .criticalAlert, .providesAppNotificationSettings]
                ) { granted, error in
                    DispatchQueue.main.async {
                        if granted {
                            print("✅ Notification permissions granted including critical alerts")
                        } else {
                            print("❌ Notification permissions denied: \(error?.localizedDescription ?? "Unknown error")")
                            print("   ⚠️ Background timer notifications may not work properly")
                        }
                    }
                }
            case .denied:
                print("🚫 Notifications denied - user needs to enable in Settings")
                print("   💡 Background timer completion will not work without notifications")
            case .authorized, .provisional:
                print("✅ Notifications already authorized")
            case .ephemeral:
                print("⏰ Ephemeral authorization (App Clips)")
            @unknown default:
                print("⚠️ Unknown notification authorization status")
            }
        }
    }
    
    private func checkSystemFocusStatus() {
        // Check if system Focus mode is active
        let focusStatus = INFocusStatusCenter.default.focusStatus
        if focusStatus.isFocused == true {
            print("🎯 System Focus mode is active")
            // When system Focus is active, we can be extra quiet
            suppressAllNotifications()
        } else {
            print("🎯 System Focus mode is not active")
        }
    }
    
    private func suppressAllNotifications() {
        // Remove non-essential notifications, but keep timer completion notification
        // This preserves the critical timer functionality while respecting Focus mode
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let nonTimerRequests = requests.compactMap { request in
                request.identifier != "timer.completion" ? request.identifier : nil
            }

            if !nonTimerRequests.isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: nonTimerRequests)
                print("🔕 Non-essential notifications suppressed, timer notification preserved")
            } else {
                print("🔕 No non-essential notifications to suppress")
            }
        }
    }
    
    // Enhanced notification method that respects Do Not Disturb
    private func shouldTriggerNotifications() -> Bool {
        if doNotDisturbEnabled {
            // Check if system Focus is active
            let focusStatus = INFocusStatusCenter.default.focusStatus
            if focusStatus.isFocused == true {
                // System Focus is active, be completely silent
                return false
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

            // Start Live Activity for restored timer
            startLiveActivity()

            // Start the timer without calling startTimer() to avoid double-saving state
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }

                if let endDate = self.timerEndDate {
                    let remainingTime = Int(endDate.timeIntervalSinceNow)
                    if remainingTime > 0 {
                        self.timeLeft = remainingTime
                    } else {
                        self.timeLeft = 0
                        self.completeTimer() // Use completeTimer for natural completion
                        self.isRunning = false
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

        // Always schedule a background notification regardless of DND settings
        // The system notification will handle background/locked states
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self = self else { return }

            switch settings.authorizationStatus {
            case .authorized, .provisional:
                // Always create the notification - it's essential for background operation
                self.createAndScheduleNotification(endDate: endDate)
                print("🔔 Background notification scheduled (required for background timer completion)")
            case .denied:
                print("🚫 Cannot schedule background notification - permissions denied")
                print("   ⚠️ Timer notifications will only work when app is in foreground")
            case .notDetermined:
                print("⚠️ Notification permissions not determined - requesting and scheduling")
                // Request permissions and schedule after getting them
                self.requestNotificationPermissions()
                // Schedule anyway in case permissions are granted quickly
                self.createAndScheduleNotification(endDate: endDate)
            default:
                print("⚠️ Notification authorization status: \(settings.authorizationStatus)")
                // Still try to schedule - some states might allow notifications
                self.createAndScheduleNotification(endDate: endDate)
            }
        }
    }

    private func createAndScheduleNotification(endDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "🧘 ZenTimer Complete"
        content.body = "Your \(minutes) minute meditation timer has finished. Time to return to mindfulness."
        content.categoryIdentifier = "TIMER_COMPLETE"
        content.badge = NSNumber(value: 1)
        content.threadIdentifier = "zentimer.notifications"

        // Configure sound for background notifications
        // Background notifications need sound to trigger properly and provide haptic feedback
        if soundEnabled {
            // User wants sound - use critical sound to ensure it plays even in silent mode
            content.sound = .defaultCritical
        } else if vibrationEnabled {
            // User wants vibration only - use default sound which triggers vibration but can be muted
            content.sound = .default
        } else {
            // User disabled both - still use default to ensure notification appears, but system will respect silent mode
            content.sound = .default
        }

        // Add notification relevance score to ensure prominence
        content.relevanceScore = 1.0 // Maximum relevance
        content.interruptionLevel = soundEnabled ? .critical : .active

        // Add custom user info for debugging
        content.userInfo = [
            "timerMinutes": minutes,
            "completionTime": endDate.timeIntervalSince1970,
            "soundEnabled": soundEnabled,
            "vibrationEnabled": vibrationEnabled,
            "flashEnabled": flashEnabled,
            "doNotDisturbEnabled": doNotDisturbEnabled
        ]

        let timeInterval = endDate.timeIntervalSinceNow
        guard timeInterval > 0 else {
            print("⚠️ Timer end date is in the past, cannot schedule notification")
            return
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "timer.completion", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Failed to schedule notification: \(error.localizedDescription)")
                    self?.showTemporaryMessage("Failed to schedule notification: \(error.localizedDescription)")
                } else {
                    print("✅ Timer completion notification scheduled for background delivery")
                    print("   📅 Scheduled for: \(endDate)")
                    print("   ⏰ Time interval: \(timeInterval) seconds")
                    print("   🔊 Sound enabled: \(self?.soundEnabled ?? false)")
                    print("   📳 Vibration enabled: \(self?.vibrationEnabled ?? false)")
                    print("   🔕 DND enabled: \(self?.doNotDisturbEnabled ?? false)")
                    print("   📱 Will show banner/bubble when app is in background")
                }
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
        // Clear badge number when app becomes active
        clearAppBadge()

        if isRunning, let endDate = timerEndDate {
            let remainingTime = Int(endDate.timeIntervalSinceNow)
            if remainingTime > 0 {
                timeLeft = remainingTime
            } else {
                timeLeft = 0
                completeTimer() // Use completeTimer for natural completion
                isRunning = false
            }
        }
    }

    /// Call this when the app is about to terminate to ensure cleanup
    func handleAppWillTerminate() {
        cleanupResources()
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

        // Clear badge number when app returns to foreground
        clearAppBadge()

        // Verify timer accuracy when returning from background
        if isRunning, let endDate = timerEndDate {
            let remainingTime = Int(endDate.timeIntervalSinceNow)
            if remainingTime <= 0 {
                // Timer expired while in background
                timeLeft = 0
                completeTimer() // Use completeTimer for natural completion
                isRunning = false
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
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        print("♻️ TimerViewModel deallocating")
        cleanupResources()
    }

    // MARK: - Badge Management

    /// Clear the app badge number and remove delivered notifications
    func clearAppBadge() {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().setBadgeCount(0)
            // Also clear delivered notifications to clean up notification center
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["timer.completion"])
            print("🔢 App badge cleared and delivered timer notifications removed")
        }
    }

    // MARK: - Preset Management

    private func loadPresets() {
        guard let data = userDefaults.data(forKey: UserDefaultsKeys.presets),
              let decoded = try? JSONDecoder().decode([TimerPreset].self, from: data) else {
            presets = TimerPreset.defaults
            return
        }
        presets = decoded
    }

    private func savePresets() {
        if let data = try? JSONEncoder().encode(presets) {
            userDefaults.set(data, forKey: UserDefaultsKeys.presets)
        }
    }

    func addPreset(_ preset: TimerPreset) {
        presets.append(preset)
        savePresets()
    }

    func deletePreset(id: UUID) {
        presets.removeAll { $0.id == id }
        savePresets()
    }

    func updatePreset(_ preset: TimerPreset) {
        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
            presets[index] = preset
            savePresets()
        }
    }

    // MARK: - Debug Methods

    func debugNotificationStatus() {
        print("\n🔍 === NOTIFICATION DEBUG STATUS ===")
        print("📱 Timer Running: \(isRunning)")
        print("📱 Time Left: \(timeLeft)")
        print("📱 Background Task: Not Used (Removed for iOS Compliance)")

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                print("📱 Authorization Status: \(settings.authorizationStatus)")
                print("📱 Notification Center Setting: \(settings.notificationCenterSetting)")
                print("📱 Alert Setting: \(settings.alertSetting)")
                print("📱 Sound Setting: \(settings.soundSetting)")
                print("📱 Badge Setting: \(settings.badgeSetting)")
                print("📱 Lock Screen Setting: \(settings.lockScreenSetting)")

                // Check pending notifications
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    let timerRequests = requests.filter { $0.identifier == "timer.completion" }
                    print("📱 Pending timer notifications: \(timerRequests.count)")

                    for request in timerRequests {
                        print("   📝 ID: \(request.identifier)")
                        print("   📝 Title: \(request.content.title)")
                        print("   📝 Body: \(request.content.body)")
                        if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                            print("   📝 Time remaining: \(trigger.timeInterval) seconds")
                        }
                    }

                    // Check delivered notifications
                    UNUserNotificationCenter.current().getDeliveredNotifications { delivered in
                        let deliveredTimer = delivered.filter { $0.request.identifier == "timer.completion" }
                        print("📱 Delivered timer notifications: \(deliveredTimer.count)")
                        print("🔍 === END DEBUG STATUS ===\n")
                    }
                }
            }
        }
    }

    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("🗑️ All notifications cleared")
    }
}
