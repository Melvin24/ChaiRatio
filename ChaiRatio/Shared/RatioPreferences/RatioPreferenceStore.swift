import Foundation
import Observation

@MainActor
@Observable
final class RatioPreferenceStore {
    static let key = "chaiRatio.selectedRatioID"
    let catalog: RatioCatalog
    private(set) var current: RatioPreset
    private let defaults: UserDefaults

    init(defaults: UserDefaults, catalog: RatioCatalog) {
        self.defaults = defaults
        self.catalog = catalog
        current = catalog.resolve(defaults.object(forKey: Self.key) as? String)
    }

    func select(id: String) {
        guard let preset = catalog.preset(for: id), preset != current else { return }
        defaults.set(id, forKey: Self.key)
        current = preset
    }

    func selectAdjacent(by offset: Int) {
        guard let index = catalog.presets.firstIndex(of: current) else { return }
        let next = index + offset
        guard catalog.presets.indices.contains(next) else { return }
        select(id: catalog.presets[next].id)
    }
}
