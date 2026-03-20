import WidgetKit
import SwiftUI
import ShortlessKit

// MARK: - Timeline Entry

struct ShortlessEntry: TimelineEntry {
    let date: Date
    let todayCount: Int
    let totalCount: Int
    let streakDays: Int
    let timeReclaimedSeconds: TimeInterval
}

// MARK: - Timeline Provider

struct ShortlessProvider: TimelineProvider {
    func placeholder(in context: Context) -> ShortlessEntry {
        ShortlessEntry(date: .now, todayCount: 42, totalCount: 1234, streakDays: 7, timeReclaimedSeconds: 18510)
    }

    func getSnapshot(in context: Context, completion: @escaping (ShortlessEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ShortlessEntry>) -> Void) {
        let entry = makeEntry()
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: entry.date) ?? entry.date
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func makeEntry() -> ShortlessEntry {
        let blockStore = BlockCountStore()
        let settings = SettingsStore()
        return ShortlessEntry(
            date: .now,
            todayCount: blockStore.todayCount,
            totalCount: blockStore.totalCount,
            streakDays: settings.streakDays,
            timeReclaimedSeconds: blockStore.timeReclaimed(secondsPerShort: settings.estimatedSecondsPerShort)
        )
    }
}

// MARK: - Widget Definition

struct ShortlessWidget: Widget {
    let kind = "ShortlessWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShortlessProvider()) { entry in
            ShortlessWidgetView(entry: entry)
        }
        .configurationDisplayName("Shortless")
        .description("Track your blocking activity and scroll-free streak.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}

// MARK: - Widget Views

struct ShortlessWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: ShortlessEntry

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .accessoryCircular:
            circularWidget
        default:
            smallWidget
        }
    }

    // MARK: - Small Widget

    private var smallWidget: some View {
        VStack(spacing: 6) {
            if entry.streakDays > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                    Text("\(entry.streakDays)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Text(entry.streakDays == 1 ? "day scroll-free" : "days scroll-free")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            } else {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "#3ABAB4"))
                Text("Shortless")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }

            Spacer().frame(height: 4)

            HStack(spacing: 4) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "#3ABAB4"))
                Text("\(entry.todayCount) today")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetBackground(Color(hex: "#1a1a2e"))
    }

    // MARK: - Medium Widget

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            // Left: Streak
            VStack(spacing: 4) {
                if entry.streakDays > 0 {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.orange)
                    Text("\(entry.streakDays)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(entry.streakDays == 1 ? "day" : "days")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                } else {
                    Image(systemName: "eye.slash.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "#3ABAB4"))
                    Text("Shortless")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 1)
                .padding(.vertical, 8)

            // Right: Stats
            VStack(alignment: .leading, spacing: 8) {
                statRow(icon: "clock.arrow.counterclockwise", label: "Reclaimed", value: formattedTime)
                statRow(icon: "shield.checkered", label: "Today", value: "\(entry.todayCount)")
                statRow(icon: "sum", label: "All time", value: "\(entry.totalCount)")
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetBackground(Color(hex: "#1a1a2e"))
    }

    private func statRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "#3ABAB4"))
                .frame(width: 16)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.gray)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
    }

    // MARK: - Lock Screen (Circular)

    private var circularWidget: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: entry.streakDays > 0 ? "flame.fill" : "eye.slash.fill")
                    .font(.system(size: 12))
                Text(entry.streakDays > 0 ? "\(entry.streakDays)d" : "\(entry.todayCount)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
        }
    }

    // MARK: - Formatting

    private var formattedTime: String {
        let hours = Int(entry.timeReclaimedSeconds) / 3600
        let minutes = (Int(entry.timeReclaimedSeconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "--"
        }
    }
}

// MARK: - Widget Background Modifier

extension View {
    @ViewBuilder
    func widgetBackground(_ color: Color) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            self.containerBackground(for: .widget) { color }
        } else {
            self.background(color)
        }
    }
}

// MARK: - Color Extension (duplicated for widget target)

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}
