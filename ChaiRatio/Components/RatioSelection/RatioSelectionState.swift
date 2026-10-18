import Foundation

struct RatioSelectionState: Equatable {
    let preset: RatioPreset
    let index: Int
    let count: Int
    var canGoPrevious: Bool { index > 0 }
    var canGoNext: Bool { index + 1 < count }
    var positionText: LocalizedStringResource {
        LocalizedStringResource("\(index + 1) of \(count)",
                                comment: "Selected ratio position. First value is its one-based position, second is the total number of ratios.")
    }
    var endpointText: LocalizedStringResource? {
        if !canGoPrevious { return "Most water · Start of range" }
        if !canGoNext { return "Most milk · End of range" }
        return nil
    }
    var accessibilitySummary: LocalizedStringResource {
        if let endpointText {
            return LocalizedStringResource("\(preset.waterParts) parts water, \(preset.milkParts) parts milk. \(preset.name). \(preset.milkShareText). \(positionText). \(endpointText)",
                                           comment: "VoiceOver ratio summary: water parts, milk parts, name, milk percentage, position, and range endpoint.")
        }
        return LocalizedStringResource("\(preset.waterParts) parts water, \(preset.milkParts) parts milk. \(preset.name). \(preset.milkShareText). \(positionText).",
                                       comment: "VoiceOver ratio summary: water parts, milk parts, name, milk percentage, and position.")
    }
}
