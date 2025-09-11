import SwiftUI
import Foundation

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


#Preview {
    TimerView()
}