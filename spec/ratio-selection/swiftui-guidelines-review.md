# SwiftUI guidelines review

Reviewed 13 October 2026 using the SwiftUI specialist skill's structure, data flow, environment, modifiers, localization, collection identity, and soft-deprecation references. The current implementation targets iPhone and iPad on OS 26 or later; the historical MVVM-C and Mac requirements are superseded by the Daily Ritual revisions.

## Changes

- `RatioPreferenceStore` uses main-actor `@Observable` with an equatable current preset. The app owns its lifetime through private `@State`; dependent views receive the shared reference. Selection validation, stable persisted IDs, fallback behavior, and redundant-write suppression are retained.
- `RatioSelectionView` owns navigation and sheet presentation. `RatioPagerView` owns transient scroll position, drag state, focus, and scroll restoration. Only a settled user scroll commits a ratio; programmatic synchronization cannot write a preference back in a loop. Scroll commits use stable target IDs instead of inferring identity from pixel offsets.
- Screen sections are separate `View` types with inputs limited to the values they display or forward. Background appearance, primary action, pages, indicators, paging hint, ratio heading, details, proportion bar, and measurement sections have their own view boundaries.
- Ratio pages use the preset ID for collection identity. Serving examples use stable enum cases rather than array offsets. Enumeration no longer copies the preset array on each body evaluation.
- `AnyLayout` switches between horizontal and vertical arrangements while retaining child identity. Scaled serif numerals, the accessibility-size font fallback, vertical overflow scrolling, semantic text styles, Reduce Motion, and the existing contrast-tested palette are retained.
- Model-provided names, descriptions, percentages, endpoints, and accessibility summaries use `LocalizedStringResource`. Numbers and percentages use format styles. The new `Localizable.xcstrings` contains 55 extracted entries and 10 translator comments; English remains the only supplied language.
- Existing preference tests now check Observation notifications and no invalidation for redundant or invalid selection. They continue to use isolated preference suites. Text assertions explicitly resolve English resources.

## Verification

- Xcode 27 / iPhone 18 Pro Max simulator on OS 27: seven tests passed, zero warnings or errors, with output parsed by xcsift.
- Final simulator build, including the narrowed page inputs and synchronized catalog: zero warnings or errors through xcsift.
- The string catalog compiles with `xcstringstool`; whitespace checks pass for the app and tests.
- Final binary launch and landscape rendering were inspected at the saved `water2-milk1` preference: 2:1 Light, selected second indicator, readable content and controls without clipping. The semantic snapshot exposes all five ratio buttons, the measurements action, and the primary action. [Simulator screenshot](/private/tmp/ChaiRatio-SwiftUI-Guidelines-landscape.jpg).

## Remaining manual checks

Interactive swipes, cancelled drags, indicator taps, calculator navigation and Back, sheet dismissal, portrait rotation, VoiceOver adjustment, largest Dynamic Type, and Reduce Motion still require manual checks. Simulator touch tools were unavailable, and both Computer Use surfaces were blocked by setup or permission requirements. These checks are not recorded as passed. Physical devices and OS 26 runtimes were not tested.
