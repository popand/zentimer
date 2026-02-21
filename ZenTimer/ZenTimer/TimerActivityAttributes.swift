import ActivityKit
import Foundation

// Add Live Activities for Dynamic Island and Lock Screen
struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endTime: Date
        var totalMinutes: Int
    }
    
    var timerName: String = "Meditation"
}

// Extension to TimerViewModel for Live Activity support
extension TimerViewModel {
    func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities not enabled")
            return
        }
        
        guard let endDate = timerEndDate else { return }
        
        let attributes = TimerActivityAttributes()
        let contentState = TimerActivityAttributes.ContentState(
            endTime: endDate,
            totalMinutes: minutes
        )
        let content = ActivityContent(state: contentState, staleDate: nil)

        do {
            let activity = try Activity<TimerActivityAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            print("✅ Live Activity started: \(activity.id)")
        } catch {
            print("❌ Failed to start Live Activity: \(error)")
        }
    }
    
    func endLiveActivity() {
        Task {
            for activity in Activity<TimerActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
