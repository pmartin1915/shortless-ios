import XCTest
@testable import ShortlessKit

final class DNSParserTests: XCTestCase {

    // MARK: - Test Data Helpers

    /// Builds a minimal DNS query packet for a given domain name.
    /// Format: 12-byte header + QNAME labels + 0x00 terminator + QTYPE(A=1) + QCLASS(IN=1)
    private func makeDNSQuery(domain: String, transactionID: UInt16 = 0xABCD) -> Data {
        var data = Data()

        // Transaction ID (2 bytes, big-endian)
        data.append(UInt8((transactionID >> 8) & 0xFF))
        data.append(UInt8(transactionID & 0xFF))

        // Flags: standard query (0x0100 = RD set)
        data.append(0x01)
        data.append(0x00)

        // QDCOUNT = 1
        data.append(0x00)
        data.append(0x01)

        // ANCOUNT = 0
        data.append(0x00)
        data.append(0x00)

        // NSCOUNT = 0
        data.append(0x00)
        data.append(0x00)

        // ARCOUNT = 0
        data.append(0x00)
        data.append(0x00)

        // QNAME: encode domain labels
        let labels = domain.split(separator: ".")
        for label in labels {
            data.append(UInt8(label.count))
            data.append(contentsOf: label.utf8)
        }
        data.append(0x00) // root label terminator

        // QTYPE = A (1)
        data.append(0x00)
        data.append(0x01)

        // QCLASS = IN (1)
        data.append(0x00)
        data.append(0x01)

        return data
    }

    // MARK: - Domain Extraction Tests

    func testExtractSimpleDomain() {
        let query = makeDNSQuery(domain: "tiktok.com")
        let domain = DNSParser.extractDomainName(from: query)
        XCTAssertEqual(domain, "tiktok.com")
    }

    func testExtractMultiLabelDomain() {
        let query = makeDNSQuery(domain: "api.tiktok.com")
        let domain = DNSParser.extractDomainName(from: query)
        XCTAssertEqual(domain, "api.tiktok.com")
    }

    func testExtractDeepSubdomain() {
        let query = makeDNSQuery(domain: "v16m.tiktokcdn.com")
        let domain = DNSParser.extractDomainName(from: query)
        XCTAssertEqual(domain, "v16m.tiktokcdn.com")
    }

    func testDomainIsLowercased() {
        // DNS labels in the packet are case-insensitive; our parser lowercases
        var query = makeDNSQuery(domain: "TikTok.COM")
        // The helper already encodes as-is, so check the parser normalizes
        let domain = DNSParser.extractDomainName(from: query)
        XCTAssertEqual(domain, "tiktok.com")
    }

    // MARK: - Transaction ID Tests

    func testExtractTransactionID() {
        let query = makeDNSQuery(domain: "tiktok.com", transactionID: 0x1234)
        let txID = DNSParser.extractTransactionID(from: query)
        XCTAssertEqual(txID, 0x1234)
    }

    func testExtractTransactionIDZero() {
        let query = makeDNSQuery(domain: "example.com", transactionID: 0x0000)
        let txID = DNSParser.extractTransactionID(from: query)
        XCTAssertEqual(txID, 0x0000)
    }

    func testExtractTransactionIDMax() {
        let query = makeDNSQuery(domain: "example.com", transactionID: 0xFFFF)
        let txID = DNSParser.extractTransactionID(from: query)
        XCTAssertEqual(txID, 0xFFFF)
    }

    // MARK: - Error Handling

    func testEmptyDataReturnsNil() {
        XCTAssertNil(DNSParser.extractDomainName(from: Data()))
        XCTAssertNil(DNSParser.extractTransactionID(from: Data()))
    }

    func testTooShortDataReturnsNil() {
        let shortData = Data([0x00, 0x01, 0x02])
        XCTAssertNil(DNSParser.extractDomainName(from: shortData))
    }

    func testHeaderOnlyReturnsNil() {
        // 12-byte header with no question section
        var header = Data(count: 12)
        header[4] = 0x00 // QDCOUNT = 0
        header[5] = 0x00
        XCTAssertNil(DNSParser.extractDomainName(from: header))
    }

    // MARK: - Question Section End

    func testQuestionSectionEnd() {
        let query = makeDNSQuery(domain: "tiktok.com")
        let end = DNSParser.questionSectionEnd(in: query)
        // Header (12) + 6("tiktok") + 1(length) + 3("com") + 1(length) + 1(null) + 4(QTYPE+QCLASS) = 28
        XCTAssertEqual(end, query.startIndex + 28)
    }

    // MARK: - NXDOMAIN Response Tests

    func testNXDOMAINResponse() {
        let query = makeDNSQuery(domain: "tiktok.com", transactionID: 0xBEEF)
        let response = DNSResponseBuilder.nxdomain(for: query)

        // Transaction ID preserved
        XCTAssertEqual(response[0], 0xBE)
        XCTAssertEqual(response[1], 0xEF)

        // QR bit set (response)
        XCTAssertTrue(response[2] & 0x80 != 0, "QR bit should be set")

        // RCODE = 3 (NXDOMAIN)
        XCTAssertEqual(response[3] & 0x0F, 3, "RCODE should be 3 (NXDOMAIN)")

        // QDCOUNT = 1
        XCTAssertEqual(response[4], 0x00)
        XCTAssertEqual(response[5], 0x01)

        // ANCOUNT = 0
        XCTAssertEqual(response[6], 0x00)
        XCTAssertEqual(response[7], 0x00)

        // Question section should be echoed
        let queryQuestionEnd = DNSParser.questionSectionEnd(in: query)!
        let queryQuestion = query[query.startIndex + 12..<queryQuestionEnd]
        let responseQuestion = response[response.startIndex + 12..<response.endIndex]
        XCTAssertEqual(queryQuestion, responseQuestion)
    }

    func testNXDOMAINPreservesTransactionID() {
        for txID: UInt16 in [0x0000, 0x1234, 0xFFFF, 0xABCD] {
            let query = makeDNSQuery(domain: "test.com", transactionID: txID)
            let response = DNSResponseBuilder.nxdomain(for: query)
            let responseTxID = DNSParser.extractTransactionID(from: response)
            XCTAssertEqual(responseTxID, txID)
        }
    }
}
