# Approved app design — Daily Ritual

Status: Approved implementation target  
Approved by: Product owner, 10 October 2026

Daily Ritual is the chosen end look and interaction direction for ChaiRatio. Future native app implementation should follow this design. The other three concepts are retained as explorations, not implementation alternatives.

## Source of truth

- [Frozen approved prototype](daily-ritual-approved-2026-10-10.html) — the exact HTML approved on 10 October 2026, including all screen examples and interactive flows. Keep this file unchanged; record subsequent approved revisions separately.
- [Working prototype](daily-ritual.html) — editable version, regenerated from `src/` by `build.mjs`.
- [Calculator reference image](daily-ritual-preview.png) and [measurement sheet reference image](daily-ritual-measures.png).

Approved snapshot SHA-256: `03bc332b76c29493a78356337a9af581685cc0664afdb915baf41ed05812b7e4`.

## Locked visual direction

Use Daily Ritual’s warm cream, chai and brown palette, spacious composition, prominent serif headings and ratio numerals, rounded controls, paired water/milk cards, and simple recipe presentation. Preserve the approved hierarchy, spacing and overall visual character across ratios, calculator, methods, recipe details, cooking and completion.

Implement with native iOS controls and SF Symbols where appropriate, including `info.circle`. The HTML’s inline icons represent their intended appearance. Adapt safely to device size, safe areas, Dynamic Type, VoiceOver and Reduce Motion while retaining the approved design.

## Locked interactions

- Ratios page horizontally through the five finite presets. No up/down arrow buttons. Keep page indicators, ratio descriptions, chai-tone backgrounds and the bottom “Let’s make chai →” action.
- “Let’s make chai” pushes Calculator onto the navigation stack. Use normal Back navigation and preserve current selections and scroll position.
- No tab bar. Calculator’s bottom “Methods →” button uses the same primary-button style and floats over the scrolling content. It pushes Methods.
- Keep `info.circle` in the top-right navigation bar on every main screen. It opens “Know your measures” modally; dismissing it restores the underlying screen and state.
- Serving size choices are Small (150 mL, default), Medium (200 mL), and Large (250 mL). Explain these sizes in the measurement sheet; retain metric ingredient results.
- Tea strength: Regular / Strong. Sweetness: None / Regular / Sweet.
- Carry batch selections through recipe details and cooking. Keep the remaining Daily Ritual screen designs shown in the approved prototype.

## Implementation status and precedence

This approval locks the design target; it does not mean the Swift app already implements it or that draft recipe doses and timings are validated. The existing architecture and product calculation rules still apply.

This decision supersedes earlier design exploration, vertical ratio paging, up/down UI controls, tab-based navigation, numeric-only size selectors, and the extra taste options in older documents. The PRD links to this decision. The earlier ratio-selection feature spec records a prior implementation milestone; its conflicting UI details are historical.

Changes to the approved visual direction or navigation should be agreed with the product owner and recorded as a new design revision.

## Platform decision — 11 October 2026

The native app targets iPhone and iPad only, on iOS/iPadOS 26 or later. Native macOS, Mac Catalyst, and Designed for iPhone/iPad on Mac are excluded. The approved Daily Ritual visual direction still applies; the frozen prototype is unchanged.

## Ratio layout revision — 12 October 2026

Remove “A cup, your way.” from the native ratio screen to give the ratio content more room, particularly in landscape. Keep the serif ratio, descriptions, proportion bar, indicators, and primary action. In wide, short landscape layouts, place the ratio beside its description and proportion bar. Short-height pages must preserve their full content height and scroll vertically when necessary; ratio numerals must not be compressed or clipped. The frozen prototype remains unchanged as the earlier approval snapshot.

## Adaptive layout revision — 17 October 2026

The product owner authorized changes to the current layout to improve screen-size and orientation support using the Apple design and SwiftUI skills. Retain the warm palette and ratio content. Use labeled, wrapping ratio choices in place of dots; retain horizontal paging in roomy layouts. Short windows and larger text sizes use a single vertically scrolling composition with the primary action after the selection controls. Wide layouts place the ratio beside its explanation; accessibility sizes stack them. The measurement guide adapts to its content width. See [implementation and verification](../spec/ratio-selection/adaptive-layout-verification.md). The frozen prototype remains unchanged.

## Indicator and paging revision — 18 October 2026

At the product owner's request, replace the visible ratio-choice labels with tappable indicators, while retaining accessibility labels. Native horizontal swiping changes ratios at every size, including landscape. In constrained layouts, each horizontal page scrolls vertically to keep its content, indicators, and primary action reachable. Top scroll-edge effects use `.soft` on the ratio, calculator, and measurement screens. See [implementation and verification](../spec/ratio-selection/indicator-paging-verification.md).

## Measurement layout revision — 18 October 2026

The product owner requested an adaptive native “Know your measures” sheet following the approved prototype's “Understand the units” flow. Preserve the serving comparison, explanatory copy, individual unit cards, and rounding note. Cup examples may become rows and unit cards may use two columns when space permits; larger text uses one column. Keep a single vertical scrolling flow, native Done dismissal, and soft top scroll edges. See [implementation and verification](../spec/measurements/adaptive-verification.md). The frozen prototype remains unchanged.
