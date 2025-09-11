import ActivityKit
import WidgetKit
import SwiftUI
import UIKit

// MARK: - Simplified Live Activity Implementation
@available(iOS 16.1, *)
extension LiveActivityManager {
    
    func startSimpleLiveActivity(totalTime: TimeInterval, remainingTime: TimeInterval, isRunning: Bool) {
        print("🚀 Starting SIMPLE Live Activity - iOS Version: \(UIDevice.current.systemVersion)")
        
        // End any existing activity first
        endLiveActivity()
        
        // Check if Live Activities are supported and enabled
        let authInfo = ActivityAuthorizationInfo()
        print("📱 Live Activities enabled: \(authInfo.areActivitiesEnabled)")
        
        guard authInfo.areActivitiesEnabled else {
            print("❌ Live Activities are not enabled")
            print("💡 Please enable Live Activities in Settings")
            showSystemSettingsAlert()
            return
        }
        
        let attributes = TimerActivityAttributes(timerName: "ZenTimer Focus")
        let contentState = TimerActivityAttributes.ContentState(
            remainingTime: remainingTime,
            totalTime: totalTime,
            isRunning: isRunning,
            startTime: Date()
        )
        
        print("🎯 Requesting Live Activity...")
        
        do {
            let activity = try Activity<TimerActivityAttributes>.request(
                attributes: attributes,
                contentState: contentState
            )
            currentActivity = activity
            print("✅ Live Activity started successfully!")
            print("🆔 Activity ID: \(activity.id)")
            print("📱 Activity state: \(activity.activityState)")
        } catch {
            print("❌ Error starting Live Activity: \(error)")
            handleLiveActivityError(error)
        }
    }
    
    private func handleLiveActivityError(_ error: Error) {
        print("❌ Live Activity Error: \(error.localizedDescription)")
        print("❌ Error type: \(type(of: error))")
        
        if let nsError = error as NSError? {
            print("❌ Error domain: \(nsError.domain)")
            print("❌ Error code: \(nsError.code)")
            
            // Handle common error cases
            switch nsError.code {
            case -1:
                print("💡 Suggestion: Live Activities may not be enabled in Settings")
            case -2:
                print("💡 Suggestion: Check app permissions for Live Activities")
            default:
                print("💡 Suggestion: Check device compatibility and iOS version")
            }
        }
    }
    
    private func showSystemSettingsAlert() {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else { return }
            
            let alert = UIAlertController(
                title: "Enable Live Activities", 
                message: "To see the timer in Dynamic Island, please enable Live Activities in Settings → Face ID & Attention → Live Activities",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            window.rootViewController?.present(alert, animated: true)
        }
    }
}