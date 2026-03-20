import SwiftUI
import FamilyControls
import ManagedSettings
import ShortlessKit

/// Lets users pick native apps to block entirely using Apple's Screen Time API.
/// Requires the Family Controls entitlement (com.apple.developer.family-controls).
struct AppBlockerView: View {
    @State private var selection = FamilyActivitySelection()
    @State private var isPickerPresented = false
    @State private var isAuthorized = false
    @State private var isBlocking = false

    private let store = ManagedSettingsStore(named: .shortless)

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
                // Selected apps summary
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

                // Choose apps button
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

                // Block toggle
                if !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty {
                    Toggle(isOn: $isBlocking) {
                        HStack(spacing: 8) {
                            Image(systemName: isBlocking ? "shield.checkered" : "shield.slash")
                                .foregroundColor(isBlocking ? ShortlessTheme.accent : ShortlessTheme.textTertiary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(isBlocking ? "Blocking Active" : "Blocking Paused")
                                    .font(.system(size: ShortlessTheme.bodySize, weight: .semibold))
                                    .foregroundColor(ShortlessTheme.textPrimary)
                                Text(isBlocking ? "Selected apps are shielded" : "Tap to enable blocking")
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
                    .onChange(of: isBlocking) { blocking in
                        if blocking {
                            applyShield()
                        } else {
                            clearShield()
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }

                // Explanation
                VStack(alignment: .leading, spacing: 8) {
                    Text("How it works")
                        .font(.system(size: ShortlessTheme.bodySize, weight: .medium))
                        .foregroundColor(ShortlessTheme.textPrimary)
                    Text("When blocking is active, selected apps show a shield screen instead of opening. This works across your entire device, not just Safari. You can disable blocking anytime.")
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
        }
    }

    // MARK: - Screen Time API

    private func checkAuthorization() async {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        if isAuthorized {
            loadSelection()
        }
    }

    private func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = true
        } catch {
            print("[Shortless] Screen Time authorization failed: \(error)")
        }
    }

    private func applyShield() {
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
    }

    private func clearShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }

    // MARK: - Persistence

    private func saveSelection() {
        guard let defaults = UserDefaults(suiteName: SettingsStore.appGroupID) else { return }
        if let data = try? JSONEncoder().encode(selection) {
            defaults.set(data, forKey: "appBlockerSelection")
        }
        defaults.set(isBlocking, forKey: "appBlockerEnabled")
    }

    private func loadSelection() {
        guard let defaults = UserDefaults(suiteName: SettingsStore.appGroupID) else { return }
        if let data = defaults.data(forKey: "appBlockerSelection"),
           let saved = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            selection = saved
        }
        isBlocking = defaults.bool(forKey: "appBlockerEnabled")
        if isBlocking && !selection.applicationTokens.isEmpty {
            applyShield()
        }
    }
}

// MARK: - Named Store

extension ManagedSettingsStore.Name {
    static let shortless = ManagedSettingsStore.Name("shortless")
}
