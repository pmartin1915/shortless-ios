import XCTest
@testable import ShortlessKit

final class ContentBlockerRuleGeneratorTests: XCTestCase {

    func testAllPlatformsGeneratesRules() throws {
        let allPlatforms = Set(Platform.allCases)
        let rules = ContentBlockerRuleGenerator.generateRules(for: allPlatforms)
        // YouTube: 1 URL block + 11 CSS = 12
        // Instagram: 1 URL block + 10 CSS = 11
        // TikTok: 2 domain blocks = 2
        // Snapchat: 1 URL block + 2 CSS = 3
        // Total: 28
        XCTAssertEqual(rules.count, 28, "All platforms enabled should generate 28 rules")
    }

    func testEmptyPlatformsGeneratesNoRules() {
        let rules = ContentBlockerRuleGenerator.generateRules(for: [])
        XCTAssertEqual(rules.count, 0)
    }

    func testYouTubeOnlyRules() {
        let rules = ContentBlockerRuleGenerator.generateRules(for: [.youtube])
        XCTAssertEqual(rules.count, 12) // 1 URL block + 11 CSS
    }

    func testInstagramOnlyRules() {
        let rules = ContentBlockerRuleGenerator.generateRules(for: [.instagram])
        XCTAssertEqual(rules.count, 11) // 1 URL block + 10 CSS
    }

    func testTikTokOnlyRules() {
        let rules = ContentBlockerRuleGenerator.generateRules(for: [.tiktok])
        XCTAssertEqual(rules.count, 2) // 2 full domain blocks
    }

    func testSnapchatOnlyRules() {
        let rules = ContentBlockerRuleGenerator.generateRules(for: [.snapchat])
        XCTAssertEqual(rules.count, 3) // 1 URL block + 2 CSS
    }

    func testTikTokRulesBlockFullDomain() {
        let rules = ContentBlockerRuleGenerator.generateRules(for: [.tiktok])
        let urlFilters = rules.map { $0.trigger.urlFilter }
        XCTAssertTrue(urlFilters.contains("tiktok\\.com"))
        XCTAssertTrue(urlFilters.contains("musical\\.ly"))

        // TikTok rules should have no resource-type filter (block everything)
        for rule in rules {
            XCTAssertNil(rule.trigger.resourceType,
                         "TikTok should be a full domain block with no resource-type filter")
        }
    }

    func testURLBlockRulesUseRawResourceType() {
        let rules = ContentBlockerRuleGenerator.generateRules(for: [.youtube])
        let urlBlockRules = rules.filter { $0.action.type == "block" }
        for rule in urlBlockRules {
            XCTAssertEqual(rule.trigger.resourceType, ["raw"],
                           "URL block rules should use 'raw' resource type")
        }
    }

    func testCSSRulesUseCSSDisplayNone() {
        let rules = ContentBlockerRuleGenerator.generateRules(for: [.youtube])
        let cssRules = rules.filter { $0.action.type == "css-display-none" }
        XCTAssertEqual(cssRules.count, 11, "YouTube should have 11 CSS hiding rules")
        for rule in cssRules {
            XCTAssertNotNil(rule.action.selector, "CSS rules must have a selector")
            XCTAssertTrue(rule.trigger.urlFilter.contains("youtube"),
                          "CSS rules should target youtube.com")
        }
    }

    func testGenerateJSONProducesValidJSON() throws {
        let data = try ContentBlockerRuleGenerator.generateJSON(for: Set(Platform.allCases))
        let parsed = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        XCTAssertNotNil(parsed, "Generated JSON should be a valid array of objects")
        XCTAssertEqual(parsed?.count, 28)
    }

    func testGenerateJSONEmptyProducesEmptyArray() throws {
        let data = try ContentBlockerRuleGenerator.generateJSON(for: [])
        let parsed = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.count, 0)
    }
}
