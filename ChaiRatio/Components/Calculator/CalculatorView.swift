import SwiftUI

struct CalculatorView: View {
    @Bindable var model: CalculatorViewModel
    let coordinator: ChaiCoordinator
    @FocusState private var countFocused: Bool
    @AccessibilityFocusState private var infoFocused: Bool
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        CalculatorContent(model: model, countFocused: $countFocused, typeSize: typeSize,
                          openMethods: openMethods)
        .foregroundStyle(RitualPalette.ink(dark: scheme == .dark))
        .background(model.preferences.current.appearance.background(dark: scheme == .dark).ignoresSafeArea())
        .navigationTitle("Make chai")
        .toolbarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    finishEditing()
                    coordinator.openMeasures()
                } label: {
                    Label("Know your measures", systemImage: "info.circle")
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityFocused($infoFocused)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { finishEditing() }
            }
        }
        .onChange(of: countFocused) { _, focused in
            if !focused { model.finishEntry() }
        }
        .onChange(of: coordinator.showingMeasures) { wasShowing, isShowing in
            if wasShowing && !isShowing { infoFocused = true }
        }
        .onDisappear { finishEditing() }
        .modifier(CalculatorAnnouncements(model: model))
    }

    private func finishEditing() {
        countFocused = false
        model.finishEntry()
    }

    private func openMethods() {
        finishEditing()
        #if DEBUG
        coordinator.openMethods()
        #endif
    }
}

private struct CalculatorContent: View {
    @Bindable var model: CalculatorViewModel
    var countFocused: FocusState<Bool>.Binding
    let typeSize: DynamicTypeSize
    let openMethods: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let floatingAction = geometry.size.height >= 520 && typeSize < .xxLarge && !countFocused.wrappedValue
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    CalculatorResults(calculation: model.calculation, summary: model.summary, servingSize: model.servingSize)
                        .id(CalculatorSection.results)
                    CalculatorBatchControls(model: model, countFocused: countFocused)
                        .id(CalculatorSection.batch)
                    CalculatorTasteControls(model: model)
                    CalculatorNotes(availability: model.availabilityNote, servingSize: model.servingSize)
                        .id(CalculatorSection.notes)
                    #if DEBUG
                    if !floatingAction { MethodsButton(action: openMethods) }
                    #else
                    UnavailableMethodsNote()
                    #endif
                }
                .scrollTargetLayout()
                .padding(.horizontal, 22)
                .padding(.top, 16)
                .padding(.bottom, 24)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .scrollPosition(id: $model.visibleSection, anchor: .top)
            .scrollBounceBehavior(.always, axes: .vertical)
            .scrollEdgeEffectStyle(.soft, for: .top)
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                #if DEBUG
                if floatingAction {
                    MethodsButton(action: openMethods)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 8)
                        .frame(maxWidth: 680)
                        .frame(maxWidth: .infinity)
                }
                #endif
            }
        }
    }
}

private struct CalculatorTasteControls: View {
    @Bindable var model: CalculatorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            CalculatorChoicePicker(title: "Tea strength", options: TeaStrength.allCases, selection: $model.strength)
                .id(CalculatorSection.strength)
            CalculatorChoicePicker(title: "Sweetness", options: Sweetness.allCases, selection: $model.sweetness)
                .id(CalculatorSection.sweetness)
        }
    }
}

private struct UnavailableMethodsNote: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Text("Preparation guides are not available yet.")
            .font(.footnote)
            .foregroundStyle(RitualPalette.secondary(dark: scheme == .dark))
    }
}

struct CalculatorResults: View {
    let calculation: BatchCalculation
    let summary: LocalizedStringResource
    let servingSize: BatchServingSize
    @ScaledMetric(relativeTo: .body) private var minimumCardWidth = 142
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 12) {
                    LiquidResultCard(name: "Water", symbol: "drop", quantity: BatchQuantityFormatter.liquid(calculation.waterMilliliters, servingSize: servingSize))
                        .frame(minWidth: minimumCardWidth)
                    LiquidResultCard(name: "Milk", symbol: "waterbottle", quantity: BatchQuantityFormatter.liquid(calculation.milkMilliliters, servingSize: servingSize))
                        .frame(minWidth: minimumCardWidth)
                }
                VStack(spacing: 12) {
                    LiquidResultCard(name: "Water", symbol: "drop", quantity: BatchQuantityFormatter.liquid(calculation.waterMilliliters, servingSize: servingSize))
                    LiquidResultCard(name: "Milk", symbol: "waterbottle", quantity: BatchQuantityFormatter.liquid(calculation.milkMilliliters, servingSize: servingSize))
                }
            }
            Text(summary)
                .font(.footnote)
                .foregroundStyle(RitualPalette.secondary(dark: scheme == .dark))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct LiquidResultCard: View {
    let name: LocalizedStringResource
    let symbol: String
    let quantity: LiquidDisplay
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label { Text(name) } icon: { Image(systemName: symbol).accessibilityHidden(true) }
                .font(.subheadline)
                .foregroundStyle(RitualPalette.secondary(dark: scheme == .dark))
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(quantity.glassCount).font(.system(.title, weight: .semibold))
                    Text(quantity.glassUnit).font(.body)
                }
                .fixedSize()
                VStack(alignment: .leading, spacing: 2) {
                    Text(quantity.glassCount).font(.system(.title, weight: .semibold))
                    Text(quantity.glassUnit).font(.body)
                }
            }
            .monospacedDigit()
            Text("\(quantity.milliliters, format: .number) mL", comment: "Rounded ingredient volume, secondary to the glass count.")
                .font(.subheadline)
                .foregroundStyle(RitualPalette.secondary(dark: scheme == .dark))
            if let liters = quantity.literEquivalent {
                Text(liters)
                    .font(.subheadline)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .modifier(CalculatorCard())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(Text(name)), \(Text(quantity.spokenQuantity))",
                                 comment: "Ingredient name followed by its spoken volume and glass equivalent."))
    }
}

