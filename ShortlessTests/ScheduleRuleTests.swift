import XCTest
@testable import ShortlessKit

final class ScheduleRuleTests: XCTestCase {

    func testDefaultValues() {
        let rule = ScheduleRule()
        XCTAssertEqual(rule.startHour, 9)
        XCTAssertEqual(rule.startMinute, 0)
        XCTAssertEqual(rule.endHour, 17)
        XCTAssertEqual(rule.endMinute, 0)
        XCTAssertEqual(rule.activeDays, [2, 3, 4, 5, 6]) // Mon-Fri
        XCTAssertTrue(rule.isEnabled)
    }

    func testCodableRoundTrip() throws {
        let rule = ScheduleRule(
            startHour: 22,
            startMinute: 30,
            endHour: 6,
            endMinute: 0,
            activeDays: [1, 7], // Sun, Sat
            isEnabled: false
        )
        let data = try JSONEncoder().encode(rule)
        let decoded = try JSONDecoder().decode(ScheduleRule.self, from: data)
        XCTAssertEqual(rule, decoded)
    }

    func testEquality() {
        let a = ScheduleRule(startHour: 9, startMinute: 0, endHour: 17, endMinute: 0, activeDays: [2, 3], isEnabled: true)
        let b = ScheduleRule(startHour: 9, startMinute: 0, endHour: 17, endMinute: 0, activeDays: [2, 3], isEnabled: true)
        let c = ScheduleRule(startHour: 10, startMinute: 0, endHour: 17, endMinute: 0, activeDays: [2, 3], isEnabled: true)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    func testFormattedStartTime() {
        let rule = ScheduleRule(startHour: 9, startMinute: 0, endHour: 17, endMinute: 0)
        XCTAssertEqual(rule.formattedStartTime, "9:00 AM")
    }

    func testFormattedEndTime() {
        let rule = ScheduleRule(startHour: 9, startMinute: 0, endHour: 17, endMinute: 30)
        XCTAssertEqual(rule.formattedEndTime, "5:30 PM")
    }

    func testMidnightFormatting() {
        let rule = ScheduleRule(startHour: 0, startMinute: 0, endHour: 23, endMinute: 59)
        XCTAssertEqual(rule.formattedStartTime, "12:00 AM")
        XCTAssertEqual(rule.formattedEndTime, "11:59 PM")
    }

    func testNoonFormatting() {
        let rule = ScheduleRule(startHour: 12, startMinute: 0, endHour: 12, endMinute: 30)
        XCTAssertEqual(rule.formattedStartTime, "12:00 PM")
        XCTAssertEqual(rule.formattedEndTime, "12:30 PM")
    }

    func testEmptyActiveDays() throws {
        let rule = ScheduleRule(activeDays: [])
        let data = try JSONEncoder().encode(rule)
        let decoded = try JSONDecoder().decode(ScheduleRule.self, from: data)
        XCTAssertTrue(decoded.activeDays.isEmpty)
    }

    func testDayLabelsCount() {
        XCTAssertEqual(ScheduleRule.dayLabels.count, 7)
        XCTAssertEqual(ScheduleRule.dayLabels.first?.weekday, 1) // Sunday
        XCTAssertEqual(ScheduleRule.dayLabels.last?.weekday, 7)  // Saturday
    }
}
