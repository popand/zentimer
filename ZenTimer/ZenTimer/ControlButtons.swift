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
        .scaleEffect(isEnabled ? 1.05 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isEnabled)
    }
}

