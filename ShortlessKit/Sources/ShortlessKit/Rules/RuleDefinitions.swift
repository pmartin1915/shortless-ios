import Foundation

/// Centralized URL patterns and CSS selectors for all platforms.
/// Single source of truth — used by Content Blocker rule generator and NEURLFilter (Phase 2).
public enum RuleDefinitions {

    // MARK: - YouTube

    public static let youtubeURLBlocks: [String] = [
        "youtube\\.com/youtubei/v1/reel/"
    ]

    public static let youtubeCSSSelectors: [String] = [
        "ytd-reel-shelf-renderer",
        "ytd-rich-shelf-renderer[is-shorts]",
        "ytd-guide-entry-renderer:has(a[href=\"/shorts\"])",
        "ytd-mini-guide-entry-renderer:has(a[href=\"/shorts\"])",
        "yt-tab-shape[tab-title=\"Shorts\"]",
        "yt-tab-shape:has(a[href*=\"/shorts\"])",
        "[overlay-style=\"SHORTS\"]",
        "ytd-grid-video-renderer:has([overlay-style=\"SHORTS\"])",
        "ytd-video-renderer:has([overlay-style=\"SHORTS\"])",
        "ytd-rich-item-renderer:has([overlay-style=\"SHORTS\"])",
        "ytd-compact-video-renderer:has([overlay-style=\"SHORTS\"])"
    ]

    // MARK: - Instagram

    public static let instagramURLBlocks: [String] = [
        "instagram\\.com/api/v1/clips/"
    ]

    public static let instagramCSSSelectors: [String] = [
        "a[href=\"/reels/\"]",
        "a[href^=\"/reels/\"]",
        "a[href^=\"/reel/\"]",
        "[data-testid=\"reels-tab\"]",
        "article:has(a[href*=\"/reel/\"])",
        "li:has(> a[href=\"/reels/\"])",
        "li:has(> a[href^=\"/reels/\"])",
        "[role=\"listitem\"]:has(> a[href=\"/reels/\"])",
        "[role=\"listitem\"]:has(> a[href^=\"/reels/\"])",
        "div[role=\"menuitem\"]:has(a[href^=\"/reels/\"])"
    ]

    // MARK: - TikTok

    public static let tiktokURLBlocks: [String] = [
        "tiktok\\.com",
        "musical\\.ly"
    ]

    // No CSS selectors — full domain block

    // MARK: - Snapchat

    public static let snapchatURLBlocks: [String] = [
        "snapchat\\.com/embed/spotlight/"
    ]

    public static let snapchatCSSSelectors: [String] = [
        "a[href^=\"/spotlight\"]",
        "[data-testid=\"spotlight-tab\"]"
    ]

    // MARK: - URL trigger patterns (for CSS rules)

    public static let domainTriggers: [Platform: String] = [
        .youtube:   ".*youtube\\.com.*",
        .instagram: ".*instagram\\.com.*",
        .tiktok:    ".*tiktok\\.com.*",
        .snapchat:  ".*snapchat\\.com.*"
    ]

    // MARK: - NEURLFilter patterns (Phase 2)

    public static let neURLFilterPatterns: [Platform: [String]] = [
        .youtube: [
            "youtube.com/shorts/*",
            "youtube.com/youtubei/v1/reel/*"
        ],
        .instagram: [
            "instagram.com/reels/*",
            "instagram.com/reel/*",
            "instagram.com/api/v1/clips/*"
        ],
        .tiktok: [
            "tiktok.com/*",
            "musical.ly/*"
        ],
        .snapchat: [
            "snapchat.com/spotlight*",
            "snapchat.com/embed/spotlight/*"
        ]
    ]
}
