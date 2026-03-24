import Foundation
import Combine

/// Manages per-platform toggle state via App Group UserDefaults.
/// Extensions write directly to the shared UserDefaults; this class
/// observes changes and keeps @Published properties in sync.
public final class SettingsStore: ObservableObject {
    public static let appGroupID = "group.dev.pmartin1915.shortless"

    private let defaults: UserDefaults
    private var cancellable: AnyCancellable?

    @Published public private(set) var toggles: [Platform: Bool]
    @Published public private(set) var vpnEnabled: Bool
    @Published public private(set) var streakStartDate: Date?
    @Published public private(set) var dailyShortMinutes: Int
    @Published public private(set) var reductionGoalPercent: Int
    @Published public private(set) var estimatedSecondsPerShort: Int
    @Published public private(set) var schedule: ScheduleRule?
    @Published public private(set) var appBlockerEnabled: Bool
    @Published public private(set) var blockingMode: String  // "alwaysOn" or "scheduled"

    // MARK: - UserDefaults Keys (public so extensions can use the same keys)
    public static let vpnEnabledKey = "vpnEnabled"
    public static let streakStartDateKey = "streakStartDate"
    public static let dailyShortMinutesKey = "dailyShortMinutes"
    public static let reductionGoalPercentKey = "reductionGoalPercent"
    public static let estimatedSecondsPerShortKey = "estimatedSecondsPerShort"
    public static let scheduleKey = "appBlockerSchedule"
    public static let appBlockerEnabledKey = "appBlockerEnabled"
    public static let appBlockerSelectionKey = "appBlockerSelection"
    public static let blockingModeKey = "appBlockerMode"

    public init() {
        guard let defaults = UserDefaults(suiteName: SettingsStore.appGroupID) else {
            // App Group misconfiguration is a fatal developer error — fail loudly.
            // This should never happen if entitlements are set up correctly.
            fatalError("[Shortless] App Group '\(SettingsStore.appGroupID)' is not configured. Check Signing & Capabilities → App Groups for all targets.")
        }
        self.defaults = defaults

        var initial: [Platform: Bool] = [:]
        for platform in Platform.allCases {
            // Default to enabled (true) if no value stored — matches browser extension behavior
            let value = defaults.object(forKey: platform.rawValue) as? Bool ?? true
            initial[platform] = value
        }
        self.toggles = initial
        self.vpnEnabled = defaults.object(forKey: SettingsStore.vpnEnabledKey) as? Bool ?? false
        self.streakStartDate = defaults.object(forKey: SettingsStore.streakStartDateKey) as? Date
        self.dailyShortMinutes = defaults.object(forKey: SettingsStore.dailyShortMinutesKey) as? Int ?? 60
        self.reductionGoalPercent = defaults.object(forKey: SettingsStore.reductionGoalPercentKey) as? Int ?? 100
        self.estimatedSecondsPerShort = defaults.object(forKey: SettingsStore.estimatedSecondsPerShortKey) as? Int ?? 15
        self.appBlockerEnabled = defaults.object(forKey: SettingsStore.appBlockerEnabledKey) as? Bool ?? false
        self.blockingMode = defaults.string(forKey: SettingsStore.blockingModeKey) ?? "alwaysOn"
        if let scheduleData = defaults.data(forKey: SettingsStore.scheduleKey),
           let saved = try? JSONDecoder().decode(ScheduleRule.self, from: scheduleData) {
            self.schedule = saved
        } else {
            self.schedule = nil
        }

        // Observe external changes (e.g., from extensions writing to shared UserDefaults)
        cancellable = NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.reloadFromDefaults() }
    }

    /// Re-read all values from UserDefaults to keep @Published properties in sync
    /// with changes made by extensions or other processes.
    private func reloadFromDefaults() {
        for platform in Platform.allCases {
            let value = defaults.object(forKey: platform.rawValue) as? Bool ?? true
            if toggles[platform] != value {
                toggles[platform] = value
            }
        }
        let newVPN = defaults.object(forKey: SettingsStore.vpnEnabledKey) as? Bool ?? false
        if vpnEnabled != newVPN { vpnEnabled = newVPN }

        let newAppBlocker = defaults.object(forKey: SettingsStore.appBlockerEnabledKey) as? Bool ?? false
        if appBlockerEnabled != newAppBlocker { appBlockerEnabled = newAppBlocker }

        let newMode = defaults.string(forKey: SettingsStore.blockingModeKey) ?? "alwaysOn"
        if blockingMode != newMode { blockingMode = newMode }
    }

    public func isEnabled(_ platform: Platform) -> Bool {
        toggles[platform] ?? true
    }

    public func setEnabled(_ platform: Platform, _ enabled: Bool) {
        defaults.set(enabled, forKey: platform.rawValue)
        toggles[platform] = enabled
        updateStreak()
    }

    public func setVPNEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: SettingsStore.vpnEnabledKey)
        vpnEnabled = enabled
    }

    public func setDailyShortMinutes(_ minutes: Int) {
        defaults.set(minutes, forKey: SettingsStore.dailyShortMinutesKey)
        dailyShortMinutes = minutes
    }

    public func setReductionGoalPercent(_ percent: Int) {
        defaults.set(percent, forKey: SettingsStore.reductionGoalPercentKey)
        reductionGoalPercent = percent
    }

    public func setEstimatedSecondsPerShort(_ seconds: Int) {
        defaults.set(seconds, forKey: SettingsStore.estimatedSecondsPerShortKey)
        estimatedSecondsPerShort = seconds
    }

    public func setSchedule(_ rule: ScheduleRule?) {
        if let rule = rule, let data = try? JSONEncoder().encode(rule) {
            defaults.set(data, forKey: SettingsStore.scheduleKey)
        } else {
            defaults.removeObject(forKey: SettingsStore.scheduleKey)
        }
        schedule = rule
    }

    public func setAppBlockerEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: SettingsStore.appBlockerEnabledKey)
        appBlockerEnabled = enabled
    }

    public func setBlockingMode(_ mode: String) {
        defaults.set(mode, forKey: SettingsStore.blockingModeKey)
        blockingMode = mode
    }

    /// Returns the set of currently enabled platforms.
    public var enabledPlatforms: Set<Platform> {
        Set(Platform.allCases.filter { isEnabled($0) })
    }

    /// Number of full days since all platforms were enabled (streak).
    /// Uses startOfDay so streaks increment at midnight, not 24h from start.
    public var streakDays: Int {
        guard let start = streakStartDate else { return 0 }
        let calendar = Calendar.current
        let startOfDay1 = calendar.startOfDay(for: start)
        let startOfDay2 = calendar.startOfDay(for: Date())
        return max(0, calendar.dateComponents([.day], from: startOfDay1, to: startOfDay2).day ?? 0)
    }

    private func updateStreak() {
        let allEnabled = Platform.allCases.allSatisfy { isEnabled($0) }
        if allEnabled && streakStartDate == nil {
            let now = Date()
            defaults.set(now, forKey: SettingsStore.streakStartDateKey)
            streakStartDate = now
        } else if !allEnabled && streakStartDate != nil {
            defaults.removeObject(forKey: SettingsStore.streakStartDateKey)
            streakStartDate = nil
        }
    }
}
