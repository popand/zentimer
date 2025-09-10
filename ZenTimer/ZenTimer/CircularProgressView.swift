import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let radius: CGFloat = 140
    let lineWidth: CGFloat = 6
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: lineWidth)
                .frame(width: radius * 2, height: radius * 2)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.white,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: radius * 2, height: radius * 2)
                .rotationEffect(.degrees(-90)) // Start from top
                .animation(.easeOut(duration: 0.1), value: progress)
        }
    }
}

struct DraggableHandle: View {
    let progress: Double
    let setTimeProgress: Double  // Progress based on set time, not remaining time
    let radius: CGFloat = 150
    let isDragging: Bool
    
    var handlePosition: CGPoint {
        // Use setTimeProgress for handle position so it represents the set time, not remaining time
        let angle = 2 * Double.pi * setTimeProgress - Double.pi / 2 // Start from top
        let x = radius * cos(angle)
        let y = radius * sin(angle)
        return CGPoint(x: x, y: y)
    }
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 20, height: 20)
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            .scaleEffect(isDragging ? 1.3 : 1.0)
            .position(
                x: 160 + handlePosition.x,
                y: 160 + handlePosition.y
            )
            .animation(
                isDragging ? .none : .easeOut(duration: 0.2),
                value: isDragging
            )
    }
}