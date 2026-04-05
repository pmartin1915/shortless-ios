import SwiftUI
import SafariServices
import ShortlessKit

/// Main screen — 4 platform toggle cards + block counter.
/// Layout matches the browser extension popup.
struct DashboardView: View {
    @ObservedObject var settings: SettingsStore
    @ObservedObject var blockCount: BlockCountStore
    @State private var showOnboarding = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ShortlessTheme.sectionSpacing) {
                    header
                    platformCards
                    wellbeingSection
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
            .onAppear {
                checkFirstLaunch()
                blockCount.refresh()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    blockCount.refresh()
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
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    )
                )
            }
        }
    }

    // MARK: - Wellbeing Section

    private var wellbeingSection: some View {
        VStack(alignment: .leading, spacing: ShortlessTheme.cardSpacing) {
            Text("WELLBEING")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(ShortlessTheme.textTertiary)
                .tracking(0.5)

            NavigationLink(destination: StatsView(blockCount: blockCount, settings: settings)) {
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Time Reclaimed")
                                .font(.system(size: ShortlessTheme.captionSize, weight: .semibold))
                                .foregroundColor(ShortlessTheme.textTertiary)
                                .textCase(.uppercase)
                                .tracking(0.3)

                            Text(formattedTimeReclaimed)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(ShortlessTheme.textPrimary)

                            if blockCount.totalCount == 0 {
                                Text("Start browsing to track your progress")
                                    .font(.system(size: ShortlessTheme.captionSize))
                                    .foregroundColor(ShortlessTheme.textTertiary)
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ShortlessTheme.accent.opacity(0.6))
                    }

                    HStack(spacing: 16) {
                        if settings.streakDays > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: ShortlessTheme.captionSize))
                                    .foregroundColor(.orange)
                                Text("\(settings.streakDays)d streak")
                                    .font(.system(size: ShortlessTheme.captionSize, weight: .semibold))
                                    .foregroundColor(.orange)
                            }
                        }

                        HStack(spacing: 4) {
                            Text("Today:")
                                .font(.system(size: ShortlessTheme.captionSize))
                                .foregroundColor(ShortlessTheme.textTertiary)
                            Text("\(blockCount.todayCount)")
                                .font(.system(size: ShortlessTheme.captionSize, weight: .semibold))
                                .foregroundColor(ShortlessTheme.accent)
                        }

                        Spacer()

                        Text("View stats")
                            .font(.system(size: ShortlessTheme.captionSize))
                            .foregroundColor(ShortlessTheme.accent)
                    }
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
        let key = "hasCompletedOnboarding_v2.1"
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
