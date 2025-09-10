import SwiftUI
import Combine
import AVFoundation
import UserNotifications
import AudioToolbox

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
    
    private var timer: Timer?
    
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
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeLeft > 0 {
                self.timeLeft -= 1
            } else {
                self.stopTimer()
                self.isRunning = false
                self.triggerNotifications()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Notification Methods
    
    private func triggerNotifications() {
        if vibrationEnabled {
            triggerCalmingVibration()
        }
        
        if flashEnabled {
            triggerFlash()
        }
        
        if soundEnabled {
            triggerCalmingSound()
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
            do {
                try device.lockForConfiguration()
                
                // Create a gentle flash pattern
                for i in 0..<3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                        do {
                            try device.setTorchModeOn(level: 0.5)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                device.torchMode = .off
                            }
                        } catch {
                            print("Flash error: \(error)")
                        }
                    }
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Could not configure flash: \(error)")
            }
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
    }
    
    func toggleVibration() {
        vibrationEnabled.toggle()
    }
    
    func toggleSound() {
        soundEnabled.toggle()
    }
    
    func toggleDoNotDisturb() {
        doNotDisturbEnabled.toggle()
        if doNotDisturbEnabled && isRunning {
            enableDoNotDisturb()
        }
    }
    
    private func enableDoNotDisturb() {
        // This would typically integrate with Focus/Do Not Disturb APIs
        // For now, we'll just track the state
        print("Do Not Disturb mode enabled")
    }
    
    deinit {
        stopTimer()
    }
}