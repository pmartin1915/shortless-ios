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

    public static func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "blocks_\(formatter.string(from: Date()))"
    }
}
