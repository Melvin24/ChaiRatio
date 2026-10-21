import SwiftUI

struct MeasuresView: View {
    var servingSize: BatchServingSize = .small
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    MeasuresHeader()
                    ServingSizesSection()
                    MeasurementDefinitions(servingSize: servingSize)
                    MeasurementPrecisionNote()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 28)
                .frame(maxWidth: 760)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollEdgeEffectStyle(.soft, for: .top)
            .foregroundStyle(RitualPalette.ink(dark: scheme == .dark))
            .background(RitualPalette.paper(dark: scheme == .dark).ignoresSafeArea())
            .navigationTitle("Measurements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityHint("Close measurements and return to your chai.")
                }
            }
        }
        .tint(RitualPalette.accent(dark: scheme == .dark))
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

private struct MeasuresHeader: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Know your measures")
                .font(.system(.largeTitle, design: .serif))
                .accessibilityAddTraits(.isHeader)
            Text("A little clarity in every cup.")
                .font(.body)
                .foregroundStyle(RitualPalette.secondary(dark: scheme == .dark))
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct ServingSizesSection: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Find your cup size")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                Text("Choose how much chai you’d like per person.")
                    .font(.subheadline)
                    .foregroundStyle(RitualPalette.secondary(dark: scheme == .dark))
            }
            ServingSizesView()
            Text("Small is the default. These are serving sizes, not standard household cup measurements. Finished volume varies with boiling loss.")
                .font(.caption)
                .foregroundStyle(RitualPalette.secondary(dark: scheme == .dark))
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RitualPalette.card(dark: scheme == .dark), in: RoundedRectangle(cornerRadius: 22))
    }
}

private enum ServingSize: CaseIterable, Identifiable {
    case small, medium, large

    var id: Self { self }
    var name: LocalizedStringResource {
        switch self {
        case .small: "Small"
        case .medium: "Medium"
        case .large: "Large"
        }
    }
    var detail: LocalizedStringResource {
        switch self {
        case .small: "A little cup"
        case .medium: "An everyday cup"
        case .large: "A generous cup"
        }
    }
    var milliliters: Int {
        switch self {
        case .small: 150
        case .medium: 200
        case .large: 250
        }
    }
    var symbolSize: CGFloat {
        switch self {
        case .small: 30
        case .medium: 38
        case .large: 46
        }
    }
}

private struct ServingSizesView: View {
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if typeSize >= .xxLarge {
            ServingExamplesRows()
        } else {
            ViewThatFits(in: .horizontal) {
                ServingExamplesColumns()
                ServingExamplesRows()
            }
        }
    }
}

private struct ServingExamplesColumns: View {
    @ScaledMetric(relativeTo: .body) private var minimumWidth = 72
    @ScaledMetric(relativeTo: .body) private var idealWidth = 88

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ForEach(ServingSize.allCases) { serving in
                VStack(spacing: 12) {
                    ServingCupSymbol(size: serving.symbolSize)
                    ServingExampleText(name: serving.name, detail: serving.detail,
                                       milliliters: serving.milliliters, centered: true)
                }
                .frame(minWidth: minimumWidth, idealWidth: idealWidth, maxWidth: .infinity)
                .accessibilityElement(children: .combine)
            }
        }
    }
}

private struct ServingExamplesRows: View {
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(ServingSize.allCases) { serving in
                let layout = typeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
                    : AnyLayout(HStackLayout(alignment: .center, spacing: 16))
                layout {
                    ServingCupSymbol(size: serving.symbolSize)
                    ServingExampleText(name: serving.name, detail: serving.detail,
                                       milliliters: serving.milliliters, centered: false)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)
            }
        }
    }
}

private struct ServingCupSymbol: View {
    let size: CGFloat
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Image(systemName: "cup.and.saucer")
            .font(.system(size: size))
            .frame(width: 64, height: 56, alignment: .bottom)
            .foregroundStyle(RitualPalette.accent(dark: scheme == .dark))
            .accessibilityHidden(true)
    }
}

private struct ServingExampleText: View {
    let name: LocalizedStringResource
    let detail: LocalizedStringResource
    let milliliters: Int
    let centered: Bool
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: centered ? .center : .leading, spacing: 6) {
            Text(name).font(.subheadline.weight(.semibold))
            Text("\(milliliters, format: .number) mL", comment: "Serving volume in milliliters.")
                .font(.headline)
            Text(detail)
                .font(.caption)
                .foregroundStyle(RitualPalette.secondary(dark: scheme == .dark))
        }
        .multilineTextAlignment(centered ? .center : .leading)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: centered ? .center : .leading)
    }
}

