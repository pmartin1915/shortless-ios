import XCTest
@testable import ShortlessKit

final class BlockCountStoreHistoryTests: XCTestCase {

    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: SettingsStore.appGroupID)!
        // Clear all blocks_ keys
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix("blocks_") {
            defaults.removeObject(forKey: key)
        }
    }

    override func tearDown() {
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix("blocks_") {
            defaults.removeObject(forKey: key)
        }
        super.tearDown()
    }

    // MARK: - count(for:)

    func testCountForSpecificDate() {
        let date = date(daysAgo: 3)
        defaults.set(42, forKey: BlockCountStore.key(for: date))

        let store = BlockCountStore()
        XCTAssertEqual(store.count(for: date), 42)
    }

    func testCountForDateWithNoData() {
        let store = BlockCountStore()
        XCTAssertEqual(store.count(for: date(daysAgo: 100)), 0)
    }

    // MARK: - counts(for:)

    func testCountsForWeek() {
        seedData([0: 10, 1: 20, 2: 30, 3: 0, 4: 15, 5: 0, 6: 5])

        let store = BlockCountStore()
        let data = store.counts(for: 7)

        XCTAssertEqual(data.count, 7)
        // Most recent (today) should be last
        XCTAssertEqual(data.last?.count, 10)
        // Oldest (6 days ago) should be first
        XCTAssertEqual(data.first?.count, 5)
    }

    func testCountsForEmptyRange() {
        let store = BlockCountStore()
        let data = store.counts(for: 7)
        XCTAssertEqual(data.count, 7)
        XCTAssertTrue(data.allSatisfy { $0.count == 0 })
    }

    // MARK: - totalCount

    func testTotalCountAcrossAllDays() {
        seedData([0: 10, 1: 20, 5: 30])

        let store = BlockCountStore()
        XCTAssertEqual(store.totalCount, 60)
    }

    func testTotalCountWithNoData() {
        let store = BlockCountStore()
        XCTAssertEqual(store.totalCount, 0)
    }

    // MARK: - activeDays

    func testActiveDaysCountsOnlyNonZero() {
        seedData([0: 10, 1: 0, 2: 30, 3: 0, 4: 5])

        let store = BlockCountStore()
        XCTAssertEqual(store.activeDays, 3)
    }

    // MARK: - dailyAverage

    func testDailyAverage() {
        seedData([0: 10, 1: 20, 2: 30])

        let store = BlockCountStore()
        XCTAssertEqual(store.dailyAverage, 20.0, accuracy: 0.01)
    }

    func testDailyAverageWithNoData() {
        let store = BlockCountStore()
        XCTAssertEqual(store.dailyAverage, 0)
    }

    // MARK: - timeReclaimed

    func testTimeReclaimedDefaultSeconds() {
        seedData([0: 100])

        let store = BlockCountStore()
        // 100 blocks * 15 seconds = 1500 seconds
        XCTAssertEqual(store.timeReclaimed(), 1500)
    }

    func testTimeReclaimedCustomSeconds() {
        seedData([0: 100])

        let store = BlockCountStore()
        // 100 blocks * 30 seconds = 3000 seconds
        XCTAssertEqual(store.timeReclaimed(secondsPerShort: 30), 3000)
    }

    // MARK: - key(for:)

    func testKeyForDateFormat() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: "2026-03-15")!

        let key = BlockCountStore.key(for: date)
        XCTAssertEqual(key, "blocks_2026-03-15")
    }

    // MARK: - Helpers

    private func date(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: Calendar.current.startOfDay(for: Date()))!
    }

    private func seedData(_ data: [Int: Int]) {
        for (daysAgo, count) in data {
            defaults.set(count, forKey: BlockCountStore.key(for: date(daysAgo: daysAgo)))
        }
    }
}
