import SwiftUI

struct RatioSelectionView: View {
    let store: RatioPreferenceStore
    @Bindable var coordinator: ChaiCoordinator
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            RatioPagerView(store: store, isActive: coordinator.path.isEmpty && !coordinator.showingMeasures,
                           makeChai: coordinator.openCalculator)
                .foregroundStyle(RitualPalette.ink(dark: scheme == .dark))
                .background { RatioSelectionBackground(store: store) }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: coordinator.openMeasures) {
                            Image(systemName: "info.circle")
                                .font(.title3)
                                .frame(minWidth: 44, minHeight: 44)
                        }
                        .accessibilityLabel("Know your measures")
                    }
                }
                .navigationTitle("ChaiRatio")
                .toolbarTitleDisplayMode(.inline)
                .navigationDestination(for: ChaiCoordinator.Route.self) { route in
                    switch route {
                    case .calculator:
                        CalculatorView(model: coordinator.calculator, coordinator: coordinator)
                    #if DEBUG
                    case .methodsPreview(let batch):
                        MethodsDevelopmentView(batch: batch, catalog: store.catalog,
                                               openMeasures: coordinator.openMeasures)
                    #endif
                    }
                }
        }
        .sheet(isPresented: $coordinator.showingMeasures) {
            MeasuresView(servingSize: coordinator.calculator.servingSize)
        }
        .tint(RitualPalette.accent(dark: scheme == .dark))
    }
}

private struct RatioSelectionBackground: View {
    let store: RatioPreferenceStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        store.current.appearance.background(dark: scheme == .dark)
            .ignoresSafeArea()
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: store.current.appearance)
    }
}

struct MakeChaiButton: View {
    let isEnabled: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text("Let’s make chai")
                Image(systemName: "arrow.forward").accessibilityHidden(true)
            }
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(RitualPalette.onAccent(dark: scheme == .dark))
            .background(RitualPalette.accent(dark: scheme == .dark), in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .padding(.horizontal, 22)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .frame(maxWidth: 560)
        .frame(maxWidth: .infinity)
    }
}
