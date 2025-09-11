import SwiftUI

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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
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