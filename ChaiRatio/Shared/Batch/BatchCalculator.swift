import Foundation

struct BatchCalculation: Equatable {
    let startingMilliliters: Decimal
    let waterMilliliters: Decimal
    let milkMilliliters: Decimal
}

/// Decimal arithmetic preserves exact halfway values such as 112.5 mL.
/// Yield is 1.0 until a later recipe supplies validated yield data.
enum BatchCalculator {
    static func calculate(servings: Int, servingSize: BatchServingSize,
                          waterParts: Int, milkParts: Int) -> BatchCalculation? {
        guard (1...20).contains(servings), waterParts > 0, milkParts > 0 else { return nil }
        let total = Decimal(servings * servingSize.milliliters)
        let parts = Decimal(waterParts) + Decimal(milkParts)
        return BatchCalculation(startingMilliliters: total,
                                waterMilliliters: total * Decimal(waterParts) / parts,
                                milkMilliliters: total * Decimal(milkParts) / parts)
    }

    static func calculate(_ batch: BatchSnapshot, catalog: RatioCatalog) -> BatchCalculation? {
        let ratio = catalog.resolve(batch.presetID)
        return calculate(servings: batch.servings, servingSize: batch.servingSize,
                         waterParts: ratio.waterParts, milkParts: ratio.milkParts)
    }
}
