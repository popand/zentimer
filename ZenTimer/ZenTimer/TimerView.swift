import SwiftUI

struct TimerView: View {
    @StateObject private var viewModel = TimerViewModel()
    @State private var showingSettings = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 251/255, green: 146/255, blue: 60/255),  // orange-400
                        Color(red: 239/255, green: 68/255, blue: 68/255),   // red-500
                        Color(red: 220/255, green: 38/255, blue: 38/255)    // red-600
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Timer Circle Container - Fixed center positioning
                    GeometryReader { timerGeometry in
                        ZStack {
                            // Circular Progress
                            CircularProgressView(progress: viewModel.progress)
                            
                            // Draggable Handle - Always present but hidden when running
                            DraggableHandle(
                                progress: viewModel.progress,
                                setTimeProgress: viewModel.setTimeProgress,
                                isDragging: viewModel.isDragging
                            )
                            .opacity(viewModel.isRunning ? 0 : 1)
                            .allowsHitTesting(!viewModel.isRunning)
                            
                            // Time Display in Center
                            VStack(spacing: 8) {
                                Text(viewModel.formattedTime)
                                    .font(.system(size: 64, weight: .ultraLight, design: .default))
                                    .foregroundColor(.white)
                                    .tracking(4)
                                    .monospacedDigit()
                                
                                Text(viewModel.statusText)
                                    .font(.system(size: 18, weight: .light))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .frame(width: timerGeometry.size.width, height: timerGeometry.size.height)
                        .position(x: timerGeometry.size.width / 2, y: timerGeometry.size.height / 2)
                        .gesture(
                            DragGestureHandler.createDragGesture(
                                viewModel: viewModel,
                                geometry: timerGeometry
                            )
                        )
                    }
                    .frame(width: 320, height: 320)
                    
                    // Control Buttons
                    ControlButtons(viewModel: viewModel)
                    
                    // Notification Options
                    NotificationButtons(viewModel: viewModel)
                    
                    // Notification Message (appears temporarily)
                    NotificationMessage(viewModel: viewModel)
                        .padding(.top, 16)
                }
                
                // Settings Button - Top Right
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            showingSettings.toggle()
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(.white.opacity(0.15))
                                        .background(.ultraThinMaterial)
                                )
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .padding(.top, 60)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SimpleSettingsView()
        }
    }
}

