import ActivityKit
import Foundation
import UIKit

@available(iOS 16.1, *)
class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<TimerActivityAttributes>?
    
    private init() {}
    
    // MARK: - Live Activity Management
    
    func startLiveActivity(totalTime: TimeInterval, remainingTime: TimeInterval, isRunning: Bool) {
        print("🚀 Starting Live Activity - iOS Version: \(UIDevice.current.systemVersion)")
        
        // End any existing activity first
        endLiveActivity()
        
        let authInfo = ActivityAuthorizationInfo()
        print("📱 Live Activities enabled: \(authInfo.areActivitiesEnabled)")
        print("📱 Activity authorization status: \(authInfo.areActivitiesEnabled)")
        
        guard authInfo.areActivitiesEnabled else {
            print("❌ Live Activities are not enabled in system settings")
            print("💡 Enable in Settings > Face ID & Attention > Live Activities")
            return
        }
        
        let attributes = TimerActivityAttributes(timerName: "Focus Timer")
        let contentState = TimerActivityAttributes.ContentState(
            remainingTime: remainingTime,
            totalTime: totalTime,
            isRunning: isRunning,
            startTime: Date()
        )
        
        print("🎯 Requesting Live Activity with:")
        print("   - Total time: \(totalTime)s")
        print("   - Remaining time: \(remainingTime)s") 
        print("   - Is running: \(isRunning)")
        
        do {
            currentActivity = try Activity<TimerActivityAttributes>.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            print("✅ Live Activity started successfully!")
            print("🆔 Activity ID: \(currentActivity?.id ?? "unknown")")
            print("📱 Activity state: \(String(describing: currentActivity?.activityState))")
        } catch {
            print("❌ Error starting Live Activity: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            print("❌ Error type: \(type(of: error))")
            
            // Handle specific ActivityKit errors if available
            if let nsError = error as NSError? {
                print("❌ Error domain: \(nsError.domain)")
                print("❌ Error code: \(nsError.code)")
                print("❌ Error userInfo: \(nsError.userInfo)")
            }
        }
    }
    
    func updateLiveActivity(remainingTime: TimeInterval, totalTime: TimeInterval, isRunning: Bool) {
        guard let activity = currentActivity else {
            print("⚠️ No active Live Activity to update")
            return
        }
        
        let updatedContentState = TimerActivityAttributes.ContentState(
            remainingTime: remainingTime,
            totalTime: totalTime,
            isRunning: isRunning,
            startTime: Date()
        )
        
        Task {
            await activity.update(using: updatedContentState)
            print("🔄 Live Activity updated - Time: \(Int(remainingTime))s, Running: \(isRunning)")
        }
    }
    
    func endLiveActivity() {
        guard let activity = currentActivity else { return }
        
        let finalContentState = TimerActivityAttributes.ContentState(
            remainingTime: 0,
            totalTime: activity.contentState.totalTime,
            isRunning: false,
            startTime: activity.contentState.startTime
        )
        
        Task {
            await activity.end(using: finalContentState, dismissalPolicy: .immediate)
            print("🏁 Live Activity ended")
        }
        
        currentActivity = nil
    }
    
    // MARK: - Activity State
    
    var isActivityActive: Bool {
        return currentActivity != nil
    }
    
    func requestActivityAuthorization() async -> Bool {
        let authorizationInfo = ActivityAuthorizationInfo()
        
        if authorizationInfo.areActivitiesEnabled {
            return true
        }
        
        // For iOS 16.1+, activities are controlled by system settings
        // We can't programmatically request permission, but we can check status
        print("Live Activities need to be enabled in Settings > Focus > Focus Filters")
        return false
    }
}

// MARK: - Helper Extensions
@available(iOS 16.1, *)
extension LiveActivityManager {
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func shouldShowLiveActivity() -> Bool {
        guard #available(iOS 16.1, *) else { return false }
        return ActivityAuthorizationInfo().areActivitiesEnabled
    }
}
