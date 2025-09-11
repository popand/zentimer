import SwiftUI

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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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