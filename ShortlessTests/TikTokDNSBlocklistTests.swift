import XCTest
@testable import ShortlessKit

final class TikTokDNSBlocklistTests: XCTestCase {

    // MARK: - Exact Domain Matches

    func testExactDomainMatch() {
        XCTAssertTrue(TikTokDNSBlocklist.isBlocked("tiktok.com"))
        XCTAssertTrue(TikTokDNSBlocklist.isBlocked("musical.ly"))
        XCTAssertTrue(TikTokDNSBlocklist.isBlocked("tiktokcdn.com"))
    }

    // MARK: - Subdomain Matches

    func testSubdomainMatch() {
        XCTAssertTrue(TikTokDNSBlocklist.isBlocked("api.tiktok.com"))
        XCTAssertTrue(TikTokDNSBlocklist.isBlocked("m.tiktok.com"))
        XCTAssertTrue(TikTokDNSBlocklist.isBlocked("api2.musical.ly"))
        XCTAssertTrue(TikTokDNSBlocklist.isBlocked("log.tiktokv.com"))
    }

    func testDeepSubdomainMatch() {
        XCTAssertTrue(TikTokDNSBlocklist.isBlocked("v16.tiktokcdn.com"))
        XCTAssertTrue(TikTokDNSBlocklist.isBlocked("v16m.tiktokcdn.com"))
        XCTAssertTrue(TikTokDNSBlocklist.isBlocked("p16-tiktokcdn-com.byteoversea.com"))
    }

    // MARK: - Non-Matches

    func testNonBlockedDomains() {
        XCTAssertFalse(TikTokDNSBlocklist.isBlocked("google.com"))
        XCTAssertFalse(TikTokDNSBlocklist.isBlocked("youtube.com"))
        XCTAssertFalse(TikTokDNSBlocklist.isBlocked("instagram.com"))
        XCTAssertFalse(TikTokDNSBlocklist.isBlocked("apple.com"))
    }

    func testPartialSuffixNotBlocked() {
        // "nottiktok.com" should NOT match "tiktok.com" — suffix matching requires dot boundary
        XCTAssertFalse(TikTokDNSBlocklist.isBlocked("nottiktok.com"))
        XCTAssertFalse(TikTokDNSBlocklist.isBlocked("faketiktokcdn.com"))
        XCTAssertFalse(TikTokDNSBlocklist.isBlocked("mymusical.ly"))
    }

    // MARK: - Case Insensitivity

    func testCaseInsensitivity() {
        XCTAssertTrue(TikTokDNSBlocklist.isBlocked("TikTok.COM"))
        XCTAssertTrue(TikTokDNSBlocklist.isBlocked("API.TIKTOK.COM"))
        XCTAssertTrue(TikTokDNSBlocklist.isBlocked("Musical.Ly"))
    }

    // MARK: - All Suffixes Covered

    func testAllSuffixesBlocked() {
        let expectedSuffixes = [
            "tiktok.com", "tiktokv.com", "tiktoktv.com", "tiktokvideo.com", "tiktokw.us",
            "tiktokcdn.com", "tiktokcdn-us.com", "tiktokcdn-in.com",
            "musical.ly",
            "byteoversea.com", "ibyteimg.com", "byteimg.com", "isnssdk.com",
            "musemuse.cn", "ttwstatic.com", "ttdns2.com", "muscdn.com"
        ]
        for suffix in expectedSuffixes {
            XCTAssertTrue(TikTokDNSBlocklist.isBlocked(suffix), "\(suffix) should be blocked")
            XCTAssertTrue(TikTokDNSBlocklist.isBlocked("sub.\(suffix)"), "sub.\(suffix) should be blocked")
        }
    }

    // MARK: - Edge Cases

    func testEmptyString() {
        XCTAssertFalse(TikTokDNSBlocklist.isBlocked(""))
    }

    func testDotOnly() {
        XCTAssertFalse(TikTokDNSBlocklist.isBlocked("."))
    }
}
