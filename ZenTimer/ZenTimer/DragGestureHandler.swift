import SwiftUI

struct DragGestureHandler {
    static let circleRadius: CGFloat = 140  // Match CircularProgressView and DraggableHandle
    
    static func calculateProgress(from location: CGPoint, center: CGPoint) -> Double {
        let deltaX = location.x - center.x
        let deltaY = location.y - center.y
        
        // Calculate angle from top (12 o'clock position)
        var angle = atan2(deltaX, -deltaY)
        if angle < 0 {
            angle += 2 * Double.pi
        }
        
        // Convert angle to progress (0 to 1)
        let progress = angle / (2 * Double.pi)
        
        return progress
    }
    
    static func isNearCircle(location: CGPoint, center: CGPoint, radius: CGFloat, tolerance: CGFloat = 30) -> Bool {
        let distance = sqrt(pow(location.x - center.x, 2) + pow(location.y - center.y, 2))
        return abs(distance - radius) <= tolerance
    }
    
    static func createDragGesture(
        viewModel: TimerViewModel,
        geometry: GeometryProxy
    ) -> some Gesture {
        DragGesture(coordinateSpace: .local)
            .onChanged { value in
                guard !viewModel.isRunning else { return }
                
                let center = CGPoint(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )
                
                // Check if the touch is near the circle circumference
                if !viewModel.isDragging {
                    // Only start dragging if touch is near the circle
                    guard isNearCircle(location: value.location, center: center, radius: circleRadius) else {
                        return
                    }
                    
                    viewModel.isDragging = true
                    // Add haptic feedback when drag starts
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
                
                let progress = calculateProgress(from: value.location, center: center)
                viewModel.setTime(fromProgress: progress)
            }
            .onEnded { _ in
                viewModel.isDragging = false
                viewModel.dragProgress = nil // Clear drag progress for clean state
            }
    }
}