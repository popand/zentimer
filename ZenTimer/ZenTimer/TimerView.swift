import SwiftUI

struct TimerView: View {
    @StateObject private var viewModel = TimerViewModel()
    
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
                
                VStack(spacing: 48) {
                    // Timer Circle Container
                    GeometryReader { timerGeometry in
                        ZStack {
                            // Circular Progress
                            CircularProgressView(progress: viewModel.progress)
                            
                            // Draggable Handle
                            if !viewModel.isRunning {
                                DraggableHandle(
                                    progress: viewModel.progress,
                                    setTimeProgress: viewModel.setTimeProgress,
                                    isDragging: viewModel.isDragging
                                )
                            }
                            
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
                        .gesture(
                            DragGestureHandler.createDragGesture(
                                viewModel: viewModel,
                                geometry: timerGeometry
                            )
                        )
                    }
                    .frame(width: 320, height: 320)
                    .padding(.horizontal, 40)
                    
                    // Time Adjustment Controls
                    TimeAdjustmentControls(viewModel: viewModel)
                    
                    // Control Buttons
                    ControlButtons(viewModel: viewModel)
                }
            }
        }
    }
}

#Preview {
    TimerView()
}