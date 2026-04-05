import SwiftUI
import ShortlessKit

/// About screen: version, privacy policy, GitHub link, setup guide.
struct SettingsView: View {
    @ObservedObject var settings: SettingsStore
    @State private var showOnboarding = false

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(ShortlessTheme.textTertiary)
                }
            }

            Section(header: Text("About")) {
                Link("Privacy Policy", destination: privacyPolicyURL)
                Link("Source Code (GitHub)", destination: githubURL)
            }

            Section(header: Text("Setup")) {
                Button {
                    showOnboarding = true
                } label: {
                    HStack {
                        Label("Replay Welcome Tour", systemImage: "sparkles")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(ShortlessTheme.textTertiary)
                    }
                }
            }

            Section(header: Text("Widgets")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add Shortless to your Home Screen")
                        .font(.system(size: ShortlessTheme.bodySize, weight: .medium))
                        .foregroundColor(ShortlessTheme.textPrimary)
                    Text("Long-press your Home Screen, tap the + button in the top corner, then search for \"Shortless\" to add the Time Reclaimed widget.")
                        .font(.system(size: ShortlessTheme.captionSize))
                        .foregroundColor(ShortlessTheme.textTertiary)
                }
            }

            Section(header: Text("How It Works")) {
                Text("Shortless blocks short-form video content using two layers:")
                    .font(.system(size: ShortlessTheme.captionSize))
                    .foregroundColor(ShortlessTheme.textSecondary)

                bulletPoint("Content Blocker", detail: "Declarative rules that block URLs and hide UI elements before they load.")
                bulletPoint("Web Extension", detail: "Content scripts that redirect short-form URLs and catch dynamically loaded content.")
            }

            Section(header: Text("Why Block Shorts?")) {
                bulletPoint("Attention Fragmentation", detail: "Studies show short-form video reduces sustained attention span, making it harder to focus on longer tasks.")
                bulletPoint("Algorithmic Loops", detail: "Infinite scroll feeds exploit dopamine-driven reward cycles, averaging 90+ minutes of daily unplanned screen time.")
                bulletPoint("You Deserve the Choice", detail: "Shortless doesn't block platforms — it removes the addictive feed so you use them intentionally.")
            }

            Section(header: Text("Limitations")) {
                Text("Shortless blocks short-form content in Safari only. Third-party browsers on iOS do not support content blocking extensions, and native apps (including TikTok) cannot be blocked without system-level permissions.")
                    .font(.system(size: ShortlessTheme.captionSize))
                    .foregroundColor(ShortlessTheme.textTertiary)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showOnboarding) {
            NavigationStack {
                OnboardingContainerView(settings: settings)
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    // These URLs are compile-time constants — safe to force-unwrap, but using
    // guard-let for defensive coding and App Store review safety.
    private var privacyPolicyURL: URL {
        guard let url = URL(string: "https://github.com/pmartin1915/shortless-ios/blob/master/PRIVACY_POLICY.md") else {
            return URL(string: "https://github.com/pmartin1915/shortless-ios")!
        }
        return url
    }

    private var githubURL: URL {
        guard let url = URL(string: "https://github.com/pmartin1915/shortless-ios") else {
            return URL(string: "https://github.com/pmartin1915")!
        }
        return url
    }

    private func bulletPoint(_ title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: ShortlessTheme.bodySize, weight: .medium))
                .foregroundColor(ShortlessTheme.textPrimary)
            Text(detail)
                .font(.system(size: ShortlessTheme.captionSize))
                .foregroundColor(ShortlessTheme.textTertiary)
        }
    }
}
