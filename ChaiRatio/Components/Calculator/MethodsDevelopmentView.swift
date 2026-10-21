#if DEBUG
import SwiftUI

/// A reviewable typed handoff until the separate Methods feature is implemented.
/// This destination is deliberately excluded from Release builds.
struct MethodsDevelopmentView: View {
    let batch: BatchSnapshot
    let catalog: RatioCatalog
    let openMeasures: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Methods preview")
                    .font(.system(.largeTitle, design: .serif))
                    .accessibilityAddTraits(.isHeader)
                Text("Development destination. Preparation guides are still being built. Your batch is ready below; go back to keep adjusting it.")
                    .font(.body)
                if let result = BatchCalculator.calculate(batch, catalog: catalog) {
                    CalculatorResults(calculation: result,
                                      summary: BatchQuantityFormatter.summary(total: result.startingMilliliters,
                                          servings: batch.servings, servingMilliliters: batch.servingMilliliters),
                                      servingSize: batch.servingSize)
                }
                let ratio = catalog.resolve(batch.presetID)
                Text("\(Text(ratio.ratioText)) · \(Text(ratio.name))",
                     comment: "Water-to-milk ratio and the name of the preset.")
                LabeledContent("Tea strength") { Text(batch.strength.name) }
                LabeledContent("Sweetness") { Text(batch.sweetness.name) }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(22)
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollEdgeEffectStyle(.soft, for: .top)
        .foregroundStyle(RitualPalette.ink(dark: scheme == .dark))
        .background(RitualPalette.paper(dark: scheme == .dark).ignoresSafeArea())
        .navigationTitle("Methods")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: openMeasures) {
                    Label("Know your measures", systemImage: "info.circle")
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
        }
    }
}
#endif
