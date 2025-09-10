import SwiftUI

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