private struct CalculatorBatchControls: View {
    @Bindable var model: CalculatorViewModel
    var countFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ServingsControl(model: model, countFocused: countFocused)
            CalculatorChoicePicker(title: "Size of each serving", options: BatchServingSize.allCases,
                                   selection: $model.servingSize)
            CalculatorRatioPicker(model: model)
        }
        .padding(20)
        .modifier(CalculatorCard())
    }
}

private struct ServingsControl: View {
    @Bindable var model: CalculatorViewModel
    var countFocused: FocusState<Bool>.Binding
    @State private var selection: TextSelection?
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    Text("Servings").font(.headline).fixedSize()
                    Spacer(minLength: 0)
                    ServingsStepper(model: model, countFocused: countFocused, selection: $selection)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("Servings").font(.headline)
                    ServingsStepper(model: model, countFocused: countFocused, selection: $selection)
                }
            }
            if let error = model.entry.error {
                Text(error.message)
                    .font(.footnote)
                    .foregroundStyle(RitualPalette.secondary(dark: scheme == .dark))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onChange(of: countFocused.wrappedValue) { _, focused in
            if focused { selection = TextSelection(range: model.servingsText.startIndex..<model.servingsText.endIndex) }
        }
    }
}

private struct ServingsStepper: View {
    @Bindable var model: CalculatorViewModel
    var countFocused: FocusState<Bool>.Binding
    @Binding var selection: TextSelection?
    @ScaledMetric(relativeTo: .body) private var fieldWidth = 48
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 5) {
            Button { model.stepServings(by: -1) } label: {
                Text("−")
                    .font(.title2.weight(.medium))
                    .frame(width: 44, height: 44)
                    .background(RitualPalette.controlWell(dark: scheme == .dark), in: RoundedRectangle(cornerRadius: 13))
            }
            .accessibilityLabel("Decrease servings")
            .disabled(model.entry.count == 1)
            TextField("Number of servings", text: $model.servingsText, selection: $selection)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.body.weight(.semibold).monospacedDigit())
                .frame(width: max(44, min(96, fieldWidth)))
                .frame(minHeight: 44)
                .focused(countFocused)
                .submitLabel(.done)
                .onSubmit { countFocused.wrappedValue = false; model.finishEntry() }
                .accessibilityLabel("Number of servings")
                .accessibilityHint(Text(model.entry.error?.message ?? "Enter a whole number from 1 to 20."))
            Button { model.stepServings(by: 1) } label: {
                Text("+")
                    .font(.title2.weight(.medium))
                    .frame(width: 44, height: 44)
                    .background(RitualPalette.controlWell(dark: scheme == .dark), in: RoundedRectangle(cornerRadius: 13))
            }
            .accessibilityLabel("Increase servings")
            .disabled(model.entry.count == 20)
        }
        .buttonStyle(.plain)
    }
}

private struct CalculatorRatioPicker: View {
    @Bindable var model: CalculatorViewModel

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                Text("Water : milk").font(.headline).fixedSize()
                Spacer(minLength: 0)
                RatioMenu(model: model).fixedSize(horizontal: true, vertical: false)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Water : milk").font(.headline)
                RatioMenu(model: model)
            }
        }
    }
}

private struct RatioMenu: View {
    @Bindable var model: CalculatorViewModel
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Menu {
            Picker("Water : milk", selection: $model.presetID) {
                ForEach(model.preferences.catalog.presets) { preset in
                    Text("\(Text(preset.ratioText)) · \(Text(preset.name))",
                         comment: "Water-to-milk ratio and the name of the preset.")
                        .tag(preset.id)
                }
            }
            .pickerStyle(.inline)
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(Text(model.preferences.current.ratioText)) · \(Text(model.preferences.current.name))",
                     comment: "Water-to-milk ratio and the name of the preset.")
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption.weight(.semibold))
                    .accessibilityHidden(true)
            }
            .frame(minHeight: 44, alignment: .leading)
        }
        .foregroundStyle(RitualPalette.accent(dark: scheme == .dark))
        .accessibilityLabel("Water to milk ratio")
        .accessibilityValue(Text("\(Text(model.preferences.current.ratioText)) · \(Text(model.preferences.current.name))",
                                 comment: "Water-to-milk ratio and the name of the preset."))
    }
}

private struct CalculatorNotes: View {
    let availability: LocalizedStringResource
    let servingSize: BatchServingSize
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label { Text(availability) } icon: { Image(systemName: "info.circle").accessibilityHidden(true) }
                .font(.subheadline)
            Text(BatchQuantityFormatter.measurementNote(servingSize: servingSize))
                .font(.footnote)
        }
        .foregroundStyle(RitualPalette.secondary(dark: scheme == .dark))
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct CalculatorCard: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.colorSchemeContrast) private var contrast

    func body(content: Content) -> some View {
        content
            .background(RitualPalette.surface(dark: scheme == .dark), in: RoundedRectangle(cornerRadius: 23))
            .overlay {
                if contrast == .increased {
                    RoundedRectangle(cornerRadius: 23)
                        .strokeBorder(RitualPalette.secondary(dark: scheme == .dark), lineWidth: 1)
                        .accessibilityHidden(true)
                }
            }
    }
}

#if DEBUG
private struct MethodsButton: View {
    let action: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text("Methods")
                Image(systemName: "arrow.forward").accessibilityHidden(true)
            }
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, minHeight: 52)
                .foregroundStyle(RitualPalette.onAccent(dark: scheme == .dark))
                .background(RitualPalette.accent(dark: scheme == .dark), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
#endif
