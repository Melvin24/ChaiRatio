import Foundation

struct RatioPreset: Identifiable, Equatable {
    enum Appearance: CaseIterable { case teaForward, light, balanced, rich, extraRich }
    let id: String
    let waterParts: Int
    let milkParts: Int
    let name: LocalizedStringResource
    let description: LocalizedStringResource
    let appearance: Appearance

    var milkShare: Double { Double(milkParts) / Double(waterParts + milkParts) }
    var ratioText: LocalizedStringResource {
        LocalizedStringResource("\(waterParts, format: .number):\(milkParts, format: .number)",
                                comment: "Water-to-milk ratio. First value is water parts, second is milk parts.")
    }
    var milkShareText: LocalizedStringResource {
        let percentage = milkShare * 100
        if percentage == percentage.rounded() {
            return LocalizedStringResource("\(milkShare, format: .percent.precision(.fractionLength(0))) milk",
                                           comment: "Exact milk percentage of the water and milk mixture.")
        }
        return LocalizedStringResource("approximately \(milkShare, format: .percent.precision(.fractionLength(0))) milk",
                                       comment: "Milk percentage rounded to a whole number.")
    }
}
