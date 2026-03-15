import Foundation

/// Low-level DNS packet parser.
/// Extracts domain names and transaction IDs from raw DNS query payloads.
/// Uses manual byte parsing to stay within the 15MB network extension memory limit.
public enum DNSParser {

    /// Minimum valid DNS header size (ID + flags + 4 count fields = 12 bytes).
    private static let headerSize = 12

    /// Extracts the queried domain name from a DNS payload.
    ///
    /// DNS wire format encodes names as a sequence of labels:
    /// `[length][label bytes][length][label bytes]...[0]`
    /// starting at byte offset 12 (after the 12-byte header).
    ///
    /// - Parameter dnsPayload: Raw DNS packet data (UDP payload, no IP/UDP headers).
    /// - Returns: The domain name (e.g. "api.tiktok.com"), or `nil` if parsing fails.
    public static func extractDomainName(from dnsPayload: Data) -> String? {
        guard dnsPayload.count >= headerSize + 1 else { return nil }

        // Verify QDCOUNT >= 1 (bytes 4-5, big-endian)
        let qdcount = UInt16(dnsPayload[dnsPayload.startIndex + 4]) << 8
                    | UInt16(dnsPayload[dnsPayload.startIndex + 5])
        guard qdcount >= 1 else { return nil }

        var offset = dnsPayload.startIndex + headerSize
        var labels: [String] = []

        while offset < dnsPayload.endIndex {
            let lengthByte = dnsPayload[offset]

            // Root label terminator
            if lengthByte == 0 {
                break
            }

            // Pointer (compression) — not expected in queries but handle gracefully
            if lengthByte & 0xC0 == 0xC0 {
                return nil
            }

            let labelLength = Int(lengthByte)
            offset += 1

            guard offset + labelLength <= dnsPayload.endIndex else { return nil }

            let labelData = dnsPayload[offset..<(offset + labelLength)]
            guard let label = String(bytes: labelData, encoding: .ascii) else { return nil }
            labels.append(label)

            offset += labelLength
        }

        guard !labels.isEmpty else { return nil }
        return labels.joined(separator: ".").lowercased()
    }

    /// Extracts the DNS transaction ID from a DNS payload.
    ///
    /// The transaction ID is the first 2 bytes of the DNS header (big-endian UInt16).
    ///
    /// - Parameter dnsPayload: Raw DNS packet data.
    /// - Returns: The 16-bit transaction ID, or `nil` if the payload is too short.
    public static func extractTransactionID(from dnsPayload: Data) -> UInt16? {
        guard dnsPayload.count >= 2 else { return nil }
        return UInt16(dnsPayload[dnsPayload.startIndex]) << 8
             | UInt16(dnsPayload[dnsPayload.startIndex + 1])
    }

    /// Returns the byte offset just past the question section's QNAME + QTYPE + QCLASS.
    /// Useful for copying the full question section into a response.
    ///
    /// - Parameter dnsPayload: Raw DNS packet data.
    /// - Returns: The end offset of the first question entry, or `nil` if parsing fails.
    public static func questionSectionEnd(in dnsPayload: Data) -> Data.Index? {
        guard dnsPayload.count >= headerSize + 1 else { return nil }

        var offset = dnsPayload.startIndex + headerSize

        // Skip QNAME labels
        while offset < dnsPayload.endIndex {
            let lengthByte = dnsPayload[offset]
            if lengthByte == 0 {
                offset += 1 // skip the root label terminator
                break
            }
            if lengthByte & 0xC0 == 0xC0 {
                offset += 2 // skip pointer
                break
            }
            offset += 1 + Int(lengthByte)
        }

        // Skip QTYPE (2 bytes) + QCLASS (2 bytes)
        offset += 4
        guard offset <= dnsPayload.endIndex else { return nil }
        return offset
    }
}
