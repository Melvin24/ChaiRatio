import SwiftUI

protocol CalculatorChoice: Hashable, Identifiable {
    var name: LocalizedStringResource { get }
    var spokenValue: LocalizedStringResource { get }
}

extension BatchServingSize: CalculatorChoice {
    var spokenValue: LocalizedStringResource {
        LocalizedStringResource("\(String(localized: name)), \(milliliters, format: .number) millilitres",
                                comment: "Serving size name and volume for accessibility.")
    }
}
extension TeaStrength: CalculatorChoice {
    var spokenValue: LocalizedStringResource { name }
}
extension Sweetness: CalculatorChoice {
    var spokenValue: LocalizedStringResource { name }
}

/// Segments are useful only while every label fits. Rows preserve the same values
/// and native button semantics when text or the available width grows constrained.
struct CalculatorChoicePicker<Option: CalculatorChoice>: View {
    let title: LocalizedStringResource
    let options: [Option]
    @Binding var selection: Option
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.colorScheme) private var scheme
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            if typeSize >= .xxLarge {
                CalculatorChoiceRows(title: title, options: options, selection: $selection)
            } else {
                Picker(selection: $selection) {
                    ForEach(options) { option in
                        Text(option.name).tag(option)
                            .accessibilityLabel(Text(option.spokenValue))
                    }
                } label: { Text(title) }
                    .pickerStyle(.segmented)
                    .background(RitualPalette.controlWell(dark: scheme == .dark), in: RoundedRectangle(cornerRadius: 12))
                    .accessibilityValue(Text(selection.spokenValue))
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct CalculatorChoiceRows<Option: CalculatorChoice>: View {
    let title: LocalizedStringResource
    let options: [Option]
    @Binding var selection: Option
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(spacing: 8) {
            ForEach(options) { option in
                Button { selection = option } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(option.name).frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: selection == option ? "checkmark.circle.fill" : "circle")
                            .accessibilityHidden(true)
                    }
                    .font(.body)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .background(RitualPalette.controlWell(dark: scheme == .dark), in: RoundedRectangle(cornerRadius: 12))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("\(String(localized: title)): \(String(localized: option.name))",
                                         comment: "Unique choice button name, e.g. Tea strength: Regular."))
                .accessibilityValue(Text(option.spokenValue))
                .accessibilityAddTraits(selection == option ? .isSelected : [])
            }
        }
    }
}
