import SwiftUI

/// Design tokens ported from the browser extension's popup.css.
/// All values match the desktop extension exactly for brand consistency.
enum ShortlessTheme {
    // MARK: - Colors

    static let background    = Color(hex: "#1a1a2e")
    static let accent        = Color(hex: "#2E75B6")
    static let textPrimary   = Color.white
    static let textSecondary = Color(hex: "#e0e0e0")
    static let textTertiary  = Color(hex: "#888888")
    static let cardBorder    = Color.white.opacity(0.1)
    static let cardFill      = Color.white.opacity(0.03)
    static let toggleOff     = Color(hex: "#555555")
    static let footerBorder  = Color.white.opacity(0.06)

    // MARK: - Typography

    static let titleSize: CGFloat    = 22
    static let bodySize: CGFloat     = 14
    static let captionSize: CGFloat  = 12
    static let versionSize: CGFloat  = 11

    // MARK: - Spacing

    static let containerPadding: CGFloat = 16
    static let cardPadding: CGFloat      = 12
    static let cardSpacing: CGFloat      = 8
    static let cardCornerRadius: CGFloat = 8
    static let sectionSpacing: CGFloat   = 20
}

// MARK: - Color hex initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
