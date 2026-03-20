import SwiftUI

/// Onboarding page 5: Safari extension setup instructions.
struct SetupPage: View {
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "safari.fill")
                    .font(.system(size: 44))
                    .foregroundColor(ShortlessTheme.accent)

                Text("One last step")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(ShortlessTheme.textPrimary)

                Text("Enable Shortless in Safari to start blocking.")
                    .font(.system(size: ShortlessTheme.bodySize))
                    .foregroundColor(ShortlessTheme.textTertiary)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 14) {
                    stepRow(number: 1, title: "Open Settings", detail: "Go to your device's Settings app")
                    stepRow(number: 2, title: "Find Safari", detail: "Scroll down and tap Safari")
                    stepRow(number: 3, title: "Tap Extensions", detail: "Under General, tap Extensions")
                    stepRow(number: 4, title: "Enable Shortless", detail: "Turn on both Shortless extensions")
                    stepRow(number: 5, title: "Allow on All Websites", detail: "Tap \"Allow\" when prompted")
                }
                .padding(.horizontal, ShortlessTheme.containerPadding)
            }

            Spacer()

            Button(action: onDone) {
                Text("I'm Ready")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(ShortlessTheme.accent)
                    .cornerRadius(10)
            }
            .padding(.horizontal, ShortlessTheme.containerPadding)
            .padding(.bottom, 48)
        }
    }

    private func stepRow(number: Int, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(ShortlessTheme.background)
                .frame(width: 26, height: 26)
                .background(ShortlessTheme.accent)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: ShortlessTheme.bodySize, weight: .semibold))
                    .foregroundColor(ShortlessTheme.textPrimary)

                Text(detail)
                    .font(.system(size: ShortlessTheme.captionSize))
                    .foregroundColor(ShortlessTheme.textTertiary)
            }
        }
    }
}
