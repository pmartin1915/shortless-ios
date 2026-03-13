import XCTest
@testable import ShortlessKit

final class SettingsStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Clear App Group defaults before each test
        let defaults = UserDefaults(suiteName: SettingsStore.appGroupID)
        Platform.allCases.forEach { defaults?.removeObject(forKey: $0.rawValue) }
    }

    func testAllPlatformsEnabledByDefault() {
        let store = SettingsStore()
        for platform in Platform.allCases {
            XCTAssertTrue(store.isEnabled(platform), "\(platform.displayName) should be enabled by default")
        }
    }

    func testSetEnabledPersists() {
        let store = SettingsStore()
        store.setEnabled(.youtube, false)
        XCTAssertFalse(store.isEnabled(.youtube))

        // Create a new instance to verify persistence
        let store2 = SettingsStore()
        XCTAssertFalse(store2.isEnabled(.youtube))
    }

    func testSetEnabledDoesNotAffectOtherPlatforms() {
        let store = SettingsStore()
        store.setEnabled(.tiktok, false)
        XCTAssertTrue(store.isEnabled(.youtube))
        XCTAssertTrue(store.isEnabled(.instagram))
        XCTAssertFalse(store.isEnabled(.tiktok))
        XCTAssertTrue(store.isEnabled(.snapchat))
    }

    func testEnabledPlatformsReturnsCorrectSet() {
        let store = SettingsStore()
        store.setEnabled(.instagram, false)
        store.setEnabled(.snapchat, false)

        let enabled = store.enabledPlatforms
        XCTAssertEqual(enabled, [.youtube, .tiktok])
    }

    func testToggleBackAndForth() {
        let store = SettingsStore()
        store.setEnabled(.youtube, false)
        XCTAssertFalse(store.isEnabled(.youtube))
        store.setEnabled(.youtube, true)
        XCTAssertTrue(store.isEnabled(.youtube))
    }
}
