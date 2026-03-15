import Foundation

/// Parsed addressing info from an IP+UDP packet containing a DNS query.
public struct DNSPacketInfo {
    public let srcIP: Data       // 4 bytes (IPv4)
    public let dstIP: Data       // 4 bytes (IPv4)
    public let srcPort: UInt16
    public let dstPort: UInt16
    public let dnsPayload: Data
    public let ipHeaderLength: Int
}

/// Parses and constructs IPv4 + UDP packets for DNS traffic.
/// Used by the VPN extension to read DNS queries from packetFlow
/// and write DNS responses back.
public enum IPPacketHelper {

    /// Extracts a DNS payload from a raw IPv4+UDP packet.
    ///
    /// Validates:
    /// - IPv4 (version nibble = 4)
    /// - Protocol = 17 (UDP)
    /// - Destination port = 53 (DNS)
    ///
    /// - Parameter ipPacket: Raw IP packet from `packetFlow.readPackets`.
    /// - Returns: Parsed packet info, or `nil` if not a DNS query.
    public static func extractDNSPayload(from ipPacket: Data) -> DNSPacketInfo? {
        guard ipPacket.count >= 28 else { return nil } // min IP (20) + UDP (8)

        let base = ipPacket.startIndex

        // Verify IPv4
        let versionIHL = ipPacket[base]
        guard versionIHL >> 4 == 4 else { return nil }

        let ihl = Int(versionIHL & 0x0F) * 4
        guard ihl >= 20, ipPacket.count >= ihl + 8 else { return nil }

        // Verify protocol = UDP (17)
        let proto = ipPacket[base + 9]
        guard proto == 17 else { return nil }

        // Source and destination IP addresses
        let srcIP = ipPacket[(base + 12)..<(base + 16)]
        let dstIP = ipPacket[(base + 16)..<(base + 20)]

        // UDP header starts at offset ihl
        let udpBase = base + ihl
        let srcPort = UInt16(ipPacket[udpBase]) << 8 | UInt16(ipPacket[udpBase + 1])
        let dstPort = UInt16(ipPacket[udpBase + 2]) << 8 | UInt16(ipPacket[udpBase + 3])

        // Only process DNS traffic (destination port 53)
        guard dstPort == 53 else { return nil }

        // UDP payload = everything after the 8-byte UDP header
        let dnsStart = udpBase + 8
        guard dnsStart < ipPacket.endIndex else { return nil }
        let dnsPayload = ipPacket[dnsStart..<ipPacket.endIndex]

        return DNSPacketInfo(
            srcIP: Data(srcIP),
            dstIP: Data(dstIP),
            srcPort: srcPort,
            dstPort: dstPort,
            dnsPayload: Data(dnsPayload),
            ipHeaderLength: ihl
        )
    }

    /// Wraps a DNS response payload in IPv4 + UDP headers, replying to the original query packet.
    ///
    /// Swaps source/destination addresses and ports from the original packet info
    /// so the response is routed back to the querying process.
    ///
    /// - Parameters:
    ///   - dnsPayload: The DNS response payload (e.g. from `DNSResponseBuilder.nxdomain`).
    ///   - original: The parsed info from the original DNS query packet.
    /// - Returns: A complete IPv4+UDP packet ready for `packetFlow.writePackets`.
    public static func wrapDNSResponse(_ dnsPayload: Data, replyingTo original: DNSPacketInfo) -> Data {
        let ipHeaderLength = 20 // fixed, no options
        let udpLength = 8 + dnsPayload.count
        let totalLength = ipHeaderLength + udpLength

        var packet = Data(count: totalLength)

        // --- IPv4 Header (20 bytes) ---

        // Version (4) + IHL (5 = 20 bytes)
        packet[0] = 0x45

        // DSCP / ECN
        packet[1] = 0x00

        // Total length (big-endian)
        packet[2] = UInt8((totalLength >> 8) & 0xFF)
        packet[3] = UInt8(totalLength & 0xFF)

        // Identification
        packet[4] = 0x00
        packet[5] = 0x00

        // Flags (Don't Fragment) + Fragment offset
        packet[6] = 0x40
        packet[7] = 0x00

        // TTL
        packet[8] = 64

        // Protocol = UDP
        packet[9] = 17

        // Header checksum (initially 0, computed below)
        packet[10] = 0x00
        packet[11] = 0x00

        // Source IP = original destination (we are the "DNS server")
        packet.replaceSubrange(12..<16, with: original.dstIP)

        // Destination IP = original source (reply to querier)
        packet.replaceSubrange(16..<20, with: original.srcIP)

        // Compute IP header checksum
        let checksum = ipHeaderChecksum(Data(packet[0..<20]))
        packet[10] = UInt8((checksum >> 8) & 0xFF)
        packet[11] = UInt8(checksum & 0xFF)

        // --- UDP Header (8 bytes) ---
        let udpBase = ipHeaderLength

        // Source port = original destination port (53)
        packet[udpBase] = UInt8((original.dstPort >> 8) & 0xFF)
        packet[udpBase + 1] = UInt8(original.dstPort & 0xFF)

        // Destination port = original source port
        packet[udpBase + 2] = UInt8((original.srcPort >> 8) & 0xFF)
        packet[udpBase + 3] = UInt8(original.srcPort & 0xFF)

        // UDP length (big-endian)
        packet[udpBase + 4] = UInt8((udpLength >> 8) & 0xFF)
        packet[udpBase + 5] = UInt8(udpLength & 0xFF)

        // UDP checksum (0 = disabled, valid for IPv4 UDP)
        packet[udpBase + 6] = 0x00
        packet[udpBase + 7] = 0x00

        // --- DNS Payload ---
        packet.replaceSubrange((udpBase + 8)..<totalLength, with: dnsPayload)

        return packet
    }

    /// Computes the IPv4 header checksum (RFC 1071).
    private static func ipHeaderChecksum(_ header: Data) -> UInt16 {
        var sum: UInt32 = 0
        let base = header.startIndex

        for i in stride(from: 0, to: header.count, by: 2) {
            let word: UInt16
            if i + 1 < header.count {
                word = UInt16(header[base + i]) << 8 | UInt16(header[base + i + 1])
            } else {
                word = UInt16(header[base + i]) << 8
            }
            sum += UInt32(word)
        }

        // Fold 32-bit sum to 16 bits
        while sum >> 16 != 0 {
            sum = (sum & 0xFFFF) + (sum >> 16)
        }

        return ~UInt16(sum & 0xFFFF)
    }
}
