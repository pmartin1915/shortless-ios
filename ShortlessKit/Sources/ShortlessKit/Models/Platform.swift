import Foundation

/// Platforms that Shortless can block short-form content on.
/// Raw values match the browser extension's storage keys exactly.
public enum Platform: String, CaseIterable, Identifiable, Codable {
    case youtube
    case instagram
    case tiktok
    case snapchat

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .youtube:   return "YouTube"
        case .instagram: return "Instagram"
        case .tiktok:    return "TikTok"
        case .snapchat:  return "Snapchat"
        }
    }

    public var shortFormName: String {
        switch self {
        case .youtube:   return "Shorts"
        case .instagram: return "Reels"
        case .tiktok:    return "TikTok"
        case .snapchat:  return "Spotlight"
        }
    }

    public var iconSystemName: String {
        switch self {
        case .youtube:   return "play.rectangle.fill"
        case .instagram: return "camera.fill"
        case .tiktok:    return "music.note"
        case .snapchat:  return "bolt.fill"
        }
    }
}
