import SwiftUI

/// About screen: version, privacy policy, GitHub link, setup guide.
struct SettingsView: View {
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
                        Label("Setup Guide", systemImage: "questionmark.circle")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(ShortlessTheme.textTertiary)
                    }
                }
            }

            Section(header: Text("How It Works")) {
                Text("Shortless blocks short-form video content in Safari using two layers:")
                    .font(.system(size: ShortlessTheme.captionSize))
                    .foregroundColor(ShortlessTheme.textSecondary)

                bulletPoint("Content Blocker", detail: "Declarative rules that block URLs and hide UI elements before they load.")
                bulletPoint("Web Extension", detail: "Content scripts that redirect short-form URLs and catch dynamically loaded content.")
            }

            Section(header: Text("Limitations")) {
                Text("Shortless only works in Safari. Third-party browsers (Chrome, Firefox) on iOS do not support content blocking extensions.")
                    .font(.system(size: ShortlessTheme.captionSize))
                    .foregroundColor(ShortlessTheme.textTertiary)

                Text("TikTok is blocked entirely (full domain block) since all TikTok content is short-form video.")
                    .font(.system(size: ShortlessTheme.captionSize))
                    .foregroundColor(ShortlessTheme.textTertiary)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showOnboarding) {
            OnboardingView()
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
