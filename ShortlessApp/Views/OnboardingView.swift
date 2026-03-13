import SwiftUI

/// First-launch guide showing how to enable the Safari extension.
struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    welcomeSection
                    stepsSection
                    doneButton
                }
                .padding(ShortlessTheme.containerPadding)
            }
            .background(ShortlessTheme.background.ignoresSafeArea())
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") { dismiss() }
                        .foregroundColor(ShortlessTheme.accent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome to Shortless")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(ShortlessTheme.textPrimary)

            Text("To block short-form content in Safari, you need to enable the Shortless extensions in your device settings.")
                .font(.system(size: ShortlessTheme.bodySize))
                .foregroundColor(ShortlessTheme.textSecondary)
        }
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepRow(number: 1, title: "Open Settings", detail: "Go to your iPhone's Settings app")
            stepRow(number: 2, title: "Find Safari", detail: "Scroll down and tap Safari")
            stepRow(number: 3, title: "Tap Extensions", detail: "Under the General section, tap Extensions")
            stepRow(number: 4, title: "Enable Shortless", detail: "Turn on both Shortless extensions:\n• Shortless Content Blocker\n• Shortless Web Extension")
            stepRow(number: 5, title: "Allow on All Websites", detail: "When prompted, tap \"Allow\" to let Shortless work on all websites")
        }
    }

    private func stepRow(number: Int, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(ShortlessTheme.background)
                .frame(width: 28, height: 28)
                .background(ShortlessTheme.accent)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: ShortlessTheme.bodySize, weight: .semibold))
                    .foregroundColor(ShortlessTheme.textPrimary)

                Text(detail)
                    .font(.system(size: ShortlessTheme.captionSize))
                    .foregroundColor(ShortlessTheme.textTertiary)
            }
        }
    }

    private var doneButton: some View {
        Button(action: { dismiss() }) {
            Text("Done")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(ShortlessTheme.accent)
                .cornerRadius(10)
        }
        .padding(.top, 8)
    }
}
