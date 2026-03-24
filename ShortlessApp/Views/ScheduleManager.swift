import Foundation
import DeviceActivity
import ShortlessKit

/// Wraps DeviceActivityCenter to register/unregister the user's focus schedule.
@MainActor
final class ScheduleManager: ObservableObject {

    private let center = DeviceActivityCenter()

    /// Start monitoring the user's schedule. Called when schedule is saved or app blocking is enabled.
    func startMonitoring(schedule rule: ScheduleRule) {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: rule.startHour, minute: rule.startMinute),
            intervalEnd: DateComponents(hour: rule.endHour, minute: rule.endMinute),
            repeats: true
        )

        // Stop any existing monitoring before starting new one
        center.stopMonitoring([.shortlessFocus])

        do {
            try center.startMonitoring(.shortlessFocus, during: schedule)
        } catch {
            print("[Shortless] Failed to start activity monitoring: \(error)")
        }
    }

    /// Stop all schedule monitoring. Called when user disables scheduled blocking.
    func stopMonitoring() {
        center.stopMonitoring([.shortlessFocus])
    }
}

// DeviceActivityName.shortlessFocus is defined in ShortlessKit/SharedConstants.swift