private enum MeasurementUnit: CaseIterable, Identifiable {
    case glass, teaspoon, tablespoon, grams

    var id: Self { self }
    var name: LocalizedStringResource {
        switch self {
        case .glass: "Glass"
        case .teaspoon: "Teaspoon"
        case .tablespoon: "Tablespoon"
        case .grams: "Grams"
        }
    }
    func value(servingSize: BatchServingSize) -> LocalizedStringResource {
        switch self {
        case .glass: LocalizedStringResource("\(servingSize.milliliters, format: .number) mL", comment: "Glass volume matches the selected serving size.")
        case .teaspoon: "5 mL"
        case .tablespoon: "15 mL"
        case .grams: "Weight"
        }
    }
    var detail: LocalizedStringResource {
        switch self {
        case .glass: "For this batch, one glass matches your selected serving size. Your household glass may hold a different amount."
        case .teaspoon: "Volume, not weight. Use a measuring teaspoon."
        case .tablespoon: "Equal to three teaspoons by volume."
        case .grams: "Spoon-to-gram conversion varies by ingredient. A teaspoon is not a fixed weight."
        }
    }
}

private struct MeasurementDefinitions: View {
    let servingSize: BatchServingSize
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if typeSize >= .xxLarge {
            MeasurementDefinitionColumn(servingSize: servingSize)
        } else {
            ViewThatFits(in: .horizontal) {
                MeasurementDefinitionGrid(servingSize: servingSize)
                MeasurementDefinitionColumn(servingSize: servingSize)
            }
        }
    }
}

private struct MeasurementDefinitionGrid: View {
    let servingSize: BatchServingSize
    var body: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow(alignment: .top) {
                MeasurementGridCard(unit: .glass, servingSize: servingSize)
                MeasurementGridCard(unit: .teaspoon, servingSize: servingSize)
            }
            GridRow(alignment: .top) {
                MeasurementGridCard(unit: .tablespoon, servingSize: servingSize)
                MeasurementGridCard(unit: .grams, servingSize: servingSize)
            }
        }
    }
}

private struct MeasurementGridCard: View {
    let unit: MeasurementUnit
    let servingSize: BatchServingSize
    @ScaledMetric(relativeTo: .body) private var minimumWidth = 260

    var body: some View {
        MeasurementDefinition(unit: unit, servingSize: servingSize)
            // ViewThatFits rejects this two-column candidate when its scaled minimum can't fit.
            .frame(minWidth: minimumWidth, idealWidth: minimumWidth, maxWidth: .infinity)
    }
}

private struct MeasurementDefinitionColumn: View {
    let servingSize: BatchServingSize
    var body: some View {
        VStack(spacing: 12) {
            ForEach(MeasurementUnit.allCases) { unit in
                MeasurementDefinition(unit: unit, servingSize: servingSize)
            }
        }
    }
}

private struct MeasurementDefinition: View {
    let unit: MeasurementUnit
    let servingSize: BatchServingSize
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(unit.name).fixedSize()
                    Spacer(minLength: 0)
                    Text(unit.value(servingSize: servingSize)).fixedSize()
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(unit.name)
                    Text(unit.value(servingSize: servingSize))
                }
            }
            .font(.headline)
            Text(unit.detail)
                .font(.subheadline)
                .foregroundStyle(RitualPalette.secondary(dark: scheme == .dark))
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(MeasurementSurface.color(dark: scheme == .dark), in: RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .combine)
    }
}

private enum MeasurementSurface {
    static func color(dark: Bool) -> Color {
        // The light card matches --card in the frozen Daily Ritual prototype.
        dark ? RitualPalette.card(dark: true) : Color(hex: 0xfffcf7)
    }
}

private struct MeasurementPrecisionNote: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Text("Liquid volumes are rounded to 5 mL below 1 L and 10 mL at or above it; glass equivalents to the nearest quarter.")
            .font(.caption)
            .foregroundStyle(RitualPalette.secondary(dark: scheme == .dark))
            .fixedSize(horizontal: false, vertical: true)
    }
}
