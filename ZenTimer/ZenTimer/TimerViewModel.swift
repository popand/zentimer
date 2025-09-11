import SwiftUI
import Combine
import AVFoundation
import UserNotifications
import AudioToolbox
import Intents
import ActivityKit
import BackgroundTasks

class TimerViewModel: ObservableObject {
    @Published var minutes: Int = 25
    @Published var totalSeconds: Int = 25 * 60
    @Published var timeLeft: Int = 25 * 60
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
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    // Background and Live Activity support
    private var liveActivityManager: AnyObject? {
        if #available(iOS 16.1, *) {
            return LiveActivityManager.shared
        }
        return nil
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
            startLiveActivity()
        } else {
            pauseTimer()
            updateLiveActivity()
        }
    }
    
    func resetTimer() {
        stopTimer()
        isRunning = false
        timeLeft = totalSeconds
        endLiveActivity()
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
        startBackgroundTask()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeLeft > 0 {
                self.timeLeft -= 1
                self.updateLiveActivity()
                
                // Schedule local notification for completion if we're near the end
                if self.timeLeft <= 5 && self.timeLeft > 0 {
                    self.scheduleCompletionNotification()
                }
            } else {
                self.stopTimer()
                self.isRunning = false
                self.triggerNotifications()
                self.endLiveActivity()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        endBackgroundTask()
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
        // Keep background task active for pause state
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
        print("📸 Flash notification: \(flashEnabled ? "ENABLED" : "DISABLED")")
    }
    
    func toggleVibration() {
        vibrationEnabled.toggle()
        print("📳 Vibration notification: \(vibrationEnabled ? "ENABLED" : "DISABLED")")
    }
    
    func toggleSound() {
        soundEnabled.toggle()
        print("🔊 Sound notification: \(soundEnabled ? "ENABLED" : "DISABLED")")
    }
    
    func toggleDoNotDisturb() {
        doNotDisturbEnabled.toggle()
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
    
    // MARK: - Live Activity Methods
    
    private func startLiveActivity() {
        guard #available(iOS 16.1, *) else { return }
        print("🎬 TimerViewModel: Starting Live Activity")
        (liveActivityManager as? LiveActivityManager)?.startLiveActivity(
            totalTime: TimeInterval(totalSeconds),
            remainingTime: TimeInterval(timeLeft),
            isRunning: isRunning
        )
    }
    
    private func updateLiveActivity() {
        guard #available(iOS 16.1, *) else { return }
        (liveActivityManager as? LiveActivityManager)?.updateLiveActivity(
            remainingTime: TimeInterval(timeLeft),
            totalTime: TimeInterval(totalSeconds),
            isRunning: isRunning
        )
    }
    
    private func endLiveActivity() {
        guard #available(iOS 16.1, *) else { return }
        (liveActivityManager as? LiveActivityManager)?.endLiveActivity()
    }
    
    // MARK: - Background Processing
    
    private func startBackgroundTask() {
        endBackgroundTask()
        
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "TimerBackgroundTask") { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    private func scheduleCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "ZenTimer"
        content.body = "Focus session completed! Take a well-deserved break."
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: "timer-completion",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeLeft), repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    deinit {
        stopTimer()
        messageTimer?.invalidate()
        endBackgroundTask()
        if #available(iOS 16.1, *) {
            (liveActivityManager as? LiveActivityManager)?.endLiveActivity()
        }
    }
}