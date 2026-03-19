import Foundation

/// Manages per-platform toggle state via App Group UserDefaults.
/// Shared across main app, Content Blocker, Safari Web Extension, and Network Extension.
public final class SettingsStore: ObservableObject {
    public static let appGroupID = "group.dev.pmartin1915.shortless"

    private let defaults: UserDefaults

    @Published public private(set) var toggles: [Platform: Bool]
    @Published public private(set) var vpnEnabled: Bool
    @Published public private(set) var streakStartDate: Date?

    private static let vpnEnabledKey = "vpnEnabled"
    private static let streakStartDateKey = "streakStartDate"

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

    /// Returns the set of currently enabled platforms.
    public var enabledPlatforms: Set<Platform> {
        Set(Platform.allCases.filter { isEnabled($0) })
    }

    /// Number of full days since all platforms were enabled (streak).
    public var streakDays: Int {
        guard let start = streakStartDate else { return 0 }
        return max(0, Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0)
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
