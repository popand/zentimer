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
    let radius: CGFloat = 140    // Match CircularProgressView radius
    let isDragging: Bool
    
    func handlePosition(for geometry: GeometryProxy) -> CGPoint {
        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        // Use setTimeProgress for handle position so it represents the set time, not remaining time
        let angle = 2 * Double.pi * setTimeProgress - Double.pi / 2 // Start from top
        let x = center.x + radius * cos(angle)
        let y = center.y + radius * sin(angle)
        let position = CGPoint(x: x, y: y)
        print("🎯 Debug - Handle position: \(position), angle: \(angle), progress: \(setTimeProgress), center: \(center), geometry: \(geometry.size)")
        return position
    }
    
    var body: some View {
        GeometryReader { geometry in
            let position = handlePosition(for: geometry)
            
            ZStack {
                // Larger invisible touch target for better touch detection
                Circle()
                    .fill(Color.clear)
                    .frame(width: 44, height: 44) // Standard iOS touch target size
                    .position(position)
                
                // Visible handle
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .scaleEffect(isDragging ? 1.3 : 1.0)
                    .position(position)
                    .animation(
                        isDragging ? .none : .easeOut(duration: 0.2),
                        value: isDragging
                    )
            }
        }
    }
}