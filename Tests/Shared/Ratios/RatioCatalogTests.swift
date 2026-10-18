import XCTest
@testable import ChaiRatio

@MainActor
final class RatioCatalogTests: XCTestCase {
    func testCatalogInvariantsAndFractions() {
        let catalog = RatioCatalog()
        XCTAssertEqual(catalog.presets.map(\.id), ["water3-milk1", "water2-milk1", "water1-milk1", "water1-milk2", "water1-milk3"])
        XCTAssertEqual(catalog.presets.map { english($0.name) }, ["Tea-forward", "Light", "Balanced", "Rich", "Extra rich"])
        XCTAssertEqual(Set(catalog.presets.map(\.id)).count, 5)
        XCTAssertTrue(catalog.presets.allSatisfy { $0.waterParts > 0 && $0.milkParts > 0 })
        XCTAssertEqual(english(catalog.defaultPreset.ratioText), "1:1")
        for (preset, share) in zip(catalog.presets, [0.25, 1.0 / 3, 0.5, 2.0 / 3, 0.75]) {
            XCTAssertEqual(preset.milkShare, share, accuracy: 0.0000001)
        }
        XCTAssertEqual(catalog.presets.map { english($0.milkShareText) }, ["25% milk", "approximately 33% milk", "50% milk", "approximately 67% milk", "75% milk"])
    }
}
