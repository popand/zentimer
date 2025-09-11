import ActivityKit
import WidgetKit
import SwiftUI

// Test to see if we can get basic custom UI working
@available(iOS 16.1, *)
struct TestTimerActivityWidget: Widget {
    let kind: String = "TestTimerActivity"
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen/banner UI - Keep it simple
            VStack {
                Text("ZenTimer")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(formatTime(context.state.remainingTime))")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "timer")
                        .foregroundColor(.orange)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(formatTime(context.state.remainingTime))
                        .foregroundColor(.white)
                        .font(.caption.monospaced())
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("Focus Timer")
                            .font(.caption)
                            .foregroundColor(.white)
                        Spacer()
                        Text(formatTime(context.state.remainingTime))
                            .font(.title3.monospaced())
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundColor(.orange)
            } compactTrailing: {
                Text(formatTime(context.state.remainingTime))
                    .foregroundColor(.white)
                    .font(.caption.monospaced())
            } minimal: {
                Circle()
                    .fill(.orange)
                    .frame(width: 16, height: 16)
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}