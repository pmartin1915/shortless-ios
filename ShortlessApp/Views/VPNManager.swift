import NetworkExtension
import Combine

/// Manages the NETunnelProviderManager lifecycle for the Shortless DNS filter VPN.
/// Handles loading, creating, starting, stopping, and observing the tunnel connection.
final class VPNManager: ObservableObject {

    @Published var connectionStatus: NEVPNStatus = .disconnected
    @Published var isOtherVPNActive: Bool = false

    private var manager: NETunnelProviderManager?
    private var statusObserver: NSObjectProtocol?

    private static let tunnelDescription = "Shortless DNS Filter"
    private static let providerBundleID = "dev.pmartin1915.shortless.VPNExtension"

    init() {
        statusObserver = NotificationCenter.default.addObserver(
            forName: .NEVPNStatusDidChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let connection = notification.object as? NEVPNConnection else { return }
            self?.connectionStatus = connection.status
        }
    }

    deinit {
        if let observer = statusObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Load

    /// Loads the existing tunnel configuration, or detects that none exists.
    /// Also checks whether another (non-Shortless) VPN is active.
    func loadManager() async {
        do {
            let managers = try await NETunnelProviderManager.loadAllFromPreferences()

            // Find our manager
            manager = managers.first { mgr in
                (mgr.protocolConfiguration as? NETunnelProviderProtocol)?
                    .providerBundleIdentifier == Self.providerBundleID
            }

            // Check for other VPNs
            let otherManagers = managers.filter { mgr in
                (mgr.protocolConfiguration as? NETunnelProviderProtocol)?
                    .providerBundleIdentifier != Self.providerBundleID
            }
            await MainActor.run {
                isOtherVPNActive = otherManagers.contains { $0.connection.status != .disconnected }
                connectionStatus = manager?.connection.status ?? .disconnected
            }
        } catch {
            NSLog("[Shortless] Failed to load VPN managers: \(error.localizedDescription)")
        }
    }

    // MARK: - Start

    /// Creates the tunnel configuration (if needed) and starts the VPN tunnel.
    func startTunnel() {
        if let manager {
            enableAndStart(manager)
        } else {
            createAndStart()
        }
    }

    private func createAndStart() {
        let newManager = NETunnelProviderManager()
        newManager.localizedDescription = Self.tunnelDescription

        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = Self.providerBundleID
        proto.serverAddress = "localhost" // required field, not used (local tunnel)
        newManager.protocolConfiguration = proto
        newManager.isEnabled = true

        newManager.saveToPreferences { [weak self] error in
            if let error {
                NSLog("[Shortless] Failed to save VPN config: \(error.localizedDescription)")
                return
            }

            // Must reload after save (Apple requirement)
            newManager.loadFromPreferences { [weak self] error in
                if let error {
                    NSLog("[Shortless] Failed to reload VPN config: \(error.localizedDescription)")
                    return
                }

                self?.manager = newManager
                self?.startConnection(newManager)
            }
        }
    }

    private func enableAndStart(_ manager: NETunnelProviderManager) {
        manager.isEnabled = true
        manager.saveToPreferences { [weak self] error in
            if let error {
                NSLog("[Shortless] Failed to enable VPN: \(error.localizedDescription)")
                return
            }

            manager.loadFromPreferences { [weak self] error in
                if let error {
                    NSLog("[Shortless] Failed to reload VPN config: \(error.localizedDescription)")
                    return
                }
                self?.startConnection(manager)
            }
        }
    }

    private func startConnection(_ manager: NETunnelProviderManager) {
        do {
            try manager.connection.startVPNTunnel()
        } catch {
            NSLog("[Shortless] Failed to start VPN tunnel: \(error.localizedDescription)")
        }
    }

    // MARK: - Stop

    /// Stops the VPN tunnel.
    func stopTunnel() {
        manager?.connection.stopVPNTunnel()
    }

    // MARK: - Status Helpers

    /// Human-readable status string for the UI.
    var statusText: String {
        switch connectionStatus {
        case .connected:    return "Active"
        case .connecting:   return "Connecting..."
        case .disconnecting: return "Disconnecting..."
        case .reasserting:  return "Reconnecting..."
        case .invalid:      return "Not Configured"
        case .disconnected: return "Disconnected"
        @unknown default:   return "Unknown"
        }
    }

    /// Whether the tunnel is currently connected or connecting.
    var isActive: Bool {
        connectionStatus == .connected || connectionStatus == .connecting
    }
}
