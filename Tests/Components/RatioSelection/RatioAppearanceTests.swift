import SwiftUI
import XCTest
@testable import ChaiRatio

@MainActor
final class RatioAppearanceTests: XCTestCase {
    func testAllTextAndEssentialBordersExceedContrastTargets() {
        func luminance(_ color: Color) -> Double {
            let rgb = color.resolve(in: EnvironmentValues())
            func linear(_ c: Float) -> Double {
                let value = Double(c)
                return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
            }
            return 0.2126 * linear(rgb.red) + 0.7152 * linear(rgb.green) + 0.0722 * linear(rgb.blue)
        }
        func contrast(_ first: Color, _ second: Color) -> Double {
            let a = luminance(first), b = luminance(second)
            return (max(a, b) + 0.05) / (min(a, b) + 0.05)
        }
        for dark in [false, true] {
            for token in RatioPreset.Appearance.allCases {
                XCTAssertGreaterThanOrEqual(contrast(RitualPalette.ink(dark: dark), token.background(dark: dark)), 4.5)
                XCTAssertGreaterThanOrEqual(contrast(RitualPalette.secondary(dark: dark), token.background(dark: dark)), 4.5)
            }
            XCTAssertGreaterThanOrEqual(contrast(RitualPalette.onAccent(dark: dark), RitualPalette.accent(dark: dark)), 4.5)
            XCTAssertGreaterThanOrEqual(contrast(RitualPalette.secondary(dark: dark), RitualPalette.paper(dark: dark)), 4.5)
            XCTAssertGreaterThanOrEqual(contrast(RitualPalette.ink(dark: dark), RitualPalette.card(dark: dark)), 4.5)
        }
    }
}
