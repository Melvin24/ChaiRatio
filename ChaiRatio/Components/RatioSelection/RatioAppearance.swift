import SwiftUI

enum RitualPalette {
    static func ink(dark: Bool) -> Color { dark ? Color(hex: 0xfffaf1) : Color(hex: 0x332218) }
    static func secondary(dark: Bool) -> Color { dark ? Color(hex: 0xe3c5a6) : Color(hex: 0x503b2e) }
    static func accent(dark: Bool) -> Color { dark ? Color(hex: 0xe3c5a6) : Color(hex: 0x814725) }
    static func onAccent(dark: Bool) -> Color { dark ? Color(hex: 0x332218) : Color(hex: 0xfffaf1) }
    static func paper(dark: Bool) -> Color { Color(hex: dark ? 0x2b231c : 0xf8f2e9) }
    static func card(dark: Bool) -> Color { Color(hex: dark ? 0x403326 : 0xe9d8c3) }
    /// Raised content and recessed controls have distinct roles in Daily Ritual.
    static func surface(dark: Bool) -> Color { Color(hex: dark ? 0x362b22 : 0xfffcf7) }
    static func controlWell(dark: Bool) -> Color { card(dark: dark) }
    static let water = Color(hex: 0x99603b)
    static let milk = Color(hex: 0xf7e3c6)
}

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB, red: Double((hex >> 16) & 255) / 255,
                  green: Double((hex >> 8) & 255) / 255, blue: Double(hex & 255) / 255, opacity: 1)
    }
}

extension RatioPreset.Appearance {
    func background(dark: Bool) -> Color {
        let rgb = components(dark: dark)
        return Color(.sRGB, red: rgb.0, green: rgb.1, blue: rgb.2, opacity: 1)
    }
    /// Approved Daily Ritual tones. Color illustrates proportion, not a brewed drink's appearance.
    func components(dark: Bool) -> (Double, Double, Double) {
        let hex: UInt32
        switch (self, dark) {
        case (.teaForward, false): hex = 0xcfa984
        case (.light, false): hex = 0xd8b897
        case (.balanced, false): hex = 0xe3c5a6
        case (.rich, false): hex = 0xecd7bd
        case (.extraRich, false): hex = 0xf2e4d0
        case (.teaForward, true): hex = 0x2b231c
        case (.light, true): hex = 0x35291f
        case (.balanced, true): hex = 0x403326
        case (.rich, true): hex = 0x4c3d2d
        case (.extraRich, true): hex = 0x554532
        }
        return (Double((hex >> 16) & 255) / 255, Double((hex >> 8) & 255) / 255, Double(hex & 255) / 255)
    }
}
