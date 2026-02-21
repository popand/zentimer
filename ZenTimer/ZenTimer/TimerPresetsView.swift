import SwiftUI

struct TimerPreset: Identifiable, Codable {
    var id: UUID
    var name: String
    var minutes: Int
    var icon: String
    var colorName: String

    var color: Color {
        switch colorName {
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "red": return .red
        case "pink": return .pink
        case "yellow": return .yellow
        case "teal": return .teal
        default: return .blue
        }
    }

    init(id: UUID = UUID(), name: String, minutes: Int, icon: String, colorName: String) {
        self.id = id
        self.name = name
        self.minutes = minutes
        self.icon = icon
        self.colorName = colorName
    }

    static let defaults: [TimerPreset] = [
        TimerPreset(name: "Quick Focus", minutes: 5, icon: "leaf.fill", colorName: "green"),
        TimerPreset(name: "Standard", minutes: 10, icon: "moon.fill", colorName: "blue"),
        TimerPreset(name: "Deep Session", minutes: 20, icon: "sparkles", colorName: "purple"),
        TimerPreset(name: "Extended", minutes: 30, icon: "star.fill", colorName: "orange")
    ]
}

struct TimerPresetsView: View {
    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Start")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .padding(.leading, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.presets) { preset in
                        PresetButton(preset: preset, viewModel: viewModel)
                    }
                }
            }
        }
    }
}

struct PresetButton: View {
    let preset: TimerPreset
    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        Button(action: {
            viewModel.setPresetTime(minutes: preset.minutes)
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }) {
            VStack(spacing: 8) {
                Image(systemName: preset.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(preset.color.opacity(0.3))
                    )

                VStack(spacing: 2) {
                    Text(preset.name)
                        .font(.caption2)
                        .fontWeight(.medium)
                    Text("\(preset.minutes) min")
                        .font(.caption2)
                        .opacity(0.8)
                }
                .foregroundColor(.white)
            }
            .frame(width: 80)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.1))
            )
        }
        .disabled(viewModel.isRunning)
        .opacity(viewModel.isRunning ? 0.5 : 1.0)
    }
}

// Extension to TimerViewModel
extension TimerViewModel {
    func setPresetTime(minutes: Int) {
        guard !isRunning else { return }

        self.minutes = minutes
        let newTotal = minutes * 60
        self.totalSeconds = newTotal
        self.timeLeft = newTotal
        self.dragProgress = Double(minutes) / 60.0
    }
}

#Preview {
    TimerPresetsView(viewModel: TimerViewModel())
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 251/255, green: 146/255, blue: 60/255),
                    Color(red: 239/255, green: 68/255, blue: 68/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
