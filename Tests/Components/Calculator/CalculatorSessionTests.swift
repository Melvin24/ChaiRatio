import XCTest
@testable import ChaiRatio

@MainActor
final class CalculatorSessionTests: XCTestCase {
    func testDefaultsSharedRatioAndReentry() {
        withPreferences { defaults, catalog in
            let store = RatioPreferenceStore(defaults: defaults, catalog: catalog)
            store.select(id: "water3-milk1")
            let coordinator = ChaiCoordinator(preferences: store)
            let model = coordinator.calculator
            coordinator.openCalculator()
            XCTAssertEqual(model.entry.count, 4)
            XCTAssertEqual(model.servingSize, .small)
            XCTAssertEqual(model.strength, .regular)
            XCTAssertEqual(model.sweetness, .regular)
            XCTAssertEqual(model.calculation.waterMilliliters, 450)
            model.servingsText = "9"
            model.servingSize = .large
            model.strength = .strong
            model.sweetness = .none
            model.presetID = "water1-milk3"
            let writes = defaults.writes
            model.presetID = "water1-milk3"
            XCTAssertEqual(defaults.writes, writes)
            XCTAssertEqual(store.current.id, "water1-milk3")
            coordinator.path.removeAll()
            store.select(id: "water2-milk1")
            coordinator.openCalculator()
            XCTAssertEqual(model.snapshot, BatchSnapshot(presetID: "water2-milk1", servings: 9,
                servingSize: .large, strength: .strong, sweetness: .none))
            let relaunched = ChaiCoordinator(preferences: RatioPreferenceStore(defaults: defaults, catalog: catalog))
            XCTAssertEqual(relaunched.calculator.presetID, "water2-milk1")
            XCTAssertEqual(relaunched.calculator.entry.count, 4)
            XCTAssertEqual(relaunched.calculator.servingSize, .small)
        }
    }

    func testTasteDoesNotChangeLiquidsAndNoSugarIsExplicit() {
        withPreferences { defaults, catalog in
            let model = CalculatorViewModel(preferences: RatioPreferenceStore(defaults: defaults, catalog: catalog))
            let initial = model.calculation
            for strength in TeaStrength.allCases {
                for sweetness in Sweetness.allCases {
                    model.strength = strength
                    model.sweetness = sweetness
                    XCTAssertEqual(model.calculation, initial)
                    XCTAssertTrue(english(model.availabilityNote).contains("not available yet"))
                    if sweetness == .none {
                        XCTAssertTrue(english(model.availabilityNote).contains("No sugar"))
                        XCTAssertFalse(english(model.availabilityNote).contains("sugar amounts"))
                    }
                }
            }
        }
    }

    func testNavigationResolvesEntryAndPreservesTheBatch() {
        withPreferences { defaults, catalog in
            let coordinator = ChaiCoordinator(preferences: RatioPreferenceStore(defaults: defaults, catalog: catalog))
            coordinator.openCalculator()
            coordinator.openCalculator()
            XCTAssertEqual(coordinator.path, [.calculator])
            let model = coordinator.calculator
            model.servingsText = "6"
            model.visibleSection = .notes
            model.servingsText = "oops"
            coordinator.openMeasures()
            XCTAssertEqual(model.servingsText, "6")
            XCTAssertNil(model.entry.error)
            let batch = model.snapshot
            coordinator.showingMeasures = false
            XCTAssertEqual(model.snapshot, batch)
            XCTAssertEqual(model.visibleSection, .notes)
            #if DEBUG
            model.servingsText = ""
            coordinator.openMethods()
            coordinator.openMethods()
            XCTAssertEqual(coordinator.path, [.calculator, .methodsPreview(batch)])
            coordinator.path.removeLast()
            XCTAssertEqual(model.snapshot, batch)
            XCTAssertEqual(model.servingsText, "6")
            XCTAssertEqual(model.visibleSection, .notes)
            #endif
        }
    }
}
