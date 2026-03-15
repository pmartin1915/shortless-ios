import SwiftUI
import NetworkExtension

/// VPN toggle card for DNS-level TikTok blocking.
/// Visually distinct from per-platform cards to communicate system-wide scope.
struct VPNCardView: View {
    @Binding var isEnabled: Bool
    @ObservedObject var vpnManager: VPNManager
    @State private var showExplanation = false
    @State private var showVPNConflict = false

    /// Tracks whether user has seen the VPN explanation before.
    @AppStorage("hasSeenVPNExplanation", store: UserDefaults(suiteName: "group.dev.pmartin1915.shortless"))
    private var hasSeenExplanation = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(vpnManager.isActive ? ShortlessTheme.accent : ShortlessTheme.textTertiary)
                    .frame(width: 32, height: 32)

                // Labels
                VStack(alignment: .leading, spacing: 2) {
                    Text("TikTok DNS Block")
                        .font(.system(size: ShortlessTheme.bodySize, weight: .semibold))
                        .foregroundColor(ShortlessTheme.textPrimary)

                    Text(vpnManager.statusText)
                        .font(.system(size: ShortlessTheme.captionSize))
                        .foregroundColor(statusColor)
                }

                Spacer()

                // Toggle
                Toggle("", isOn: Binding(
                    get: { vpnManager.isActive },
                    set: { newValue in handleToggle(newValue) }
                ))
                .labelsHidden()
                .tint(ShortlessTheme.accent)
            }
            .padding(ShortlessTheme.cardPadding)

            // Subtitle
            Text("Blocks TikTok across all apps, not just Safari")
                .font(.system(size: 11))
                .foregroundColor(ShortlessTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, ShortlessTheme.cardPadding)
                .padding(.bottom, 10)
        }
        .background(ShortlessTheme.cardFill)
        .overlay(
            RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius)
                .stroke(ShortlessTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: ShortlessTheme.cardCornerRadius))
        .alert("Local VPN Required", isPresented: $showExplanation) {
            Button("Enable") {
                hasSeenExplanation = true
                vpnManager.startTunnel()
                isEnabled = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Shortless uses a local VPN to block TikTok at the DNS level. No data leaves your device.\n\niOS will show a VPN icon in the status bar while active.")
        }
        .alert("VPN Conflict", isPresented: $showVPNConflict) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Another VPN is currently active. iOS only allows one VPN at a time. Please disable your other VPN first.")
        }
    }

    // MARK: - Helpers

    private var statusColor: Color {
        switch vpnManager.connectionStatus {
        case .connected:    return ShortlessTheme.accent
        case .connecting, .disconnecting, .reasserting: return .yellow
        default:            return ShortlessTheme.textTertiary
        }
    }

    private func handleToggle(_ newValue: Bool) {
        if newValue {
            // Check for VPN conflict
            if vpnManager.isOtherVPNActive {
                showVPNConflict = true
                return
            }

            // Show explanation on first use
            if !hasSeenExplanation {
                showExplanation = true
                return
            }

            vpnManager.startTunnel()
            isEnabled = true
        } else {
            vpnManager.stopTunnel()
            isEnabled = false
        }
    }
}
