import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes
struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingTime: TimeInterval
        var totalTime: TimeInterval
        var isRunning: Bool
        var startTime: Date
    }
    
    // Static properties that don't change during the activity
    var timerName: String
}

// MARK: - Live Activity Views  
@available(iOS 16.1, *)
struct TimerLiveActivityLockScreenView: View {
    let state: TimerActivityAttributes.ContentState
    let attributes: TimerActivityAttributes
    
    var body: some View {
        VStack(spacing: 8) {
            // Timer Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 4)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text(timeString)
                        .font(.system(.title2, design: .monospaced, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if state.isRunning {
                        Text("FOCUS")
                            .font(.system(.caption, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    } else {
                        Text("PAUSED")
                            .font(.system(.caption, weight: .medium))
                            .foregroundColor(.orange)
                    }
                }
            }
            .frame(width: 60, height: 60)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(red: 251/255, green: 146/255, blue: 60/255),
                    Color(red: 239/255, green: 68/255, blue: 68/255),
                    Color(red: 220/255, green: 38/255, blue: 38/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var progress: CGFloat {
        guard state.totalTime > 0 else { return 0 }
        return CGFloat(1.0 - (state.remainingTime / state.totalTime))
    }
    
    private var timeString: String {
        let minutes = Int(state.remainingTime) / 60
        let seconds = Int(state.remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Dynamic Island Compact Leading
@available(iOS 16.1, *)
struct TimerCompactLeadingView: View {
    let state: TimerActivityAttributes.ContentState
    
    var body: some View {
        Image(systemName: state.isRunning ? "timer" : "pause.circle")
            .foregroundColor(.orange)
            .font(.system(size: 16, weight: .semibold))
    }
}

// MARK: - Dynamic Island Compact Trailing  
@available(iOS 16.1, *)
struct TimerCompactTrailingView: View {
    let state: TimerActivityAttributes.ContentState
    
    var body: some View {
        Text(timeString)
            .font(.system(.caption, design: .monospaced, weight: .semibold))
            .foregroundColor(.white)
    }
    
    private var timeString: String {
        let minutes = Int(state.remainingTime) / 60
        let seconds = Int(state.remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Dynamic Island Minimal
@available(iOS 16.1, *)
struct TimerMinimalView: View {
    let state: TimerActivityAttributes.ContentState
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.orange, lineWidth: 2)
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 20, height: 20)
    }
    
    private var progress: CGFloat {
        guard state.totalTime > 0 else { return 0 }
        return CGFloat(1.0 - (state.remainingTime / state.totalTime))
    }
}

// MARK: - Dynamic Island Expanded
@available(iOS 16.1, *)
struct TimerExpandedView: View {
    let state: TimerActivityAttributes.ContentState
    
    var body: some View {
        HStack(spacing: 16) {
            // Timer Ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: state.isRunning ? "timer" : "pause.circle")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
            }
            .frame(width: 40, height: 40)
            
            // Timer Info
            VStack(alignment: .leading, spacing: 4) {
                Text(timeString)
                    .font(.system(.title3, design: .monospaced, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(state.isRunning ? .green : .orange)
                        .frame(width: 6, height: 6)
                    
                    Text(state.isRunning ? "Focus Time" : "Paused")
                        .font(.system(.caption, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var progress: CGFloat {
        guard state.totalTime > 0 else { return 0 }
        return CGFloat(1.0 - (state.remainingTime / state.totalTime))
    }
    
    private var timeString: String {
        let minutes = Int(state.remainingTime) / 60
        let seconds = Int(state.remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}