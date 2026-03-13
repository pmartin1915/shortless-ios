import XCTest
@testable import ShortlessKit

final class BlockCountStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Clear today's block count before each test
        let defaults = UserDefaults(suiteName: SettingsStore.appGroupID)
        defaults?.removeObject(forKey: BlockCountStore.todayKey())
    }

    func testInitialCountIsZero() {
        let store = BlockCountStore()
        XCTAssertEqual(store.todayCount, 0)
    }

    func testIncrementByOne() {
        let store = BlockCountStore()
        store.increment()
        XCTAssertEqual(store.todayCount, 1)
    }

    func testIncrementByMultiple() {
        let store = BlockCountStore()
        store.increment(by: 5)
        XCTAssertEqual(store.todayCount, 5)
    }

    func testMultipleIncrements() {
        let store = BlockCountStore()
        store.increment(by: 3)
        store.increment(by: 7)
        XCTAssertEqual(store.todayCount, 10)
    }

    func testRefreshReadsLatestValue() {
        let store = BlockCountStore()
        store.increment(by: 42)

        // Simulate another process writing to the same key
        let defaults = UserDefaults(suiteName: SettingsStore.appGroupID)!
        defaults.set(100, forKey: BlockCountStore.todayKey())

        store.refresh()
        XCTAssertEqual(store.todayCount, 100)
    }

    func testTodayKeyFormat() {
        let key = BlockCountStore.todayKey()
        // Should match "blocks_YYYY-MM-DD"
        XCTAssertTrue(key.hasPrefix("blocks_"))
        let datePart = String(key.dropFirst("blocks_".count))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        XCTAssertNotNil(formatter.date(from: datePart), "Key date part should be valid YYYY-MM-DD")
    }

    func testPersistsAcrossInstances() {
        let store1 = BlockCountStore()
        store1.increment(by: 15)

        let store2 = BlockCountStore()
        XCTAssertEqual(store2.todayCount, 15)
    }
}
