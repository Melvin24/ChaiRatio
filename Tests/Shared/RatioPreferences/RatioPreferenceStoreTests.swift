import Observation
import Synchronization
import XCTest
@testable import ChaiRatio

@MainActor
final class RatioPreferenceStoreTests: XCTestCase {
    func testFreshAndEveryRestoredPreset() {
        withPreferences { defaults, catalog in
            XCTAssertEqual(RatioPreferenceStore(defaults: defaults, catalog: catalog).current, catalog.defaultPreset)
            for preset in catalog.presets {
                defaults.set(preset.id, forKey: RatioPreferenceStore.key)
                XCTAssertEqual(RatioPreferenceStore(defaults: defaults, catalog: catalog).current, preset)
            }
        }
    }

    func testMalformedUnknownAndRemovedValuesFallBackWithoutWriting() {
        withPreferences { defaults, catalog in
            for invalid: Any in [42, true, ["water1-milk2"], "unknown", "removed-ratio"] {
                defaults.set(invalid, forKey: RatioPreferenceStore.key)
                defaults.writes = 0
                let store = RatioPreferenceStore(defaults: defaults, catalog: catalog)
                XCTAssertEqual(store.current, catalog.defaultPreset)
                XCTAssertEqual(defaults.writes, 0)
                store.select(id: "water1-milk3")
                XCTAssertEqual(defaults.string(forKey: RatioPreferenceStore.key), "water1-milk3")
                XCTAssertEqual(defaults.writes, 1)
            }
        }
    }

    func testValidationNoOpWritesAndRestoration() {
        withPreferences { defaults, catalog in
            let store = RatioPreferenceStore(defaults: defaults, catalog: catalog)
            store.select(id: "invalid")
            store.select(id: catalog.defaultID)
            XCTAssertEqual(defaults.writes, 0)
            store.select(id: "water3-milk1")
            store.select(id: "water3-milk1")
            XCTAssertEqual(defaults.writes, 1)
            XCTAssertEqual(store.current, catalog.presets[0])
            XCTAssertEqual(RatioPreferenceStore(defaults: defaults, catalog: catalog).current, catalog.presets[0])
        }
    }

    func testAdjacentSelectionStopsAtEndpoints() {
        withPreferences { defaults, catalog in
            let store = RatioPreferenceStore(defaults: defaults, catalog: catalog)
            for _ in 0..<10 { store.selectAdjacent(by: -1) }
            XCTAssertEqual(store.current.id, "water3-milk1")
            XCTAssertEqual(defaults.writes, 2)
            for _ in 0..<10 { store.selectAdjacent(by: 1) }
            XCTAssertEqual(store.current.id, "water1-milk3")
            XCTAssertEqual(defaults.writes, 6)
        }
    }

    func testSharedSelectionNotifiesObserversWithoutWritingBack() {
        withPreferences { defaults, catalog in
            let store = RatioPreferenceStore(defaults: defaults, catalog: catalog)
            let firstChanges = Mutex(0)
            let secondChanges = Mutex(0)
            // Observation delivers a one-shot invalidation before the mutation completes.
            withObservationTracking {
                XCTAssertEqual(store.current.id, catalog.defaultID)
            } onChange: {
                firstChanges.withLock { $0 += 1 }
            }
            withObservationTracking {
                XCTAssertEqual(store.current.id, catalog.defaultID)
            } onChange: {
                secondChanges.withLock { $0 += 1 }
            }
            store.select(id: "water1-milk2")
            store.select(id: "water1-milk2")
            XCTAssertEqual(store.current.id, "water1-milk2")
            XCTAssertEqual(firstChanges.withLock { $0 }, 1)
            XCTAssertEqual(secondChanges.withLock { $0 }, 1)
            XCTAssertEqual(defaults.writes, 1)
            // Re-register to ensure invalid and unchanged selections don't invalidate views.
            let redundantChanges = Mutex(0)
            withObservationTracking {
                _ = store.current
            } onChange: {
                redundantChanges.withLock { $0 += 1 }
            }
            store.select(id: "water1-milk2")
            store.select(id: "invalid")
            XCTAssertEqual(redundantChanges.withLock { $0 }, 0)
            XCTAssertEqual(defaults.writes, 1)
        }
    }
}
