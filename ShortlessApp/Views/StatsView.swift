import SwiftUI
import Charts
import ShortlessKit

/// Usage statistics dashboard — "Time Reclaimed" hero, weekly/monthly bar chart, summary stats.
struct StatsView: View {
    @ObservedObject var blockCount: BlockCountStore
    @ObservedObject var settings: SettingsStore
    @State private var selectedRange: DateRange = .week

    enum DateRange: String, CaseIterable {
        case week = "7 Days"
        case month = "30 Days"

        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: ShortlessTheme.sectionSpacing) {
                timeReclaimedHero
                chartSection
                statsGrid
            }
            .padding(ShortlessTheme.containerPadding)
        }
        .background(ShortlessTheme.background.ignoresSafeArea())
        .navigationTitle("Your Progress")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    // MARK: - Time Reclaimed Hero

    private var timeReclaimedHero: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.arrow.counterclockwise")
                .font(.system(size: 36))
                .foregroundColor(ShortlessTheme.accent)

            Text("Time Reclaimed")
                .font(.system(size: ShortlessTheme.captionSize, weight: .semibold))
                .foregroundColor(ShortlessTheme.textTertiary)
                .textCase(.uppercase)
                .tracking(0.5)

            Text(formattedTimeReclaimed)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(ShortlessTheme.textPrimary)

            if blockCount.totalCount == 0 {
                Text("Enable Shortless in Safari to start tracking")
                    .font(.system(size: ShortlessTheme.captionSize))
                    .foregroundColor(ShortlessTheme.textTertiary)
            }

            if settings.streakDays > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(settings.streakDays) day\(settings.streakDays == 1 ? "" : "s") scroll-free")
                        .font(.system(size: ShortlessTheme.bodySize, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(ShortlessTheme.cardFill)
        .overlay(
            RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius)
                .stroke(ShortlessTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius))
    }

    // MARK: - Chart

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Range", selection: $selectedRange) {
                ForEach(DateRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)

            let data = blockCount.counts(for: selectedRange.days)

            if data.contains(where: { $0.count > 0 }) {
                Chart(data, id: \.date) { entry in
                    BarMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Blocks", entry.count)
                    )
                    .foregroundStyle(ShortlessTheme.accent)
                    .cornerRadius(3)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: selectedRange == .week ? 1 : 5)) { value in
                        AxisValueLabel(format: selectedRange == .week ? .dateTime.weekday(.abbreviated) : .dateTime.month(.abbreviated).day())
                            .foregroundStyle(ShortlessTheme.textTertiary)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(ShortlessTheme.cardBorder)
                        AxisValueLabel()
                            .foregroundStyle(ShortlessTheme.textTertiary)
                    }
                }
                .frame(height: 180)
            } else {
                emptyChartState
            }
        }
        .padding(ShortlessTheme.cardPadding)
        .background(ShortlessTheme.cardFill)
        .overlay(
            RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius)
                .stroke(ShortlessTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius))
    }

    private var emptyChartState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis.ascending")
                .font(.system(size: 32))
                .foregroundColor(ShortlessTheme.accent.opacity(0.6))
            Text("Your chart will appear here")
                .font(.system(size: ShortlessTheme.bodySize, weight: .semibold))
                .foregroundColor(ShortlessTheme.textSecondary)
            Text("Browse with Shortless enabled in Safari.\nEach blocked short builds your progress.")
                .font(.system(size: ShortlessTheme.captionSize))
                .foregroundColor(ShortlessTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: ShortlessTheme.cardSpacing) {
            statCard(title: "Today", value: "\(blockCount.todayCount)", icon: "shield.checkered")
            statCard(title: "All Time", value: "\(blockCount.totalCount)", icon: "sum")
            statCard(title: "Daily Avg", value: String(format: "%.0f", blockCount.dailyAverage), icon: "chart.line.uptrend.xyaxis")
            statCard(title: "Active Days", value: "\(blockCount.activeDays)", icon: "calendar")
        }
    }

    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(ShortlessTheme.accent)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(ShortlessTheme.textPrimary)

            Text(title)
                .font(.system(size: ShortlessTheme.captionSize))
                .foregroundColor(ShortlessTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(ShortlessTheme.cardFill)
        .overlay(
            RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius)
                .stroke(ShortlessTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius))
    }

    // MARK: - Formatting

    private var formattedTimeReclaimed: String {
        let totalSeconds = blockCount.timeReclaimed(secondsPerShort: settings.estimatedSecondsPerShort)
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "--"
        }
    }
}
