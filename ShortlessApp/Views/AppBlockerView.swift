import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity
import ShortlessKit

/// Lets users pick native apps to block using Apple's Screen Time API,
/// with optional scheduling via DeviceActivityCenter.
struct AppBlockerView: View {
    @ObservedObject var settings: SettingsStore
    @State private var selection = FamilyActivitySelection()
    @State private var isPickerPresented = false
    @State private var isAuthorized = false
    @State private var blockingMode: BlockingMode = .alwaysOn
    @State private var scheduleRule = ScheduleRule()
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    @State private var authError: String?
    @StateObject private var scheduleManager = ScheduleManager()

    private let store = ManagedSettingsStore(named: .shortless)

    enum BlockingMode: String, CaseIterable {
        case alwaysOn = "alwaysOn"
        case scheduled = "scheduled"

        var displayName: String {
            switch self {
            case .alwaysOn: return "Always On"
            case .scheduled: return "Scheduled"
            }
        }
    }

    var body: some View {
        VStack(spacing: ShortlessTheme.sectionSpacing) {
            if !isAuthorized {
                authorizationPrompt
            } else {
                blockingControls
            }
        }
        .padding(ShortlessTheme.containerPadding)
        .background(ShortlessTheme.background.ignoresSafeArea())
        .navigationTitle("App Blocking")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .task {
            await checkAuthorization()
        }
        .alert("Screen Time Access Required", isPresented: Binding(
            get: { authError != nil },
            set: { if !$0 { authError = nil } }
        )) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(authError ?? "Please enable Screen Time access in Settings to use app blocking.")
        }
    }

    // MARK: - Authorization

    private var authorizationPrompt: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 48))
                .foregroundColor(ShortlessTheme.accent)

            Text("Block Native Apps")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(ShortlessTheme.textPrimary)

            Text("Shortless can block entire apps across your device — not just in Safari. This uses Apple's Screen Time to prevent apps from opening.")
                .font(.system(size: ShortlessTheme.bodySize))
                .foregroundColor(ShortlessTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            Button {
                Task { await requestAuthorization() }
            } label: {
                Text("Enable App Blocking")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(ShortlessTheme.accent)
                    .cornerRadius(10)
            }
            .padding(.bottom, 48)
        }
    }

    // MARK: - Blocking Controls

    private var blockingControls: some View {
        ScrollView {
            VStack(spacing: ShortlessTheme.sectionSpacing) {
                appSelectionCard
                chooseAppsButton
                blockToggle
                modeSelector
                if blockingMode == .scheduled {
                    scheduleCard
                }
                explanationCard
            }
        }
    }

    // MARK: - App Selection Summary

    private var appSelectionCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "app.badge.checkmark.fill")
                .font(.system(size: 36))
                .foregroundColor(ShortlessTheme.accent)

            Text("\(selection.applicationTokens.count) app\(selection.applicationTokens.count == 1 ? "" : "s") selected")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(ShortlessTheme.textPrimary)

            if selection.categoryTokens.count > 0 {
                Text("+ \(selection.categoryTokens.count) categor\(selection.categoryTokens.count == 1 ? "y" : "ies")")
                    .font(.system(size: ShortlessTheme.captionSize))
                    .foregroundColor(ShortlessTheme.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(ShortlessTheme.cardFill)
        .overlay(
            RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius)
                .stroke(ShortlessTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius))
    }

    // MARK: - Choose Apps Button

    private var chooseAppsButton: some View {
        Button {
            isPickerPresented = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "plus.app")
                    .font(.system(size: 14))
                Text("Choose Apps to Block")
                    .font(.system(size: ShortlessTheme.bodySize, weight: .semibold))
            }
            .foregroundColor(ShortlessTheme.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(ShortlessTheme.cardFill)
            .overlay(
                RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius)
                    .stroke(ShortlessTheme.accent.opacity(0.4), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius))
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
        .onChange(of: selection) { _ in
            saveSelection()
        }
    }

    // MARK: - Block Toggle

    @ViewBuilder
    private var blockToggle: some View {
        if !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty {
            Toggle(isOn: Binding(
                get: { settings.appBlockerEnabled },
                set: { newValue in
                    settings.setAppBlockerEnabled(newValue)
                    if newValue {
                        applyBlocking()
                    } else {
                        clearBlocking()
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            )) {
                HStack(spacing: 8) {
                    Image(systemName: settings.appBlockerEnabled ? "shield.checkered" : "shield.slash")
                        .foregroundColor(settings.appBlockerEnabled ? ShortlessTheme.accent : ShortlessTheme.textTertiary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(settings.appBlockerEnabled ? "Blocking Active" : "Blocking Paused")
                            .font(.system(size: ShortlessTheme.bodySize, weight: .semibold))
                            .foregroundColor(ShortlessTheme.textPrimary)
                        Text(settings.appBlockerEnabled ? "Selected apps are shielded" : "Tap to enable blocking")
                            .font(.system(size: ShortlessTheme.captionSize))
                            .foregroundColor(ShortlessTheme.textTertiary)
                    }
                }
            }
            .tint(ShortlessTheme.accent)
            .padding(ShortlessTheme.cardPadding)
            .background(ShortlessTheme.cardFill)
            .overlay(
                RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius)
                    .stroke(ShortlessTheme.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius))
        }
    }

    // MARK: - Mode Selector

    @ViewBuilder
    private var modeSelector: some View {
        if settings.appBlockerEnabled {
            VStack(alignment: .leading, spacing: 8) {
                Text("BLOCKING MODE")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(ShortlessTheme.textTertiary)
                    .tracking(0.5)

                Picker("Mode", selection: $blockingMode) {
                    ForEach(BlockingMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: blockingMode) { newMode in
                    settings.setBlockingMode(newMode.rawValue)
                    if newMode == .alwaysOn {
                        scheduleManager.stopMonitoring()
                        settings.setSchedule(nil)
                        applyShield()
                    } else {
                        applySchedule()
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
    }

    // MARK: - Schedule Card

    private var scheduleCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Time range
            HStack {
                timeButton(label: "Start", hour: scheduleRule.startHour, minute: scheduleRule.startMinute) {
                    showStartTimePicker.toggle()
                    showEndTimePicker = false
                }

                Image(systemName: "arrow.right")
                    .font(.system(size: 12))
                    .foregroundColor(ShortlessTheme.textTertiary)

                timeButton(label: "End", hour: scheduleRule.endHour, minute: scheduleRule.endMinute) {
                    showEndTimePicker.toggle()
                    showStartTimePicker = false
                }
            }

            // Time pickers (inline)
            if showStartTimePicker {
                timePicker(hour: $scheduleRule.startHour, minute: $scheduleRule.startMinute)
            }
            if showEndTimePicker {
                timePicker(hour: $scheduleRule.endHour, minute: $scheduleRule.endMinute)
            }

            // Day-of-week pills
            HStack(spacing: 6) {
                ForEach(ScheduleRule.dayLabels, id: \.weekday) { day in
                    dayPill(weekday: day.weekday, label: day.label)
                }
            }

            // Apply button
            Button {
                applySchedule()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                Text("Apply Schedule")
                    .font(.system(size: ShortlessTheme.bodySize, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(ShortlessTheme.accent)
                    .cornerRadius(ShortlessTheme.cardCornerRadius)
            }
        }
        .padding(ShortlessTheme.cardPadding)
        .background(ShortlessTheme.cardFill)
        .overlay(
            RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius)
                .stroke(ShortlessTheme.accent.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius))
    }

    // MARK: - Schedule Subviews

    private func timeButton(label: String, hour: Int, minute: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(ShortlessTheme.textTertiary)
                Text(ScheduleRule.formatTimeStatic(hour: hour, minute: minute))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(ShortlessTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(ShortlessTheme.background)
            .cornerRadius(8)
        }
    }

    private func timePicker(hour: Binding<Int>, minute: Binding<Int>) -> some View {
        let date = Binding<Date>(
            get: {
                Calendar.current.date(from: DateComponents(hour: hour.wrappedValue, minute: minute.wrappedValue)) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                hour.wrappedValue = components.hour ?? 0
                minute.wrappedValue = components.minute ?? 0
            }
        )
        return DatePicker("", selection: date, displayedComponents: .hourAndMinute)
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxHeight: 120)
    }

    private func dayPill(weekday: Int, label: String) -> some View {
        let isActive = scheduleRule.activeDays.contains(weekday)
        return Button {
            if isActive {
                scheduleRule.activeDays.remove(weekday)
            } else {
                scheduleRule.activeDays.insert(weekday)
            }
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isActive ? .white : ShortlessTheme.textTertiary)
                .frame(width: 40, height: 36)
                .background(isActive ? ShortlessTheme.accent : ShortlessTheme.background)
                .clipShape(Circle())
        }
    }

    // MARK: - Explanation

    private var explanationCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How it works")
                .font(.system(size: ShortlessTheme.bodySize, weight: .medium))
                .foregroundColor(ShortlessTheme.textPrimary)
            Text("When blocking is active, selected apps show a shield screen instead of opening. This works across your entire device, not just Safari.\n\nIn \"Always On\" mode, apps are blocked until you turn it off. In \"Scheduled\" mode, apps are blocked only during your set times.")
                .font(.system(size: ShortlessTheme.captionSize))
                .foregroundColor(ShortlessTheme.textTertiary)
        }
        .padding(ShortlessTheme.cardPadding)
        .background(ShortlessTheme.cardFill)
        .overlay(
            RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius)
                .stroke(ShortlessTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius))
    }

    // MARK: - Screen Time API

    private func checkAuthorization() async {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        if isAuthorized {
            loadState()
        }
    }

    private func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = true
        } catch {
            isAuthorized = false
            authError = "Screen Time authorization was denied. Go to Settings > Screen Time to enable access for Shortless."
            print("[Shortless] Screen Time authorization failed: \(error)")
        }
    }

    // MARK: - Blocking Logic

    private func applyBlocking() {
        if blockingMode == .scheduled {
            applySchedule()
        } else {
            applyShield()
        }
    }

    private func clearBlocking() {
        scheduleManager.stopMonitoring()
        clearShield()
    }

    private func applyShield() {
        store.shield.applications = selection.applicationTokens
        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }
    }

    private func clearShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }

    private func applySchedule() {
        scheduleRule.isEnabled = true
        settings.setSchedule(scheduleRule)
        saveSelection()

        // Clear the direct shield — let DeviceActivityMonitor handle it on schedule
        clearShield()
        scheduleManager.startMonitoring(schedule: scheduleRule)
    }

    // MARK: - Persistence

    private func saveSelection() {
        guard let defaults = UserDefaults(suiteName: SettingsStore.appGroupID) else { return }
        if let data = try? JSONEncoder().encode(selection) {
            defaults.set(data, forKey: SettingsStore.appBlockerSelectionKey)
        }
    }

    private func loadState() {
        guard let defaults = UserDefaults(suiteName: SettingsStore.appGroupID) else { return }

        // Load app selection
        if let data = defaults.data(forKey: SettingsStore.appBlockerSelectionKey),
           let saved = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            selection = saved
        }

        // Load schedule and mode
        if let rule = settings.schedule {
            scheduleRule = rule
        }
        blockingMode = BlockingMode(rawValue: settings.blockingMode) ?? .alwaysOn
    }
}

// MARK: - ScheduleRule Helper (static access for Views)

extension ScheduleRule {
    static func formatTimeStatic(hour: Int, minute: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", displayHour, minute, period)
    }
}
