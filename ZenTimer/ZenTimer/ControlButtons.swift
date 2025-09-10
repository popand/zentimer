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

struct TimeAdjustmentControls: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        if !viewModel.isRunning && viewModel.timeLeft == viewModel.totalSeconds {
            HStack(spacing: 24) {
                // Minus Button
                Button(action: {
                    viewModel.adjustMinutes(by: -1)
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(
                            Circle()
                                .fill(.white.opacity(0.2))
                                .background(.ultraThinMaterial)
                        )
                        .clipShape(Circle())
                }
                
                // Minutes Display
                Text("\(viewModel.minutes) min")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(.white)
                    .frame(minWidth: 60)
                
                // Plus Button
                Button(action: {
                    viewModel.adjustMinutes(by: 1)
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
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
}