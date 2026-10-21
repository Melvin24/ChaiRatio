import XCTest
@testable import ChaiRatio

@MainActor
final class BatchCalculatorTests: XCTestCase {
    func testReferenceTableAndIndependentRounding() throws {
        let rows: [(Int, BatchServingSize, Int, Int, Int, Int, Int, Double, Double)] = [
            (4, .small, 3, 1, 600, 450, 150, 3, 1),
            (4, .small, 2, 1, 600, 400, 200, 2.75, 1.25),
            (4, .small, 1, 1, 600, 300, 300, 2, 2),
            (4, .small, 1, 2, 600, 200, 400, 1.25, 2.75),
            (4, .small, 1, 3, 600, 150, 450, 1, 3),
            (1, .small, 3, 1, 150, 115, 40, 0.75, 0.25),
            (1, .medium, 2, 1, 200, 135, 65, 0.75, 0.25),
            (13, .small, 1, 1, 1950, 975, 975, 6.5, 6.5),
            (8, .large, 1, 1, 2000, 1000, 1000, 4, 4),
            (20, .large, 2, 1, 5000, 3330, 1670, 13.25, 6.75)
        ]
        for (servings, size, a, b, total, water, milk, waterGlasses, milkGlasses) in rows {
            let result = try XCTUnwrap(BatchCalculator.calculate(servings: servings, servingSize: size, waterParts: a, milkParts: b))
            let w = BatchQuantityFormatter.liquid(result.waterMilliliters, servingSize: size)
            let m = BatchQuantityFormatter.liquid(result.milkMilliliters, servingSize: size)
            XCTAssertEqual(result.startingMilliliters, Decimal(total))
            XCTAssertEqual(w.milliliters, Decimal(water))
            XCTAssertEqual(m.milliliters, Decimal(milk))
            XCTAssertEqual(w.glasses, Decimal(waterGlasses))
            XCTAssertEqual(m.glasses, Decimal(milkGlasses))
        }
    }

    func testAllThreeHundredCombinationsConserveVolumeAndRatio() throws {
        for count in 1...20 {
            for size in BatchServingSize.allCases {
                for preset in RatioCatalog().presets {
                    let result = try XCTUnwrap(BatchCalculator.calculate(servings: count, servingSize: size,
                        waterParts: preset.waterParts, milkParts: preset.milkParts))
                    let water = NSDecimalNumber(decimal: result.waterMilliliters).doubleValue
                    let milk = NSDecimalNumber(decimal: result.milkMilliliters).doubleValue
                    XCTAssertTrue(water.isFinite && milk.isFinite && water > 0 && milk > 0)
                    XCTAssertEqual(water + milk, Double(count * size.milliliters), accuracy: 1e-9)
                    XCTAssertEqual(water / milk, Double(preset.waterParts) / Double(preset.milkParts), accuracy: 1e-9)
                }
            }
        }
    }

    func testHalfStepsAndLiterThreshold() {
        XCTAssertEqual(BatchQuantityFormatter.liquid(112.5, servingSize: .medium).milliliters, 115)
        XCTAssertEqual(BatchQuantityFormatter.liquid(37.5, servingSize: .medium).milliliters, 40)
        XCTAssertEqual(BatchQuantityFormatter.liquid(125, servingSize: .medium).glasses, 0.75)
        XCTAssertEqual(BatchQuantityFormatter.liquid(1_005, servingSize: .medium).milliliters, 1_010)
        XCTAssertNil(BatchQuantityFormatter.liquid(999, servingSize: .medium).liters)
        XCTAssertEqual(BatchQuantityFormatter.liquid(1_000, servingSize: .medium).liters, 1)
        XCTAssertEqual(BatchQuantityFormatter.liquid(Decimal(10_000) / 3, servingSize: .medium).liters, 3.33)
        XCTAssertEqual(BatchQuantityFormatter.liquid(Decimal(5_000) / 3, servingSize: .medium).liters, 1.67)
        XCTAssertEqual(english(BatchQuantityFormatter.liquid(200, servingSize: .medium).glassEquivalent), "≈ 1 glass")
        XCTAssertEqual(english(BatchQuantityFormatter.liquid(300, servingSize: .medium).glassEquivalent), "≈ 1.5 glasses")
        XCTAssertEqual(BatchQuantityFormatter.liquid(1_000, servingSize: .medium).literEquivalent.map(english), "1 L")
        XCTAssertEqual(BatchQuantityFormatter.liquid(Decimal(10_000) / 3, servingSize: .medium).literEquivalent.map(english), "3.33 L")
    }

    func testLocalizedSummarySingularAndPlural() {
        XCTAssertEqual(english(BatchQuantityFormatter.summary(total: 150, servings: 1, servingMilliliters: 150)),
                       "150 mL starting liquid · 1 × 150 mL serving")
        XCTAssertEqual(english(BatchQuantityFormatter.summary(total: 600, servings: 4, servingMilliliters: 150)),
                       "600 mL starting liquid · 4 × 150 mL servings")
    }

    func testGlassCountAndNoteUseTheSelectedServingSize() {
        let expected: [(BatchServingSize, Decimal)] = [(.small, 2), (.medium, 1.5), (.large, 1.25)]
        for (size, glasses) in expected {
            let display = BatchQuantityFormatter.liquid(300, servingSize: size)
            XCTAssertEqual(display.milliliters, 300)
            XCTAssertEqual(display.glasses, glasses)
            XCTAssertEqual(english(BatchQuantityFormatter.measurementNote(servingSize: size)),
                           "1 glass = \(size.milliliters) mL. Finished yield is estimated; boiling loss varies.")
            XCTAssertEqual(english(BatchQuantityFormatter.liquid(Decimal(size.milliliters), servingSize: size).glassUnit), "glass")
        }
    }

    func testDefensiveBoundaries() {
        for count in [0, -1, 21, Int.max] {
            XCTAssertNil(BatchCalculator.calculate(servings: count, servingSize: .small, waterParts: 1, milkParts: 1))
        }
        XCTAssertNil(BatchCalculator.calculate(servings: 4, servingSize: .small, waterParts: 0, milkParts: 1))
        XCTAssertNil(BatchCalculator.calculate(servings: 4, servingSize: .small, waterParts: 1, milkParts: -1))
        // Parts are converted before addition/multiplication, so even extreme input cannot overflow Int.
        let result = BatchCalculator.calculate(servings: 20, servingSize: .large, waterParts: Int.max, milkParts: Int.max)
        XCTAssertEqual(result?.waterMilliliters, 2_500)
    }
}
