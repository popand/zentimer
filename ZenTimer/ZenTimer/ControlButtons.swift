import SwiftUI

struct ControlButtons: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        HStack(spacing: 24) {
            // Play/Pause Button
            Button(action: {
                viewModel.toggleTimer()
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }) {
                Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.2))
                            .background(.ultraThinMaterial)
                    )
                    .clipShape(Circle())
            }
            .accessibilityIdentifier(viewModel.isRunning ? "pause.fill" : "play.fill")
            .accessibilityLabel(viewModel.isRunning ? "Pause" : "Play")
            .scaleEffect(viewModel.isRunning ? 1.05 : 1.0)
            .animation(.easeOut(duration: 0.2), value: viewModel.isRunning)
            
            // Reset Button
            Button(action: {
                viewModel.resetTimer()
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.2))
                            .background(.ultraThinMaterial)
                    )
                    .clipShape(Circle())
            }
            .accessibilityIdentifier("arrow.clockwise")
            .accessibilityLabel("Reset")
        }
    }
}

struct NotificationMessage: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        if viewModel.showNotificationMessage {
            Text(viewModel.notificationMessage)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.15))
                        .background(.ultraThinMaterial)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                    removal: .opacity.combined(with: .move(edge: .bottom))
                ))
                .animation(.easeOut(duration: 0.3), value: viewModel.showNotificationMessage)
        }
    }
}

struct NotificationButtons: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Camera Flash Button
            NotificationToggleButton(
                isEnabled: viewModel.flashEnabled,
                icon: "flashlight.on.fill",
                action: viewModel.toggleFlash
            )
            
            // Vibration Button
            NotificationToggleButton(
                isEnabled: viewModel.vibrationEnabled,
                icon: "iphone.radiowaves.left.and.right",
                action: viewModel.toggleVibration
            )
            
            // Sound Button
            NotificationToggleButton(
                isEnabled: viewModel.soundEnabled,
                icon: "speaker.wave.1.fill",
                action: viewModel.toggleSound
            )
            
            // Do Not Disturb Button
            NotificationToggleButton(
                isEnabled: viewModel.doNotDisturbEnabled,
                icon: "moon.fill",
                action: viewModel.toggleDoNotDisturb
            )
        }
    }
}

struct NotificationToggleButton: View {
    let isEnabled: Bool
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(isEnabled ? .white : .white.opacity(0.4))
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(isEnabled ? .white.opacity(0.3) : .white.opacity(0.1))
                        .background(.ultraThinMaterial)
                )
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        }
        .accessibilityIdentifier(icon)
        .accessibilityLabel(accessibilityLabelForIcon(icon))
        .scaleEffect(isEnabled ? 1.05 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isEnabled)
    }

    private func accessibilityLabelForIcon(_ icon: String) -> String {
        switch icon {
        case "flashlight.on.fill":
            return "Flash"
        case "iphone.radiowaves.left.and.right":
            return "Vibration"
        case "speaker.wave.1.fill":
            return "Sound"
        case "moon.fill":
            return "Do Not Disturb"
        default:
            return "Toggle"
        }
    }
}

