import NetworkExtension
import ShortlessKit

/// Local split-tunnel VPN that intercepts DNS queries and sinkholeshole TikTok domains.
///
/// Architecture:
/// - Routes ONLY DNS traffic (port 53) through the tunnel via split-tunnel config
/// - Reads raw IP packets from `packetFlow`
/// - Extracts DNS query domain names
/// - TikTok domains → synthesizes NXDOMAIN response (on-device, no network)
/// - All other domains → forwards to upstream DNS (1.1.1.1 / 8.8.8.8)
///
/// Memory budget: <5MB runtime. No Codable, no JSONDecoder, no heavy frameworks.
class PacketTunnelProvider: NEPacketTunnelProvider {

    // MARK: - Configuration

    private let primaryDNS = "1.1.1.1"
    private let fallbackDNS = "8.8.8.8"
    private let tunnelAddress = "10.8.0.2"
    private let tunnelDNS = "10.8.0.1"
    private let tunnelSubnet = "255.255.255.0"

    // MARK: - State

    private var udpSession: NWUDPSession?
    private var pendingQueries: [UInt16: DNSPacketInfo] = [:]
    private var cleanupTimer: DispatchSourceTimer?
    private let settings = SettingsStore()

    // Timestamps for pending query eviction
    private var queryTimestamps: [UInt16: Date] = [:]
    private let queryTimeout: TimeInterval = 10

    // MARK: - Tunnel Lifecycle

    override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let networkSettings = createTunnelSettings()

        setTunnelNetworkSettings(networkSettings) { [weak self] error in
            if let error {
                completionHandler(error)
                return
            }

            self?.setupUpstreamSession()
            self?.startCleanupTimer()
            self?.readPacketsLoop()
            completionHandler(nil)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        cleanupTimer?.cancel()
        cleanupTimer = nil
        udpSession?.cancel()
        udpSession = nil
        pendingQueries.removeAll()
        queryTimestamps.removeAll()
        completionHandler()
    }

    // MARK: - Tunnel Configuration

    private func createTunnelSettings() -> NEPacketTunnelNetworkSettings {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: tunnelDNS)

        // IPv4: assign tunnel address, route ONLY the virtual DNS IP through tunnel
        let ipv4 = NEIPv4Settings(addresses: [tunnelAddress], subnetMasks: [tunnelSubnet])
        ipv4.includedRoutes = [
            NEIPv4Route(destinationAddress: tunnelDNS, subnetMask: "255.255.255.255")
        ]
        settings.ipv4Settings = ipv4

        // DNS: point all DNS queries to our virtual tunnel DNS IP
        let dns = NEDNSSettings(servers: [tunnelDNS])
        dns.matchDomains = [""] // catch-all: match all domains
        settings.dnsSettings = dns

        // MTU
        settings.mtu = 1500

        return settings
    }

    // MARK: - Upstream DNS Session

    private func setupUpstreamSession() {
        createSession(to: primaryDNS)
    }

    private func createSession(to server: String) {
        let endpoint = NWHostEndpoint(hostname: server, port: "53")
        let session = createUDPSession(to: endpoint, from: nil)
        self.udpSession = session

        // Observe session state for failover
        session.addObserver(self, forKeyPath: "state", options: [.new], context: nil)

        // Start reading responses
        readUpstreamResponses(from: session)
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard keyPath == "state", let session = object as? NWUDPSession else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        if session.state == .failed {
            session.removeObserver(self, forKeyPath: "state")
            session.cancel()

            // Failover to secondary DNS
            if session === udpSession {
                createSession(to: fallbackDNS)
            }
        }
    }

    // MARK: - Packet Reading Loop

    private func readPacketsLoop() {
        packetFlow.readPackets { [weak self] packets, protocols in
            guard let self else { return }

            for (i, packet) in packets.enumerated() {
                self.processPacket(packet, protocol: protocols[i])
            }

            // Continue reading
            self.readPacketsLoop()
        }
    }

    private func processPacket(_ data: Data, protocol proto: NSNumber) {
        // Parse IP+UDP packet, extract DNS payload
        guard let packetInfo = IPPacketHelper.extractDNSPayload(from: data) else {
            // Not a DNS query — should not happen with our routing config, but write through
            packetFlow.writePackets([data], withProtocols: [proto])
            return
        }

        // Extract the queried domain name
        guard let domain = DNSParser.extractDomainName(from: packetInfo.dnsPayload) else {
            // Unparseable DNS — forward as-is
            forwardToUpstream(packetInfo, protocol: proto)
            return
        }

        // Check if TikTok is enabled for blocking and domain matches
        if settings.isEnabled(.tiktok) && TikTokDNSBlocklist.isBlocked(domain) {
            // Synthesize NXDOMAIN response
            let nxdomainPayload = DNSResponseBuilder.nxdomain(for: packetInfo.dnsPayload)
            let responsePacket = IPPacketHelper.wrapDNSResponse(nxdomainPayload, replyingTo: packetInfo)
            packetFlow.writePackets([responsePacket], withProtocols: [proto])
            return
        }

        // Forward non-blocked queries to upstream DNS
        forwardToUpstream(packetInfo, protocol: proto)
    }

    // MARK: - Upstream Forwarding

    private func forwardToUpstream(_ packetInfo: DNSPacketInfo, protocol proto: NSNumber) {
        guard let session = udpSession, session.state == .ready else { return }

        // Store the original packet info so we can construct the response packet
        if let txID = DNSParser.extractTransactionID(from: packetInfo.dnsPayload) {
            pendingQueries[txID] = packetInfo
            queryTimestamps[txID] = Date()
        }

        session.writeDatagram(packetInfo.dnsPayload) { error in
            if let error {
                NSLog("[Shortless VPN] Upstream write error: \(error.localizedDescription)")
            }
        }
    }

    private func readUpstreamResponses(from session: NWUDPSession) {
        session.setReadHandler({ [weak self] datagrams, error in
            guard let self, let datagrams else { return }

            for datagram in datagrams {
                self.handleUpstreamResponse(datagram)
            }
        }, maxDatagrams: 64)
    }

    private func handleUpstreamResponse(_ dnsResponse: Data) {
        // Extract transaction ID to find the matching pending query
        guard let txID = DNSParser.extractTransactionID(from: dnsResponse),
              let originalInfo = pendingQueries.removeValue(forKey: txID) else {
            return
        }
        queryTimestamps.removeValue(forKey: txID)

        // Wrap the DNS response in IP+UDP headers to send back through the tunnel
        let responsePacket = IPPacketHelper.wrapDNSResponse(dnsResponse, replyingTo: originalInfo)
        packetFlow.writePackets([responsePacket], withProtocols: [AF_INET as NSNumber])
    }

    // MARK: - Cleanup

    private func startCleanupTimer() {
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + queryTimeout, repeating: queryTimeout)
        timer.setEventHandler { [weak self] in
            self?.evictStaleQueries()
        }
        timer.resume()
        cleanupTimer = timer
    }

    private func evictStaleQueries() {
        let now = Date()
        let staleIDs = queryTimestamps.filter { now.timeIntervalSince($0.value) > queryTimeout }.map(\.key)
        for id in staleIDs {
            pendingQueries.removeValue(forKey: id)
            queryTimestamps.removeValue(forKey: id)
        }
    }
}
