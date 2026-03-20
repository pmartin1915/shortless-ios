import SwiftUI

/// Onboarding page 1: Welcome with app branding.
struct WelcomePage: View {
    let onNext: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 64))
                    .foregroundColor(ShortlessTheme.accent)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.8)

                Text("Shortless")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(ShortlessTheme.textPrimary)
                    .opacity(appeared ? 1 : 0)

                Text("Block the Scroll.\nKeep the Content.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(ShortlessTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)

                Text("Take control of your screen time by removing short-form video feeds from YouTube, Instagram, TikTok, and Snapchat.")
                    .font(.system(size: ShortlessTheme.bodySize))
                    .foregroundColor(ShortlessTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
            }

            Spacer()

            Button(action: onNext) {
                Text("Get Started")
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
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
    }
}
