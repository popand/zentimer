import WidgetKit
import SwiftUI

struct ZenTimerWidget: Widget {
    let kind: String = "ZenTimerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ZenTimerWidgetView(entry: entry)
        }
        .configurationDisplayName("ZenTimer")
        .description("Quick access to your meditation timer")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TimerEntry {
        TimerEntry(date: Date(), isRunning: false, timeRemaining: 300)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TimerEntry) -> Void) {
        let entry = TimerEntry(date: Date(), isRunning: false, timeRemaining: 300)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TimerEntry>) -> Void) {
        // Read timer state from UserDefaults or App Group
        let entry = TimerEntry(date: Date(), isRunning: false, timeRemaining: 300)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60)))
        completion(timeline)
    }
}

struct TimerEntry: TimelineEntry {
    let date: Date
    let isRunning: Bool
    let timeRemaining: Int
}

struct ZenTimerWidgetView: View {
    var entry: TimerEntry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularWidgetView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    var entry: TimerEntry
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 251/255, green: 146/255, blue: 60/255),
                    Color(red: 239/255, green: 68/255, blue: 68/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 4) {
                Text(formatTime(entry.timeRemaining))
                    .font(.system(size: 32, weight: .ultraLight, design: .default))
                    .foregroundColor(.white)
                
                Text(entry.isRunning ? "Running" : "Tap to Start")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

struct MediumWidgetView: View {
    var entry: TimerEntry
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 251/255, green: 146/255, blue: 60/255),
                    Color(red: 239/255, green: 68/255, blue: 68/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ZenTimer")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(formatTime(entry.timeRemaining))
                        .font(.system(size: 40, weight: .ultraLight, design: .default))
                        .foregroundColor(.white)
                    
                    Text(entry.isRunning ? "Timer Running" : "Ready to Begin")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: entry.isRunning ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

struct AccessoryCircularWidgetView: View {
    var entry: TimerEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: entry.isRunning ? "timer" : "timer.circle")
                    .font(.caption)
                Text("\(entry.timeRemaining / 60)m")
                    .font(.caption2)
            }
        }
    }
}

struct AccessoryRectangularWidgetView: View {
    var entry: TimerEntry
    
    var body: some View {
        HStack {
            Image(systemName: entry.isRunning ? "timer" : "timer.circle")
            VStack(alignment: .leading) {
                Text("ZenTimer")
                    .font(.caption2)
                Text(formatTime(entry.timeRemaining))
                    .font(.caption)
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

#Preview("Small", as: .systemSmall) {
    ZenTimerWidget()
} timeline: {
    TimerEntry(date: Date(), isRunning: false, timeRemaining: 300)
    TimerEntry(date: Date(), isRunning: true, timeRemaining: 180)
}
