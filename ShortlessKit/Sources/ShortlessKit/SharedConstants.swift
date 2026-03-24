import ManagedSettings
import DeviceActivity

// MARK: - Shared constants used by main app + extensions
// Single source of truth — avoids string drift between targets.

extension ManagedSettingsStore.Name {
    public static let shortless = ManagedSettingsStore.Name("shortless")
}

extension DeviceActivityName {
    public static let shortlessFocus = DeviceActivityName("shortless.focus")
}
