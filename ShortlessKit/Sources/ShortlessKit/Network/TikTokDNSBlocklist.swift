import Foundation

/// TikTok domain blocklist for DNS-level blocking.
/// Performs case-insensitive suffix matching against known TikTok/ByteDance domains.
public enum TikTokDNSBlocklist {

    /// All known TikTok-related domain suffixes.
    /// Covers core API, CDN, legacy (Musical.ly), and ByteDance telemetry domains.
    public static let suffixes: [String] = [
        // Core API & load balancing
        "tiktok.com",
        "tiktokv.com",
        "tiktoktv.com",
        "tiktokvideo.com",
        "tiktokw.us",

        // CDN & video delivery
        "tiktokcdn.com",
        "tiktokcdn-us.com",
        "tiktokcdn-in.com",

        // Legacy (Musical.ly)
        "musical.ly",

        // ByteDance telemetry & static assets
        "byteoversea.com",
        "ibyteimg.com",
        "byteimg.com",
        "isnssdk.com",
        "musemuse.cn",
        "ttwstatic.com",
        "ttdns2.com",
        "muscdn.com"
    ]

    /// Returns `true` if the given domain is a TikTok-related domain.
    /// Matches exact domain or any subdomain (e.g. "api.tiktok.com" matches suffix "tiktok.com").
    public static func isBlocked(_ domain: String) -> Bool {
        let lowered = domain.lowercased()
        for suffix in suffixes {
            if lowered == suffix || lowered.hasSuffix("." + suffix) {
                return true
            }
        }
        return false
    }
}
