import SwiftUI

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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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