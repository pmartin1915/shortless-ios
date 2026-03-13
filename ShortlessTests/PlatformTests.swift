import XCTest
@testable import ShortlessKit

final class PlatformTests: XCTestCase {

    func testAllCasesCount() {
        XCTAssertEqual(Platform.allCases.count, 4)
    }

    func testRawValues() {
        XCTAssertEqual(Platform.youtube.rawValue, "youtube")
        XCTAssertEqual(Platform.instagram.rawValue, "instagram")
        XCTAssertEqual(Platform.tiktok.rawValue, "tiktok")
        XCTAssertEqual(Platform.snapchat.rawValue, "snapchat")
    }

    func testDisplayNames() {
        XCTAssertEqual(Platform.youtube.displayName, "YouTube")
        XCTAssertEqual(Platform.instagram.displayName, "Instagram")
        XCTAssertEqual(Platform.tiktok.displayName, "TikTok")
        XCTAssertEqual(Platform.snapchat.displayName, "Snapchat")
    }

    func testShortFormNames() {
        XCTAssertEqual(Platform.youtube.shortFormName, "Shorts")
        XCTAssertEqual(Platform.instagram.shortFormName, "Reels")
        XCTAssertEqual(Platform.tiktok.shortFormName, "TikTok")
        XCTAssertEqual(Platform.snapchat.shortFormName, "Spotlight")
    }

    func testInitFromRawValue() {
        XCTAssertEqual(Platform(rawValue: "youtube"), .youtube)
        XCTAssertEqual(Platform(rawValue: "instagram"), .instagram)
        XCTAssertNil(Platform(rawValue: "facebook"))
    }

    func testCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let original = Platform.youtube
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(Platform.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    func testIdentifiable() {
        for platform in Platform.allCases {
            XCTAssertEqual(platform.id, platform.rawValue)
        }
    }
}
