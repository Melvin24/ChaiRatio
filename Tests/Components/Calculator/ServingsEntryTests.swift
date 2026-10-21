import XCTest
@testable import ChaiRatio

@MainActor
final class ServingsEntryTests: XCTestCase {
    func testMalformedEditsKeepTheLastValidCount() {
        var entry = ServingsEntry()
        entry.edit("7")
        for text in ["", " ", "1.5", "1e1", "1,000", "abc", "+3", "½", "1 2", "--2"] {
            entry.edit(text)
            XCTAssertEqual(entry.count, 7, text)
            XCTAssertEqual(entry.text, text)
            XCTAssertEqual(entry.error, .wholeNumber)
        }
        entry.finish()
        XCTAssertEqual(entry.text, "7")
        XCTAssertNil(entry.error)
    }

    func testRangeClampingAndUnicodeDigits() {
        var entry = ServingsEntry()
        for (text, count) in [("0", 1), ("-2", 1), ("21", 20), (String(repeating: "9", count: 10_000), 20)] {
            entry.edit(text)
            XCTAssertEqual(entry.count, count)
            XCTAssertEqual(entry.text, String(count))
            XCTAssertEqual(entry.error, .range)
        }
        for text in [" 12\n", "١٢", "۱۲", "１２", "00012"] {
            entry.edit(text)
            XCTAssertEqual(entry.count, 12, text)
            XCTAssertNil(entry.error)
        }
        entry.edit("8")
        XCTAssertEqual(entry.count, 8)
        XCTAssertNil(entry.error)
    }

    func testSteppingRecoversFromInvalidInputAndHonorsBounds() {
        var entry = ServingsEntry()
        entry.edit("bad")
        entry.step(by: 1)
        XCTAssertEqual(entry.count, 5)
        XCTAssertEqual(entry.text, "5")
        XCTAssertNil(entry.error)
        entry.edit("1")
        entry.step(by: -1)
        XCTAssertEqual(entry.count, 1)
        entry.edit("20")
        entry.step(by: 1)
        XCTAssertEqual(entry.count, 20)
    }
}
