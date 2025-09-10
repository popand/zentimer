import SwiftUI
import Combine

class TimerViewModel: ObservableObject {
    @Published var minutes: Int = 25
    @Published var totalSeconds: Int = 25 * 60
    @Published var timeLeft: Int = 25 * 60
    @Published var isRunning: Bool = false
    @Published var isDragging: Bool = false
    @Published var dragProgress: Double? = nil
    
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
                // Add completion haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopTimer()
    }
}