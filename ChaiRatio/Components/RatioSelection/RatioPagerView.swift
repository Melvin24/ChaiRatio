import SwiftUI

/// The store owns selection; every layout uses the same native horizontal pager.
struct RatioPagerView: View {
    let store: RatioPreferenceStore
    let isActive: Bool
    let makeChai: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    private var selection: RatioSelectionState {
        .init(preset: store.current,
              index: store.catalog.presets.firstIndex(where: { $0.id == store.current.id }) ?? 0,
              count: store.catalog.presets.count)
    }

    var body: some View {
        GeometryReader { geometry in
            // Keep all content reachable when a pinned footer would consume the viewport.
            let scrollsTogether = geometry.size.height < 520 || typeSize >= .xxLarge
            VStack(spacing: 12) {
                RatioCarousel(store: store, isActive: isActive,
                              includesControls: scrollsTogether, makeChai: makeChai)
                if !scrollsTogether {
                    RatioSelectionControls(presets: store.catalog.presets,
                                           selectedID: store.current.id,
                                           position: selection.positionText,
                                           select: store.select)
                    MakeChaiButton(isEnabled: isActive, action: makeChai)
                }
            }
            .padding(.bottom, scrollsTogether ? 0 : 8)
        }
        .disabled(!isActive)
    }
}

private struct RatioCarousel: View {
    let store: RatioPreferenceStore
    let isActive: Bool
    let includesControls: Bool
    let makeChai: () -> Void
    @State private var pageID: String?
    @State private var userScrolling = false

    init(store: RatioPreferenceStore, isActive: Bool, includesControls: Bool, makeChai: @escaping () -> Void) {
        self.store = store
        self.isActive = isActive
        self.includesControls = includesControls
        self.makeChai = makeChai
        _pageID = State(initialValue: store.current.id)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(store.catalog.presets.enumerated(), id: \.element.id) { index, preset in
                        RatioScrollablePage(store: store,
                                            selection: RatioSelectionState(preset: preset, index: index,
                                                                           count: store.catalog.presets.count),
                                            isActive: isActive,
                                            includesControls: includesControls,
                                            makeChai: makeChai)
                            .frame(width: geometry.size.width)
                            .id(preset.id)
                            .accessibilityHidden(preset.id != store.current.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .frame(width: geometry.size.width)
            .scrollClipDisabled()
            // Hide adjacent pages without cutting off the vertical scroll beneath toolbars.
            .clipShape(HorizontalPageClip(verticalOverflow: max(geometry.size.height,
                                                                geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom)))
            .scrollEdgeEffectStyle(.soft, for: .top)
            // Align to the actual page, including landscape safe-area insets.
            .scrollTargetBehavior(ViewAlignedScrollTargetBehavior(limitBehavior: .alwaysByOne, anchor: .center))
            .scrollPosition(id: $pageID, anchor: .center)
            .onScrollPhaseChange { _, phase in
                if phase == .interacting { userScrolling = true }
                if phase == .idle, userScrolling {
                    userScrolling = false
                    guard isActive, let pageID else { return }
                    store.select(id: pageID)
                }
            }
            .onChange(of: geometry.size) { restorePage() }
        }
        .onChange(of: store.current.id) { restorePage() }
        .onChange(of: isActive) { restorePage() }
    }

    private func restorePage() {
        userScrolling = false
        pageID = store.current.id
    }

}

private struct HorizontalPageClip: Shape {
    let verticalOverflow: CGFloat

    func path(in rect: CGRect) -> Path {
        Path(rect.insetBy(dx: 0, dy: -verticalOverflow))
    }
}

private struct RatioAdjustment: ViewModifier {
    let selection: RatioSelectionState
    let isActive: Bool
    let selectAdjacent: (Int) -> Void
    @FocusState private var selectorFocused: Bool
    @Environment(\.layoutDirection) private var layoutDirection

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Water to milk ratio")
            .accessibilityValue(Text(selection.accessibilitySummary))
            .accessibilityAdjustableAction { direction in
                guard isActive else { return }
                switch direction {
                case .increment: selectAdjacent(1)
                case .decrement: selectAdjacent(-1)
                @unknown default: break
                }
            }
            .focusable(isActive)
            .focused($selectorFocused)
            .onKeyPress(.leftArrow) {
                guard selectorFocused, isActive else { return .ignored }
                selectAdjacent(layoutDirection == .leftToRight ? -1 : 1)
                return .handled
            }
            .onKeyPress(.rightArrow) {
                guard selectorFocused, isActive else { return .ignored }
                selectAdjacent(layoutDirection == .leftToRight ? 1 : -1)
                return .handled
            }
    }
}

private struct RatioScrollablePage: View {
    let store: RatioPreferenceStore
    let selection: RatioSelectionState
    let isActive: Bool
    let includesControls: Bool
    let makeChai: () -> Void

    var body: some View {
        GeometryReader { page in
            ScrollView(.vertical) {
                VStack(spacing: 12) {
                    RatioPageView(ratioText: selection.preset.ratioText,
                                  name: selection.preset.name,
                                  description: selection.preset.description,
                                  milkShare: selection.preset.milkShare,
                                  milkShareText: selection.preset.milkShareText,
                                  endpointText: selection.endpointText,
                                  horizontal: page.size.width >= 680)
                        .frame(maxWidth: .infinity)
                        .modifier(RatioAdjustment(selection: selection,
                                                  isActive: isActive && selection.preset.id == store.current.id,
                                                  selectAdjacent: store.selectAdjacent))
                    if includesControls {
                        RatioSelectionControls(presets: store.catalog.presets,
                                               selectedID: store.current.id,
                                               position: selection.positionText,
                                               select: store.select)
                        MakeChaiButton(isEnabled: isActive, action: makeChai)
                    }
                }
                .padding(.vertical, includesControls ? 12 : 0)
                .frame(minHeight: page.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollClipDisabled(false)
            .scrollEdgeEffectStyle(.soft, for: .top)
        }
    }
}

private struct RatioSelectionControls: View {
    let presets: [RatioPreset]
    let selectedID: String
    let position: LocalizedStringResource
    let select: (String) -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(presets) { preset in
                    RatioSelectionButton(id: preset.id,
                                         ratioText: preset.ratioText,
                                         name: preset.name,
                                         isSelected: preset.id == selectedID,
                                         select: select)
                }
            }
            Text("Swipe to explore · \(Text(position))",
                 comment: "Ratio selector hint. The variable is the selected position, such as 3 of 5.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(RitualPalette.secondary(dark: scheme == .dark))
        .padding(.horizontal, 24)
        .frame(maxWidth: 560)
        .frame(maxWidth: .infinity)
    }
}

private struct RatioSelectionButton: View {
    let id: String
    let ratioText: LocalizedStringResource
    let name: LocalizedStringResource
    let isSelected: Bool
    let select: (String) -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button { select(id) } label: {
            Capsule()
                .fill(RitualPalette.ink(dark: scheme == .dark))
                .frame(width: isSelected ? 20 : 6, height: 6)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("\(Text(ratioText)), \(Text(name))",
                                 comment: "Ratio selection button. First value is the water-to-milk ratio, second is the preset name."))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
