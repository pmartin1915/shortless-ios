import XCTest
@testable import ShortlessKit

final class SettingsStoreScheduleTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let defaults = UserDefaults(suiteName: SettingsStore.appGroupID)
        defaults?.removeObject(forKey: "appBlockerSchedule")
        defaults?.removeObject(forKey: "appBlockerEnabled")
    }

    func testScheduleNilByDefault() {
        let store = SettingsStore()
        XCTAssertNil(store.schedule)
    }

    func testAppBlockerDisabledByDefault() {
        let store = SettingsStore()
        XCTAssertFalse(store.appBlockerEnabled)
    }

    func testSetSchedulePersists() {
        let store = SettingsStore()
        let rule = ScheduleRule(startHour: 8, startMinute: 30, endHour: 16, endMinute: 0, activeDays: [2, 3, 4], isEnabled: true)
        store.setSchedule(rule)
        XCTAssertEqual(store.schedule, rule)

        // Verify persistence across instances
        let store2 = SettingsStore()
        XCTAssertEqual(store2.schedule, rule)
    }

    func testClearSchedule() {
        let store = SettingsStore()
        store.setSchedule(ScheduleRule())
        XCTAssertNotNil(store.schedule)

        store.setSchedule(nil)
        XCTAssertNil(store.schedule)

        let store2 = SettingsStore()
        XCTAssertNil(store2.schedule)
    }

    func testSetAppBlockerEnabledPersists() {
        let store = SettingsStore()
        store.setAppBlockerEnabled(true)
        XCTAssertTrue(store.appBlockerEnabled)

        let store2 = SettingsStore()
        XCTAssertTrue(store2.appBlockerEnabled)
    }

    func testAppBlockerToggleBackAndForth() {
        let store = SettingsStore()
        store.setAppBlockerEnabled(true)
        XCTAssertTrue(store.appBlockerEnabled)
        store.setAppBlockerEnabled(false)
        XCTAssertFalse(store.appBlockerEnabled)
    }

    func testScheduleAndAppBlockerIndependent() {
        let store = SettingsStore()
        store.setSchedule(ScheduleRule())
        store.setAppBlockerEnabled(true)

        // Clearing schedule should not affect appBlockerEnabled
        store.setSchedule(nil)
        XCTAssertTrue(store.appBlockerEnabled)

        // Disabling app blocker should not affect schedule (once set again)
        store.setSchedule(ScheduleRule())
        store.setAppBlockerEnabled(false)
        XCTAssertNotNil(store.schedule)
    }
}
