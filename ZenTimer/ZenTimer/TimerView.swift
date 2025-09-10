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
                            Text("How to Use ZenTimer")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("• Drag the handle around the circle to set your timer (1-60 minutes)\n• Tap the play button to start your focus session\n• Choose your preferred notification style from the options below\n• Enable Do Not Disturb for the most peaceful experience")
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
                            
                            Text("📳 Vibration: Gentle triple pulse pattern\n📸 Flash: Soft camera flash sequence\n🔊 Sound: Calming low chime\n🌙 Do Not Disturb: Minimal vibration only")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Contact Support")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Having issues? We're here to help!\n\nEmail: support@zentimer.app\nResponse time: Usually within 24 hours")
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
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Privacy Matters")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("ZenTimer is designed with privacy as a core principle. We believe your focus time should remain completely private.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Data Collection")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("• No personal information is collected\n• No usage analytics or tracking\n• No account creation required\n• All data stays on your device\n• No internet connection needed")
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
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Acceptance of Terms")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("By using ZenTimer, you agree to these terms of service. These terms govern your use of the app and its features.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Permitted Use")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("• Use ZenTimer for personal productivity and mindfulness\n• Respect others when using flash notifications in shared spaces\n• Do not attempt to reverse engineer or modify the app\n• Use the app in compliance with local laws and regulations")
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