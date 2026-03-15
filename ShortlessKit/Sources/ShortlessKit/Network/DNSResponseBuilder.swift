import Foundation

/// Constructs DNS response packets.
/// Used by the VPN extension to synthesize NXDOMAIN replies for blocked domains.
public enum DNSResponseBuilder {

    /// Builds an NXDOMAIN (name not found) DNS response for the given query.
    ///
    /// The response:
    /// - Copies the transaction ID from the query
    /// - Sets the QR bit (response), RA bit (recursion available), and RCODE=3 (NXDOMAIN)
    /// - Echoes the question section
    /// - Contains zero answer, authority, and additional records
    ///
    /// - Parameter query: The original DNS query payload (UDP payload, no IP/UDP headers).
    /// - Returns: A complete DNS response payload ready to be wrapped in UDP/IP.
    public static func nxdomain(for query: Data) -> Data {
        guard let questionEnd = DNSParser.questionSectionEnd(in: query),
              query.count >= 12 else {
            // Fallback: return minimal NXDOMAIN with just the header
            var minimal = Data(count: 12)
            if query.count >= 2 {
                minimal[0] = query[query.startIndex]
                minimal[1] = query[query.startIndex + 1]
            }
            minimal[2] = 0x81 // QR=1, RD=1
            minimal[3] = 0x83 // RA=1, RCODE=3 (NXDOMAIN)
            return minimal
        }

        let questionSectionLength = questionEnd - (query.startIndex + 12)
        var response = Data(capacity: 12 + questionSectionLength)

        // --- Header (12 bytes) ---

        // Transaction ID (bytes 0-1): copy from query
        response.append(query[query.startIndex])
        response.append(query[query.startIndex + 1])

        // Flags (bytes 2-3):
        // Byte 2: QR=1 (response), Opcode=0000, AA=0, TC=0, RD=1 → 0x81
        // Byte 3: RA=1, Z=000, RCODE=0011 (NXDOMAIN) → 0x83
        response.append(0x81)
        response.append(0x83)

        // QDCOUNT (bytes 4-5): 1 question (echo the query's question)
        response.append(0x00)
        response.append(0x01)

        // ANCOUNT (bytes 6-7): 0 answers
        response.append(0x00)
        response.append(0x00)

        // NSCOUNT (bytes 8-9): 0 authority records
        response.append(0x00)
        response.append(0x00)

        // ARCOUNT (bytes 10-11): 0 additional records
        response.append(0x00)
        response.append(0x00)

        // --- Question Section ---
        // Copy QNAME + QTYPE + QCLASS from the original query
        let questionStart = query.startIndex + 12
        response.append(query[questionStart..<questionEnd])

        return response
    }
}
