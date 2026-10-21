import Foundation

enum BatchServingSize: Int, CaseIterable, Identifiable, Sendable {
    case small = 150, medium = 200, large = 250

    var id: Self { self }
    var milliliters: Int { rawValue }
    var name: LocalizedStringResource {
        switch self {
        case .small: "Small"
        case .medium: "Medium"
        case .large: "Large"
        }
    }
}

enum TeaStrength: String, CaseIterable, Identifiable, Sendable {
    case regular, strong

    var id: Self { self }
    var name: LocalizedStringResource {
        switch self {
        case .regular: "Regular"
        case .strong: "Strong"
        }
    }
}

enum Sweetness: String, CaseIterable, Identifiable, Sendable {
    case none, regular, sweet

    var id: Self { self }
    var name: LocalizedStringResource {
        switch self {
        case .none: "None"
        case .regular: "Regular"
        case .sweet: "Sweet"
        }
    }
}

/// Navigation carries inputs, never rounded display quantities. Only the ratio is persisted.
struct BatchSnapshot: Hashable, Sendable {
    let presetID: String
    let servings: Int
    let servingSize: BatchServingSize
    let strength: TeaStrength
    let sweetness: Sweetness

    var servingMilliliters: Int { servingSize.milliliters }
}
