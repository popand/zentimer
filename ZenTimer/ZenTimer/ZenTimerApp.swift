import SwiftUI
import BackgroundTasks
import UserNotifications

@main
struct ZenTimerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permissions granted")
            } else {
                print("❌ Notification permissions denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        // Register background tasks
        registerBackgroundTasks()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleBackgroundAppRefresh()
    }
    
    private func registerBackgroundTasks() {
        // Register background app refresh task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.zentimer.background-refresh", using: nil) { task in
            self.handleBackgroundAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        // Register background processing task (for longer running tasks)
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.zentimer.background-processing", using: nil) { task in
            self.handleBackgroundProcessing(task: task as! BGProcessingTask)
        }
    }
    
    private func scheduleBackgroundAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.zentimer.background-refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Background app refresh scheduled")
        } catch {
            print("❌ Could not schedule background app refresh: \(error)")
        }
    }
    
    private func handleBackgroundAppRefresh(task: BGAppRefreshTask) {
        // Schedule a new background app refresh
        scheduleBackgroundAppRefresh()
        
        // Set expiration handler
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Perform background work
        DispatchQueue.global().async {
            // Check if there are any active timers and update Live Activities
            // This is where you would sync timer state if needed
            print("🔄 Background app refresh executed")
            task.setTaskCompleted(success: true)
        }
    }
    
    private func handleBackgroundProcessing(task: BGProcessingTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Perform longer background work if needed
        DispatchQueue.global().async {
            print("🔄 Background processing executed")
            task.setTaskCompleted(success: true)
        }
    }
}