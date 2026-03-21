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
    @State private var showMindfulBreak = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ShortlessTheme.sectionSpacing) {
                    header
                    wellbeingHero
                    mindfulBreakButton
                    platformSection
                    vpnSection
                }
                .padding(ShortlessTheme.containerPadding)
            }
            .background(ShortlessTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(settings: settings)) {
                        Image(systemName: "gearshape")
                            .foregroundColor(ShortlessTheme.textTertiary)
                    }
                }
            }
            .sheet(isPresented: $showOnboarding) {
                NavigationStack {
                    OnboardingContainerView(settings: settings)
                }
            }
            .sheet(isPresented: $showMindfulBreak) {
                MindfulBreakView()
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

    // MARK: - Wellbeing Hero

    private var wellbeingHero: some View {
        NavigationLink(destination: StatsView(blockCount: blockCount, settings: settings)) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TIME RECLAIMED")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(ShortlessTheme.accent.opacity(0.8))
                            .tracking(0.8)

                        Text(formattedTimeReclaimed)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(ShortlessTheme.textPrimary)

                        if blockCount.totalCount == 0 {
                            Text("Start browsing to track your progress")
                                .font(.system(size: ShortlessTheme.captionSize))
                                .foregroundColor(ShortlessTheme.textTertiary)
                        }
                    }

                    Spacer()

                    Image(systemName: "hourglass")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(ShortlessTheme.accent.opacity(0.4))
                }

                Divider()
                    .background(Color.white.opacity(0.08))

                HStack(spacing: 16) {
                    if settings.streakDays > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.orange)
                            Text("\(settings.streakDays)d streak")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.orange)
                        }
                    }

                    HStack(spacing: 4) {
                        Text("Today:")
                            .font(.system(size: 13))
                            .foregroundColor(ShortlessTheme.textTertiary)
                        Text("\(blockCount.todayCount)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(ShortlessTheme.accent)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Text("View stats")
                            .font(.system(size: 13))
                            .foregroundColor(ShortlessTheme.accent)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(ShortlessTheme.accent.opacity(0.6))
                    }
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [
                        ShortlessTheme.accent.opacity(0.08),
                        ShortlessTheme.cardFill
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ShortlessTheme.accent.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Mindful Break

    private var mindfulBreakButton: some View {
        Button {
            showMindfulBreak = true
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 16))

                VStack(alignment: .leading, spacing: 2) {
                    Text("I feel like scrolling")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Take a mindful break instead")
                        .font(.system(size: 12))
                        .opacity(0.7)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .opacity(0.5)
            }
            .foregroundColor(ShortlessTheme.accent)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(ShortlessTheme.accent.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ShortlessTheme.accent.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Platform Section

    private var platformSection: some View {
        VStack(alignment: .leading, spacing: ShortlessTheme.cardSpacing) {
            Text("PLATFORMS")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(ShortlessTheme.textTertiary)
                .tracking(0.5)

            ForEach(Platform.allCases) { platform in
                PlatformCardView(
                    platform: platform,
                    isEnabled: Binding(
                        get: { settings.isEnabled(platform) },
                        set: { newValue in
                            settings.setEnabled(platform, newValue)
                            reloadContentBlocker()
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
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

    // MARK: - App Blocking Section

    private var appBlockingSection: some View {
        VStack(alignment: .leading, spacing: ShortlessTheme.cardSpacing) {
            Text("APP BLOCKING")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(ShortlessTheme.textTertiary)
                .tracking(0.5)

            NavigationLink(destination: AppBlockerView()) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Block Native Apps")
                            .font(.system(size: ShortlessTheme.bodySize, weight: .semibold))
                            .foregroundColor(ShortlessTheme.textPrimary)
                        Text("Block apps system-wide using Screen Time")
                            .font(.system(size: ShortlessTheme.captionSize))
                            .foregroundColor(ShortlessTheme.textTertiary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(ShortlessTheme.accent.opacity(0.6))
                }
                .padding(ShortlessTheme.cardPadding)
                .background(ShortlessTheme.cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius)
                        .stroke(ShortlessTheme.cardBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius))
            }
            .buttonStyle(.plain)
        }
    }


    private var formattedTimeReclaimed: String {
        let totalSeconds = blockCount.timeReclaimed(secondsPerShort: settings.estimatedSecondsPerShort)
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "--"
        }
    }

    // MARK: - Helpers

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private func checkFirstLaunch() {
        let key = "hasCompletedOnboarding_v2.1.5"
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
