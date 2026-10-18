import SwiftUI

struct CalculatorPlaceholderView: View {
    let ratioText: LocalizedStringResource
    let name: LocalizedStringResource
    @State private var showingMeasures = false
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Water : Milk").font(.headline)
                Text(ratioText).font(.system(.largeTitle, design: .rounded, weight: .bold))
                Text(name).font(.title2)
                Text("Your selected ratio is ready. Ingredient calculations will be added in the next feature.")
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(24)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollEdgeEffectStyle(.soft, for: .top)
        .foregroundStyle(RitualPalette.ink(dark: scheme == .dark))
        .background(RitualPalette.paper(dark: scheme == .dark).ignoresSafeArea())
        .navigationTitle("Calculator")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingMeasures = true } label: { Image(systemName: "info.circle").frame(minWidth: 44, minHeight: 44) }
                    .accessibilityLabel("Know your measures")
            }
        }
        .sheet(isPresented: $showingMeasures) { MeasuresView() }
    }
}
