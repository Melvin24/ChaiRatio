import Foundation

struct LiquidDisplay: Equatable {
    let milliliters: Decimal
    let liters: Decimal?
    let glasses: Decimal

    var glassCount: LocalizedStringResource {
        LocalizedStringResource("≈ \(glasses, format: .number.precision(.fractionLength(0...2)))",
                                comment: "Approximate number of glasses matching the selected serving size.")
    }

    var glassUnit: LocalizedStringResource { glasses == 1 ? "glass" : "glasses" }

    var literEquivalent: LocalizedStringResource? {
        guard let liters else { return nil }
        return LocalizedStringResource("\(liters, format: .number.precision(.fractionLength(0...2))) L",
                                       comment: "Secondary litre equivalent, derived from the displayed millilitres.")
    }

    var glassEquivalent: LocalizedStringResource {
        if glasses == 1 { return "≈ 1 glass" }
        return LocalizedStringResource("≈ \(glasses, format: .number.precision(.fractionLength(0...2))) glasses",
                                       comment: "Approximate number of selected-serving-size glasses, in decimal quarters.")
    }

    var spokenQuantity: LocalizedStringResource {
        if glasses == 1 {
            return LocalizedStringResource("Approximately 1 glass, \(milliliters, format: .number) millilitres",
                                           comment: "Spoken ingredient volume with a singular glass equivalent.")
        }
        return LocalizedStringResource("Approximately \(glasses, format: .number.precision(.fractionLength(0...2))) glasses, \(milliliters, format: .number) millilitres",
                                       comment: "Spoken glass count followed by ingredient volume; glass size follows the selected serving size.")
    }
}

enum BatchQuantityFormatter {
    static func liquid(_ unroundedMilliliters: Decimal, servingSize: BatchServingSize) -> LiquidDisplay {
        let step: Decimal = unroundedMilliliters < 1_000 ? 5 : 10
        let displayed = rounded(unroundedMilliliters / step) * step
        return LiquidDisplay(milliliters: displayed,
                             liters: unroundedMilliliters >= 1_000 ? displayed / 1_000 : nil,
                             glasses: rounded(unroundedMilliliters * 4 / Decimal(servingSize.milliliters)) / 4)
    }

    static func measurementNote(servingSize: BatchServingSize) -> LocalizedStringResource {
        LocalizedStringResource("1 glass = \(servingSize.milliliters, format: .number) mL. Finished yield is estimated; boiling loss varies.",
                                comment: "Glass volume matches the currently selected serving size (150, 200 or 250 mL).")
    }

    static func summary(total: Decimal, servings: Int, servingMilliliters: Int) -> LocalizedStringResource {
        LocalizedStringResource("\(total, format: .number) mL starting liquid · \(servings) × \(servingMilliliters, format: .number) mL servings",
                                comment: "Starting liquid, number of servings, then millilitres per serving. Pluralize by serving count.")
    }

    private static func rounded(_ value: Decimal) -> Decimal {
        var source = value
        var result = Decimal()
        NSDecimalRound(&result, &source, 0, .plain)
        return result
    }
}
