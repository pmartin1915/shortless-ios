import Foundation

/// Generates Safari Content Blocker JSON rules from RuleDefinitions.
/// Output format matches Apple's Content Blocker JSON specification.
public enum ContentBlockerRuleGenerator {

    public struct Rule: Codable {
        public let trigger: Trigger
        public let action: Action

        public struct Trigger: Codable {
            public let urlFilter: String
            public let resourceType: [String]?

            enum CodingKeys: String, CodingKey {
                case urlFilter = "url-filter"
                case resourceType = "resource-type"
            }
        }

        public struct Action: Codable {
            public let type: String
            public let selector: String?
        }
    }

    /// Generate the complete Content Blocker rule list for the given enabled platforms.
    public static func generateRules(for platforms: Set<Platform>) -> [Rule] {
        var rules: [Rule] = []

        if platforms.contains(.youtube),
           let domain = RuleDefinitions.domainTriggers[.youtube] {
            rules += urlBlockRules(patterns: RuleDefinitions.youtubeURLBlocks)
            rules += cssHideRules(domain: domain, selectors: RuleDefinitions.youtubeCSSSelectors)
        }

        if platforms.contains(.instagram),
           let domain = RuleDefinitions.domainTriggers[.instagram] {
            rules += urlBlockRules(patterns: RuleDefinitions.instagramURLBlocks)
            rules += cssHideRules(domain: domain, selectors: RuleDefinitions.instagramCSSSelectors)
        }

        if platforms.contains(.tiktok) {
            for pattern in RuleDefinitions.tiktokURLBlocks {
                rules.append(Rule(
                    trigger: Rule.Trigger(urlFilter: pattern, resourceType: nil),
                    action: Rule.Action(type: "block", selector: nil)
                ))
            }
        }

        if platforms.contains(.snapchat),
           let domain = RuleDefinitions.domainTriggers[.snapchat] {
            rules += urlBlockRules(patterns: RuleDefinitions.snapchatURLBlocks)
            rules += cssHideRules(domain: domain, selectors: RuleDefinitions.snapchatCSSSelectors)
        }

        return rules
    }

    /// Serialize rules to JSON Data for the Content Blocker extension.
    public static func generateJSON(for platforms: Set<Platform>) throws -> Data {
        let rules = generateRules(for: platforms)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(rules)
    }

    // MARK: - Private

    private static func urlBlockRules(patterns: [String]) -> [Rule] {
        patterns.map { pattern in
            Rule(
                trigger: Rule.Trigger(urlFilter: pattern, resourceType: ["raw"]),
                action: Rule.Action(type: "block", selector: nil)
            )
        }
    }

    private static func cssHideRules(domain: String, selectors: [String]) -> [Rule] {
        selectors.map { selector in
            Rule(
                trigger: Rule.Trigger(urlFilter: domain, resourceType: nil),
                action: Rule.Action(type: "css-display-none", selector: selector)
            )
        }
    }
}
