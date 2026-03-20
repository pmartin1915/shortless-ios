import Foundation

/// Manages daily block counts via App Group UserDefaults.
/// Key format: "blocks_YYYY-MM-DD" — matches browser extension format.
public final class BlockCountStore: ObservableObject {
    private let defaults: UserDefaults

    @Published public private(set) var todayCount: Int

    public init() {
        guard let defaults = UserDefaults(suiteName: SettingsStore.appGroupID) else {
            fatalError("[Shortless] App Group '\(SettingsStore.appGroupID)' is not configured. Check Signing & Capabilities → App Groups for all targets.")
        }
        self.defaults = defaults
        self.todayCount = defaults.integer(forKey: BlockCountStore.todayKey())
    }

    public func increment(by count: Int = 1) {
        let key = BlockCountStore.todayKey()
        let current = defaults.integer(forKey: key)
        let updated = current + count
        defaults.set(updated, forKey: key)
        todayCount = updated
    }

    public func refresh() {
        todayCount = defaults.integer(forKey: BlockCountStore.todayKey())
    }

    // MARK: - Historical Data

    /// Block count for a specific date.
    public func count(for date: Date) -> Int {
        defaults.integer(forKey: BlockCountStore.key(for: date))
    }

    /// Daily block counts for a date range, sorted chronologically.
    public func counts(for days: Int) -> [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<days).compactMap { offset -> (date: Date, count: Int)? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return (date: date, count: defaults.integer(forKey: BlockCountStore.key(for: date)))
        }.reversed()
    }

    /// Total blocks across all recorded days.
    public var totalCount: Int {
        let dict = defaults.dictionaryRepresentation()
        return dict.keys
            .filter { $0.hasPrefix("blocks_") }
            .reduce(0) { sum, key in sum + (dict[key] as? Int ?? 0) }
    }

    /// Number of days with at least one block recorded.
    public var activeDays: Int {
        let dict = defaults.dictionaryRepresentation()
        return dict.keys
            .filter { $0.hasPrefix("blocks_") && (dict[$0] as? Int ?? 0) > 0 }
            .count
    }

    /// Average daily blocks (across active days only).
    public var dailyAverage: Double {
        let days = activeDays
        guard days > 0 else { return 0 }
        return Double(totalCount) / Double(days)
    }

    /// Estimated time reclaimed based on average seconds per short-form video.
    public func timeReclaimed(secondsPerShort: Int = 15) -> TimeInterval {
        return TimeInterval(totalCount * secondsPerShort)
    }

    // MARK: - Keys

    public static func todayKey() -> String {
        key(for: Date())
    }

    public static func key(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "blocks_\(formatter.string(from: date))"
    }
}
