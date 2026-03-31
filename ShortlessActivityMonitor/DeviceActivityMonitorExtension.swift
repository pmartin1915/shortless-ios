import Foundation
import DeviceActivity
import ManagedSettings
import FamilyControls
import ShortlessKit

/// Enforces the user's app-blocking schedule.
/// Called by the system when a scheduled DeviceActivity interval starts or ends.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    private let store = ManagedSettingsStore(named: .shortless)

    override func intervalDidStart(for activity: DeviceActivityName) {
        guard activity == .shortlessFocus else { return }

        let defaults = UserDefaults(suiteName: SettingsStore.appGroupID)

        // Check if today is an active day in the schedule
        if let scheduleData = defaults?.data(forKey: SettingsStore.scheduleKey),
           let schedule = try? JSONDecoder().decode(ScheduleRule.self, from: scheduleData) {
            let today = Calendar.current.component(.weekday, from: Date())
            guard schedule.activeDays.contains(today) else { return }
        }

        guard let data = defaults?.data(forKey: SettingsStore.appBlockerSelectionKey),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return
        }

        // Apply shields to the user's selected apps and categories
        store.shield.applications = selection.applicationTokens
        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        guard activity == .shortlessFocus else { return }

        // Check explicit blocking mode — "alwaysOn" keeps shields active indefinitely
        let defaults = UserDefaults(suiteName: SettingsStore.appGroupID)
        let mode = defaults?.string(forKey: SettingsStore.blockingModeKey) ?? "alwaysOn"

        if mode == "alwaysOn" {
            return
        }

        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }
}

// ManagedSettingsStore.Name.shortless and DeviceActivityName.shortlessFocus
// are defined in ShortlessKit/SharedConstants.swift
