import SwiftUI
import SafariServices
import ShortlessKit

/// Main screen — 4 platform toggle cards + block counter.
/// Layout matches the browser extension popup.
struct DashboardView: View {
    @ObservedObject var settings: SettingsStore
    @ObservedObject var blockCount: BlockCountStore
    @StateObject private var vpnManager = VPNManager()
    @State private var showOnboarding = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ShortlessTheme.sectionSpacing) {
                    header
                    platformCards
                    vpnSection
                    footer
                }
                .padding(ShortlessTheme.containerPadding)
            }
            .background(ShortlessTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .foregroundColor(ShortlessTheme.textTertiary)
                    }
                }
            }
            .sheet(isPresented: $showOnboarding) {
                OnboardingView()
            }
            .onAppear {
                checkFirstLaunch()
                blockCount.refresh()
                Task { await vpnManager.loadManager() }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    blockCount.refresh()
                    Task { await vpnManager.loadManager() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Shortless")
                    .font(.system(size: ShortlessTheme.titleSize, weight: .bold))
                    .foregroundColor(ShortlessTheme.textPrimary)
                    .tracking(-0.3)

                Text("v\(appVersion)")
                    .font(.system(size: ShortlessTheme.versionSize, weight: .medium))
                    .foregroundColor(ShortlessTheme.textTertiary)
            }

            Text("Block the Scroll. Keep the Content.")
                .font(.system(size: ShortlessTheme.captionSize))
                .foregroundColor(ShortlessTheme.textTertiary)
                .tracking(0.2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Platform Cards

    private var platformCards: some View {
        VStack(spacing: ShortlessTheme.cardSpacing) {
            ForEach(Platform.allCases) { platform in
                PlatformCardView(
                    platform: platform,
                    isEnabled: Binding(
                        get: { settings.isEnabled(platform) },
                        set: { newValue in
                            settings.setEnabled(platform, newValue)
                            reloadContentBlocker()
                        }
                    )
                )
            }
        }
    }

    // MARK: - VPN Section

    private var vpnSection: some View {
        VStack(alignment: .leading, spacing: ShortlessTheme.cardSpacing) {
            Text("TIKTOK DNS FILTER")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(ShortlessTheme.textTertiary)
                .tracking(0.5)

            VPNCardView(
                isEnabled: Binding(
                    get: { settings.vpnEnabled },
                    set: { newValue in settings.setVPNEnabled(newValue) }
                ),
                vpnManager: vpnManager
            )
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(ShortlessTheme.footerBorder)
                .frame(height: 1)

            VStack(spacing: 6) {
                if settings.streakDays > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: ShortlessTheme.captionSize))
                            .foregroundColor(.orange)

                        Text("\(settings.streakDays) day\(settings.streakDays == 1 ? "" : "s") scroll-free")
                            .font(.system(size: ShortlessTheme.captionSize, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(settings.streakDays) days scroll-free streak")
                }

                HStack(spacing: 4) {
                    Text("Blocked today:")
                        .font(.system(size: ShortlessTheme.captionSize))
                        .foregroundColor(ShortlessTheme.textTertiary)

                    Text("\(blockCount.todayCount)")
                        .font(.system(size: ShortlessTheme.captionSize, weight: .semibold))
                        .foregroundColor(ShortlessTheme.accent)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Blocked \(blockCount.todayCount) elements today")
            }
            .padding(.top, 12)
        }
    }

    // MARK: - Helpers

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private func checkFirstLaunch() {
        let key = "hasCompletedOnboarding"
        guard let defaults = UserDefaults(suiteName: SettingsStore.appGroupID) else { return }
        if !defaults.bool(forKey: key) {
            showOnboarding = true
            defaults.set(true, forKey: key)
        }
    }

    private func reloadContentBlocker() {
        let identifier = "dev.pmartin1915.shortless.ContentBlocker"
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: identifier) { error in
            if let error {
                print("[Shortless] Content Blocker reload failed: \(error.localizedDescription)")
            }
        }
    }
}
