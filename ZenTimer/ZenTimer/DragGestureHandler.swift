import SwiftUI

struct DragGestureHandler {
    static let circleRadius: CGFloat = 140  // Match CircularProgressView and DraggableHandle
    
    static func calculateProgress(from location: CGPoint, center: CGPoint) -> Double {
        let deltaX = location.x - center.x
        let deltaY = location.y - center.y
        
        // Calculate angle from top (12 o'clock position) - same as handle positioning
        var angle = atan2(deltaY, deltaX) + Double.pi / 2
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
                
                // Debug: Print coordinates to understand the issue
                print("🔍 Debug - Touch: (\(value.location.x), \(value.location.y)), Center: (\(center.x), \(center.y)), Geometry: \(geometry.size)")
                
                // Check if the touch is near the circle circumference
                if !viewModel.isDragging {
                    // Only start dragging if touch is near the circle
                    guard isNearCircle(location: value.location, center: center, radius: circleRadius) else {
                        print("🔍 Debug - Touch not near circle, ignoring")
                        return
                    }
                    
                    viewModel.isDragging = true
                    print("🔍 Debug - Started dragging")
                    // Add haptic feedback when drag starts
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
                
                let progress = calculateProgress(from: value.location, center: center)
                
                // Calculate where the handle should be at this progress for comparison
                let handleAngle = 2 * Double.pi * progress - Double.pi / 2
                let expectedHandleX = center.x + circleRadius * cos(handleAngle)
                let expectedHandleY = center.y + circleRadius * sin(handleAngle)
                let expectedHandlePos = CGPoint(x: expectedHandleX, y: expectedHandleY)
                
                print("🔍 Debug - Touch: \(value.location), Expected handle: \(expectedHandlePos), Progress: \(progress)")
                viewModel.setTime(fromProgress: progress)
            }
            .onEnded { _ in
                viewModel.isDragging = false
                viewModel.dragProgress = nil // Clear drag progress for clean state
                print("🔍 Debug - Ended dragging")
            }
    }
}