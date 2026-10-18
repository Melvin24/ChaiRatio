import Foundation

struct RatioCatalog {
    let presets: [RatioPreset] = [
        .init(id: "water3-milk1", waterParts: 3, milkParts: 1, name: "Tea-forward",
              description: "More water relative to milk.", appearance: .teaForward),
        .init(id: "water2-milk1", waterParts: 2, milkParts: 1, name: "Light",
              description: "More water than milk. A lighter balance.", appearance: .light),
        .init(id: "water1-milk1", waterParts: 1, milkParts: 1, name: "Balanced",
              description: "Equal parts water and milk.", appearance: .balanced),
        .init(id: "water1-milk2", waterParts: 1, milkParts: 2, name: "Rich",
              description: "More milk than water. A rounder cup.", appearance: .rich),
        .init(id: "water1-milk3", waterParts: 1, milkParts: 3, name: "Extra rich",
              description: "A milk-heavy cup. Simmer carefully.", appearance: .extraRich)
    ]
    let defaultID = "water1-milk1"
    var defaultPreset: RatioPreset { preset(for: defaultID)! }
    func preset(for id: String) -> RatioPreset? { presets.first { $0.id == id } }
    func resolve(_ id: String?) -> RatioPreset { id.flatMap(preset(for:)) ?? defaultPreset }
}
