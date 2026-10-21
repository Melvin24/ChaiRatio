import Foundation
import Observation

@MainActor
@Observable
final class CalculatorViewModel {
    let preferences: RatioPreferenceStore
    private(set) var entry = ServingsEntry()
    var servingSize: BatchServingSize = .small
    var strength: TeaStrength = .regular
    var sweetness: Sweetness = .regular
    // Stable section identity survives pop/re-entry and reflow without storing pixel offsets.
    var visibleSection: CalculatorSection?

    init(preferences: RatioPreferenceStore) { self.preferences = preferences }

    var servingsText: String {
        get { entry.text }
        set { entry.edit(newValue) }
    }
    var presetID: String {
        get { preferences.current.id }
        set { preferences.select(id: newValue) }
    }
    var snapshot: BatchSnapshot {
        BatchSnapshot(presetID: presetID, servings: entry.count, servingSize: servingSize,
                      strength: strength, sweetness: sweetness)
    }
    var calculation: BatchCalculation {
        // All mutable inputs are constrained above; catalog definitions are validated by the service.
        let ratio = preferences.current
        return BatchCalculator.calculate(servings: entry.count, servingSize: servingSize,
                                         waterParts: ratio.waterParts, milkParts: ratio.milkParts)
            ?? BatchCalculation(startingMilliliters: 600, waterMilliliters: 300, milkMilliliters: 300)
    }
    var summary: LocalizedStringResource {
        BatchQuantityFormatter.summary(total: calculation.startingMilliliters, servings: entry.count,
                                       servingMilliliters: servingSize.milliliters)
    }
    var availabilityNote: LocalizedStringResource {
        // Complete phrases keep grammar and taste-dependent copy localizable.
        switch (strength, sweetness) {
        case (.regular, .none): "Regular tea · No sugar. Tea amount is not available yet. Add tea to taste."
        case (.strong, .none): "Strong tea · No sugar. Tea amount is not available yet. Add tea to taste."
        case (.regular, .regular): "Regular tea · Regular sweetness. Tea and sugar amounts are not available yet. Add to taste."
        case (.strong, .regular): "Strong tea · Regular sweetness. Tea and sugar amounts are not available yet. Add to taste."
        case (.regular, .sweet): "Regular tea · Sweet sweetness. Tea and sugar amounts are not available yet. Add to taste."
        case (.strong, .sweet): "Strong tea · Sweet sweetness. Tea and sugar amounts are not available yet. Add to taste."
        }
    }

    func finishEntry() { entry.finish() }
    func stepServings(by delta: Int) { entry.step(by: delta) }
}

enum CalculatorSection: Hashable {
    case results, batch, strength, sweetness, notes, methods
}
