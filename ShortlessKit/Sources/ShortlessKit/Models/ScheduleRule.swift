import Foundation

/// A user-defined schedule for when app blocking should be active.
/// Stored in App Group UserDefaults so all extensions can read it.
public struct ScheduleRule: Codable, Equatable {
    /// Start hour (0-23)
    public var startHour: Int
    /// Start minute (0-59)
    public var startMinute: Int
    /// End hour (0-23)
    public var endHour: Int
    /// End minute (0-59)
    public var endMinute: Int
    /// Days of the week when the schedule is active.
    /// Uses Calendar weekday numbering: 1=Sunday, 2=Monday, ... 7=Saturday.
    public var activeDays: Set<Int>
    /// Whether this schedule is currently enabled.
    public var isEnabled: Bool

    public init(
        startHour: Int = 9,
        startMinute: Int = 0,
        endHour: Int = 17,
        endMinute: Int = 0,
        activeDays: Set<Int> = [2, 3, 4, 5, 6], // Mon-Fri
        isEnabled: Bool = true
    ) {
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.activeDays = activeDays
        self.isEnabled = isEnabled
    }

    /// Short day labels for UI display, ordered Sun-Sat.
    public static let dayLabels: [(weekday: Int, label: String)] = [
        (1, "S"), (2, "M"), (3, "Tu"), (4, "W"), (5, "Th"), (6, "F"), (7, "S")
    ]

    /// Formatted time string for the start time (e.g., "9:00 AM").
    public var formattedStartTime: String {
        Self.formatTime(hour: startHour, minute: startMinute)
    }

    /// Formatted time string for the end time (e.g., "5:00 PM").
    public var formattedEndTime: String {
        Self.formatTime(hour: endHour, minute: endMinute)
    }

    public static func formatTime(hour: Int, minute: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", displayHour, minute, period)
    }
}
