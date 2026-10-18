# Adaptive SwiftUI layout

Historical revision: the [18 October indicator and paging update](indicator-paging-verification.md) supersedes this revision's visible ratio labels and non-paged constrained layout.

Reviewed and implemented: 17 October 2026. This revision follows the user's authorization to change the existing layout for screen size, orientation, and accessibility. Earlier frozen visual targets are historical; the warm palette and serif ratio remain.

## Design review

The screen's job is to compare water-to-milk ratios and continue with the selected ratio. Its warm, proportion-based identity remains useful.

The previous fixed-width carousel and separately pinned controls competed for vertical space in short windows. Tiny page markers also hid the available ratio values. Measurement examples chose their arrangement from accessibility category alone, without checking whether their contents fit.

Guidance applied from the Apple design skill:

- `layout.md › Adaptability`: “Be prepared for text-size changes.” Layout now follows available width and height and the selected text size, rather than device identity or orientation.
- `typography.md › Supporting Dynamic Type`: “Consider adjusting your layout at large font sizes.” Larger text uses a single scrolling flow; text is allowed to grow vertically.
- `accessibility.md › Vision`: “Convey information with more than color alone.” Ratio buttons show their values, an underline for selection, and the accessibility selected trait.
- `scroll-views.md › Best practices`: “Support default scrolling gestures and keyboard shortcuts.” Roomy layouts retain native horizontal paging; constrained layouts offer explicit ratio choices and ordinary vertical scrolling.
- `buttons.md › Content`: “Ensure that each button clearly communicates its purpose.” Ratio values replace unlabeled dots; targets are at least 48 points high.

Layout cutoffs and width limits are implementation judgments, not Apple-prescribed values.

## Implementation

- Below 520 points of available content height, or at XX Large Dynamic Type and above, the ratio, selection controls, and primary action share one vertical scroll view. The footer cannot consume the viewport.
- At other sizes, native horizontal paging fills the available space with stable selection controls and the primary action below it.
- At widths of at least 680 points, ratio and explanation sit side by side. Accessibility text sizes retain a single column. Content width is limited for readability on large iPads.
- Adaptive ratio buttons wrap into fewer columns as text grows. Text and controls respect safe areas.
- The shared observable store remains the source of truth. Transient carousel state is local to the carousel. Only a settled user scroll commits selection; resize and navigation resets restore the committed ID without writing preferences.
- VoiceOver adjustment and focused arrow keys remain available. Arrow direction respects right-to-left layout. Reduce Motion still disables background transitions.
- Measurement examples use content fitting with a row fallback. Definition headings and values stack when they cannot fit together. Calculator copy scrolls and grows vertically, with consistent colors and an inline navigation title.
- SwiftUI skill guidance applied: separate view types for sections, narrow display inputs, stable preset IDs, `AnyLayout` for rearrangement, localizable resources and a catalog entry for the new heading, current `onChange` signatures, and no redundant selection model.

## Validation

- iOS Simulator build passed with zero warnings and errors, parsed with xcsift.
- All seven existing tests passed on the iPhone 17e simulator (iOS 27), with zero warnings/errors: catalog integrity, restored/default selection, invalid values, no-op persistence, selection boundaries, observation, and light/dark contrast.
- A temporary XCUITest harness under `/private/tmp` verifies the actual app without adding targets or testing hooks to this project.
- iPad mini (iOS 27): both UI scenarios passed. Portrait/landscape rotation, direct ratio selection, Calculator/Back, measurement-sheet dismissal, and selection retention were exercised. Accessibility 5 content, choices, primary action, and measurements remain reachable by scrolling.
- iPhone 18 Pro (iOS 27): Accessibility 5 interaction scenario passed, including selection, scrolling to the primary action, measurements, dismissal, and retained selection.
- iPhone 17e (iOS 27): normal-text UI scenario passed with zero runtime warnings. Horizontal swiping commits the visible preset; rotation preserves selection; the landscape primary action is reachable by scrolling; Calculator/Back and the measurement sheet retain the chosen ratio. The test waits for rotation to finish and directs gestures inside the scroll view.
- Dark appearance was visually inspected on iPhone 18 Pro in landscape. The existing contrast test also checks both appearances.

Screenshots inspected:

- [iPhone portrait](adaptive-iphone-portrait.png)
- [iPhone landscape](adaptive-iphone-landscape.png)
- [iPhone landscape footer](adaptive-iphone-landscape-footer.png)
- [iPhone measurement guide](adaptive-iphone-measures-wide.png)
- [iPad landscape](adaptive-ipad-landscape.png)
- [iPad measurement guide](adaptive-ipad-measures-wide.png)
- [iPad Accessibility 5](adaptive-ipad-accessibility5-top.png)
- [iPad Accessibility 5 footer](adaptive-ipad-accessibility5-footer.png)
- [iPad large-text measurements](adaptive-ipad-measures-accessibility5-scroll.png)
- [iPhone landscape, dark](adaptive-iphone-landscape-dark.png)

Not verified: physical devices, iOS/iPadOS 26 runtimes, narrow iPad multitasking windows, actual VoiceOver speech, hardware-keyboard navigation, and the Reduce Motion setting. These remain manual coverage limits; no accessibility certification is implied.
