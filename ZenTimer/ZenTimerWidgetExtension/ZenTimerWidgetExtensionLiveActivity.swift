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

// MARK: - Main Live Activity Widget
@available(iOS 16.1, *)
struct ZenTimerWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen/banner UI
            TimerLiveActivityLockScreenView(
                state: context.state,
                attributes: context.attributes
            )
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI - shows when tapped
                DynamicIslandExpandedRegion(.leading) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        
                        Circle()
                            .trim(from: 0, to: progress(for: context.state))
                            .stroke(
                                LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                        
                        Image(systemName: context.state.isRunning ? "timer" : "pause.circle")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .frame(width: 40, height: 40)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(timeString(for: context.state))
                            .font(.system(.title3, design: .monospaced, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(context.state.isRunning ? .green : .orange)
                                .frame(width: 6, height: 6)
                            
                            Text(context.state.isRunning ? "Focus" : "Paused")
                                .font(.system(.caption, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("ZenTimer")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text(timeString(for: context.state))
                            .font(.system(.title3, design: .monospaced, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal)
                }
            } compactLeading: {
                // Compact leading - left side when collapsed
                Image(systemName: context.state.isRunning ? "timer" : "pause.circle")
                    .foregroundColor(.orange)
                    .font(.system(size: 16, weight: .semibold))
            } compactTrailing: {
                // Compact trailing - right side when collapsed
                Text(timeString(for: context.state))
                    .font(.system(.caption, design: .monospaced, weight: .semibold))
                    .foregroundColor(.white)
            } minimal: {
                // Minimal - smallest state
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    
                    Circle()
                        .trim(from: 0, to: progress(for: context.state))
                        .stroke(Color.orange, lineWidth: 2)
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 16, height: 16)
            }
        }
    }
    
    // Helper functions
    private func progress(for state: TimerActivityAttributes.ContentState) -> CGFloat {
        guard state.totalTime > 0 else { return 0 }
        return CGFloat(1.0 - (state.remainingTime / state.totalTime))
    }
    
    private func timeString(for state: TimerActivityAttributes.ContentState) -> String {
        let minutes = Int(state.remainingTime) / 60
        let seconds = Int(state.remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Lock Screen View
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
            
            // App name
            Text("ZenTimer")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
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

// MARK: - Preview
#Preview("Notification", as: .content, using: TimerActivityAttributes(timerName: "Focus Timer")) {
   ZenTimerWidgetExtensionLiveActivity()
} contentStates: {
    TimerActivityAttributes.ContentState(
        remainingTime: 1500,
        totalTime: 1500,
        isRunning: true,
        startTime: Date()
    )
    TimerActivityAttributes.ContentState(
        remainingTime: 300,
        totalTime: 1500,
        isRunning: false,
        startTime: Date()
    )
}