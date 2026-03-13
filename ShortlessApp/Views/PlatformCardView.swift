import SwiftUI
import ShortlessKit

/// A single platform toggle card — matches the browser extension popup layout.
struct PlatformCardView: View {
    let platform: Platform
    @Binding var isEnabled: Bool

    var body: some View {
        HStack {
            Image(systemName: platform.iconSystemName)
                .foregroundColor(ShortlessTheme.accent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(platform.displayName)
                    .font(.system(size: ShortlessTheme.bodySize, weight: .medium))
                    .foregroundColor(ShortlessTheme.textSecondary)

                Text(platform.shortFormName)
                    .font(.system(size: ShortlessTheme.captionSize))
                    .foregroundColor(ShortlessTheme.textTertiary)
            }

            Spacer()

            Toggle("", isOn: $isEnabled)
                .toggleStyle(SwitchToggleStyle(tint: ShortlessTheme.accent))
                .labelsHidden()
        }
        .padding(ShortlessTheme.cardPadding)
        .background(ShortlessTheme.cardFill)
        .overlay(
            RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius)
                .stroke(ShortlessTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(platform.displayName) \(platform.shortFormName) blocking")
        .accessibilityValue(isEnabled ? "Enabled" : "Disabled")
    }
}
