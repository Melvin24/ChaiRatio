import SwiftUI

struct RatioPageView: View {
    let ratioText: LocalizedStringResource
    let name: LocalizedStringResource
    let description: LocalizedStringResource
    let milkShare: Double
    let milkShareText: LocalizedStringResource
    let endpointText: LocalizedStringResource?
    var horizontal = false
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let layout = horizontal && !typeSize.isAccessibilitySize
            ? AnyLayout(HStackLayout(alignment: .center, spacing: 48))
            : AnyLayout(VStackLayout(alignment: .leading, spacing: 18))

        layout {
            RatioHeading(ratioText: ratioText)
            RatioDetails(name: name,
                         description: description,
                         milkShare: milkShare,
                         milkShareText: milkShareText,
                         endpointText: endpointText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .frame(maxWidth: horizontal ? 920 : 560, alignment: .leading)
    }
}

private struct RatioHeading: View {
    let ratioText: LocalizedStringResource
    @ScaledMetric(relativeTo: .largeTitle) private var ratioSize = 116
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("WATER : MILK")
                .font(.caption.weight(.semibold))
                .tracking(1.3)
                .foregroundStyle(RitualPalette.secondary(dark: scheme == .dark))
            Text(ratioText)
                .font(typeSize.isAccessibilitySize ? .system(.largeTitle, design: .serif) : .system(size: ratioSize, design: .serif))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.trailing, 8)
                .padding(.top, 6)
                .padding(.bottom, 10)
        }
    }
}

private struct RatioDetails: View {
    let name: LocalizedStringResource
    let description: LocalizedStringResource
    let milkShare: Double
    let milkShareText: LocalizedStringResource
    let endpointText: LocalizedStringResource?
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(name).font(.title2.weight(.semibold)).padding(.bottom, 10)
            Text(description)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            RatioProportionBar(milkShare: milkShare)
                .padding(.top, 22)
                .padding(.bottom, 12)
            Text("\(Text(milkShareText)) · \(1 - milkShare, format: .percent.precision(.fractionLength(0))) water",
                 comment: "Mixture percentages. First value describes the milk share, second is the water percentage.")
                .font(.subheadline.weight(.semibold))
            if let endpointText {
                Text(endpointText)
                    .font(.caption)
                    .foregroundStyle(RitualPalette.secondary(dark: scheme == .dark))
                    .padding(.top, 8)
            }
        }
    }
}

private struct RatioProportionBar: View {
    let milkShare: Double

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                RitualPalette.water.frame(width: proxy.size.width * (1 - milkShare))
                RitualPalette.milk
            }
            .clipShape(Capsule())
        }
        .frame(height: 12)
        .accessibilityHidden(true)
    }
}