struct SimpleSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingHelpSupport = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 251/255, green: 146/255, blue: 60/255),
                        Color(red: 239/255, green: 68/255, blue: 68/255),
                        Color(red: 220/255, green: 38/255, blue: 38/255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("App Information")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("Version:")
                                .foregroundColor(.white)
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        HStack {
                            Text("Build:")
                                .foregroundColor(.white)
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Resources")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 0) {
                            // Help & Support
                            Button(action: {
                                showingHelpSupport = true
                            }) {
                                HStack {
                                    Circle()
                                        .fill(.blue)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "questionmark")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                    
                                    Text("Help & Support")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .background(.white.opacity(0.2))
                                .padding(.leading, 64)
                            
                            // Privacy Policy
                            Button(action: {
                                showingPrivacyPolicy = true
                            }) {
                                HStack {
                                    Circle()
                                        .fill(.green)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "lock.shield.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white)
                                        )
                                    
                                    Text("Privacy Policy")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .background(.white.opacity(0.2))
                                .padding(.leading, 64)
                            
                            // Terms of Service
                            Button(action: {
                                showingTermsOfService = true
                            }) {
                                HStack {
                                    Circle()
                                        .fill(.purple)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "doc.text.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white)
                                        )
                                    
                                    Text("Terms of Service")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .cornerRadius(12)
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Copyright Notice
                    Text("© 2025 ZenTimer. All rights reserved.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .sheet(isPresented: $showingHelpSupport) {
            HelpSupportView()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingTermsOfService) {
            TermsOfServiceView()
        }
    }
}

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 251/255, green: 146/255, blue: 60/255),
                        Color(red: 239/255, green: 68/255, blue: 68/255),
                        Color(red: 220/255, green: 38/255, blue: 38/255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Help & Support")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Getting Started")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("1. Set Your Timer\n• Drag the circular handle to set your desired focus time (1-60 minutes)\n• The timer display shows your selected duration\n\n2. Choose Notifications\n• Tap the notification icons to customize your alerts\n• Mix and match vibration, flash, and sound options\n\n3. Start Your Session\n• Tap the play button to begin your focus session\n• Use the pause button if you need a brief interruption\n• Tap reset to start over anytime")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Notification Options")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("📳 Vibration: Gentle triple pulse pattern for subtle alerts\n📸 Flash: Soft camera flash sequence that won't disturb others\n🔊 Sound: Calming low chime designed for focus\n🌙 Do Not Disturb: Only vibration when iOS Focus modes are active\n\nTip: Combine different notification types for the perfect alert that matches your environment.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Frequently Asked Questions")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Q: Why doesn't the timer work in the background?\nA: iOS apps are limited in background processing. Keep ZenTimer open for best results.\n\nQ: Can I set timers longer than 60 minutes?\nA: Currently, ZenTimer focuses on 1-60 minute sessions for optimal productivity.\n\nQ: Do notifications work when my phone is silent?\nA: Vibration works in silent mode. Flash notifications also work regardless of sound settings.\n\nQ: Is ZenTimer completely offline?\nA: Yes! ZenTimer requires no internet connection and collects no data.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Troubleshooting")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Flash Not Working:\n• Ensure camera permission is granted in iOS Settings\n• Check if your device has a flash/torch\n\nNotifications Not Appearing:\n• Verify notifications are enabled in iOS Settings > ZenTimer\n• Check Do Not Disturb and Focus mode settings\n\nTimer Stops Unexpectedly:\n• Keep ZenTimer in foreground for best performance\n• Close other memory-intensive apps\n• Restart the app if issues persist")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Contact & Support")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Need help or have feedback? We'd love to hear from you!")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 12) {
                                // Email Support Button
                                Button(action: {
                                    if let url = URL(string: "mailto:thezentimerapp@gmail.com?subject=ZenTimer Support") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "envelope.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Email Support")
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundColor(.white)
                                            Text("thezentimerapp@gmail.com")
                                                .font(.system(size: 13))
                                                .foregroundColor(.blue.opacity(0.9))
                                            Text("Response time: Usually within 24-48 hours")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(.white.opacity(0.1))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Bug Reports Button
                                Button(action: {
                                    if let url = URL(string: "https://github.com/popand/zentimer/issues") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "ladybug.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Bug Reports & Feature Requests")
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundColor(.white)
                                            Text("https://github.com/popand/zentimer/issues")
                                                .font(.system(size: 13))
                                                .foregroundColor(.blue.opacity(0.9))
                                            Text("Our GitHub Issues page for technical reports")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(.white.opacity(0.1))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Text("Please include your iOS version and detailed steps when reporting issues.")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 8)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                }
            }
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 251/255, green: 146/255, blue: 60/255),
                        Color(red: 239/255, green: 68/255, blue: 68/255),
                        Color(red: 220/255, green: 38/255, blue: 38/255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Privacy Policy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                        
                        Text("Last updated: January 10, 2025")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.bottom, 16)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Privacy-First Design")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("ZenTimer is designed with privacy as a core principle. We believe your focus time should remain completely private and under your control.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Zero Data Collection")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("ZenTimer collects NO user data or anonymous data whatsoever:\n\n• No personal information\n• No usage analytics or tracking\n• No crash reports or diagnostics\n• No account creation required\n• All settings stay on your device\n• No internet connection needed")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Device Permissions")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("ZenTimer only requests permissions necessary for core functionality:\n\n• Camera access: Only for optional flash notifications (never for recording)\n• Focus Status: To enhance Do Not Disturb features with iOS integration\n• Local notifications: For gentle timer completion alerts\n\nAll permissions are optional and can be revoked anytime in iOS Settings.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Local Storage Only")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("All app settings and preferences are stored locally on your device using iOS's secure storage. We maintain no servers, databases, or cloud storage for user data.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Third-Party Services")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("ZenTimer does not integrate with any third-party analytics, advertising, or tracking services. The app functions entirely offline and makes no network connections.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Children's Privacy")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("ZenTimer is safe for users of all ages. Since we collect no data whatsoever, there are no privacy concerns for children using the app.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Contact Us")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("If you have questions about this Privacy Policy:\n\nEmail: thezentimerapp@gmail.com\nResponse time: Usually within 24 hours")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                }
            }
        }
    }
}

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 251/255, green: 146/255, blue: 60/255),
                        Color(red: 239/255, green: 68/255, blue: 68/255),
                        Color(red: 220/255, green: 38/255, blue: 38/255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Terms of Service")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                        
                        Text("Effective Date: January 10, 2025")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.bottom, 16)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Welcome to ZenTimer!")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("These Terms of Service (\"Terms\") govern your use of our iOS timer application. By downloading, installing, or using ZenTimer, you acknowledge that you have read, understood, and agree to be bound by these Terms.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("1. Description of Service")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("ZenTimer is a focus and productivity timer application that:\n• Provides customizable countdown timers (1-60 minutes)\n• Offers gentle notification options (vibration, flash, sound)\n• Integrates with iOS Focus and Do Not Disturb modes\n• Operates completely offline with no data collection\n• Requires no account creation or internet connection")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("2. User Requirements & Responsibilities")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("To use ZenTimer, you must:\n• Be at least 13 years of age (safe for all ages due to no data collection)\n• Use the app in compliance with all applicable laws\n• Respect others when using flash notifications in shared spaces\n• Not attempt to reverse engineer, modify, or redistribute the app\n• Use the app for its intended purpose of productivity and focus")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("3. Device Permissions")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("ZenTimer may request optional permissions:\n• Camera access: Only for flash notifications (never for recording)\n• Local notifications: For timer completion alerts\n• Focus Status: To enhance Do Not Disturb integration\n\nAll permissions are optional and can be revoked through iOS Settings without affecting core timer functionality.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("4. Intellectual Property")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("ZenTimer and its original content, features, design, and functionality are owned by the app developers and are protected by international copyright, trademark, and other intellectual property laws.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("5. Disclaimer of Warranties")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("THE APP IS PROVIDED \"AS IS\" AND \"AS AVAILABLE\" WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED. WE DO NOT WARRANT THAT THE APP WILL BE UNINTERRUPTED, ERROR-FREE, OR FREE OF HARMFUL COMPONENTS. USE DISCRETION FOR TIME-SENSITIVE ACTIVITIES.")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("6. Limitation of Liability")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("TO THE MAXIMUM EXTENT PERMITTED BY LAW, IN NO EVENT SHALL WE BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES ARISING OUT OF YOUR USE OF ZENTIMER. USE YOUR OWN JUDGMENT FOR IMPORTANT TIMING.")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("7. Changes to Terms")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("We may modify these Terms at any time. We will notify users of any material changes by updating the \"Effective Date\" and providing notice within the app. Your continued use after changes constitutes acceptance of the modified Terms.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("8. Termination")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("You may stop using ZenTimer at any time by deleting the app from your device. Since we collect no data, no additional steps are required for account closure or data deletion.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("9. Contact Information")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("For questions about these Terms of Service:\n\nEmail: thezentimerapp@gmail.com\nGitHub Issues: https://github.com/popand/zentimer/issues\n\nWe typically respond within 24-48 hours.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                }
            }
        }
    }
}

#Preview {
    TimerView()
}