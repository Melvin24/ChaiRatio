#if DEBUG
import SwiftUI

private struct CalculatorPreviewHost: View {
    @State private var coordinator: ChaiCoordinator

    init() {
        let preferences = RatioPreferenceStore(defaults: UserDefaults(suiteName: "ChaiRatio.CalculatorPreview")!,
                                               catalog: RatioCatalog())
        let coordinator = ChaiCoordinator(preferences: preferences)
        coordinator.path = [.calculator]
        _coordinator = State(initialValue: coordinator)
    }

    var body: some View {
        NavigationStack {
            CalculatorView(model: coordinator.calculator, coordinator: coordinator)
        }
    }
}

#Preview("Small portrait", traits: .fixedLayout(width: 320, height: 568)) {
    CalculatorPreviewHost()
}

#Preview("Short landscape", traits: .fixedLayout(width: 740, height: 360)) {
    CalculatorPreviewHost()
}

#Preview("Roomy iPad", traits: .fixedLayout(width: 1024, height: 768)) {
    CalculatorPreviewHost()
}

#Preview("Narrow window · Accessibility 5", traits: .fixedLayout(width: 320, height: 700)) {
    CalculatorPreviewHost()
        .environment(\.dynamicTypeSize, .accessibility5)
}

#Preview("Dark", traits: .fixedLayout(width: 390, height: 844)) {
    CalculatorPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
