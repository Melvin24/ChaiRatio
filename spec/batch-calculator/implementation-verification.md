# Batch calculator implementation and verification

Implemented 18 October 2026 against [the feature spec](spec.md) and the frozen `daily-ritual-approved-2026-10-10.html`. The approved HTML was not modified. The owner requested a coordinator and view model, adaptive layouts, and no simulator tests.

**UI correction, 18 October:** Calculator now follows the selected ratio background. “Make chai” is the native large navigation title and collapses on scroll. Glass counts are prominent and mL secondary. A glass now matches the selected serving size: Small 150 mL, Medium 200 mL, Large 250 mL. The conversion, explanatory note, Methods handoff display and Measurements sheet use the same size. This correction supersedes the original fixed 200 mL glass definition and paper-background design.

## Design review and direction

The previous destination was a placeholder: it displayed a ratio but offered neither liquid answers nor batch controls. Its critical functional gap is addressed by this implementation. The new screen's single job is to turn the selected ratio and batch size into immediately readable water and milk amounts. The paired liquid cards remain the signature from the approved chai design.

Apple design guidance used:

- `layout.md › Visual hierarchy`: “Order content by relative importance.” Results remain before controls, including in landscape and stacked layouts.
- `layout.md › Adaptability`: “Be prepared for text-size changes.” Scaled minimum widths and fitting candidates replace assumptions about device names or orientation.
- `layout.md › Adaptability`: “Keep functionality the same as size classes change.” Every input remains in the scroll flow at constrained sizes.
- `entering-data.md › Best practices`: “Dynamically validate field values.” The editable buffer is separate from the last valid count; inline errors never invalidate liquid results.
- `pickers.md › Best practices`: “Use predictable and logically ordered values.” The existing five ratio presets retain catalog order.
- `dark-mode.md › Best practices`: “Ensure that your app looks good in both appearance modes.” Calculator surfaces have explicit light/dark roles; system bars retain their native appearance.

SwiftUI guidance used: `structure.md` (separate section views), `dataflow.md` (retained main-actor observable model, key-path bindings), `foreach.md` (stable preset/option identity), `localization.md` (string catalog, complete localizable phrases, number formatting), `environment.md`, `modifiers.md` and `soft-deprecation.md`.

### Tokens and type

These are existing Daily Ritual roles plus a new raised `surface`; `card` keeps its existing meaning for Home and Measurements. This is a continuation of the approved chai palette, using the existing Home ratio tones for the calculator background.

| Role | Light | Dark | Use |
| --- | --- | --- | --- |
| Paper | `#F8F2E9` | `#2B231C` | Measurement-sheet background |
| Surface | `#FFFCF7` | `#362B22` | Results and batch-controls card |
| Control well | `#E9D8C3` | `#403326` | Servings and choice controls |
| Ink | `#332218` | `#FFFAF1` | Main text |
| Secondary | `#503B2E` | `#E3C5A6` | Supporting text and symbols |
| Accent | `#814725` | `#E3C5A6` | Actions; paired with existing on-accent ink |

Computed WCAG contrast from the opaque sRGB token values:

| Pair | Light | Dark |
| --- | ---: | ---: |
| Ink / paper | 13.65:1 | 14.85:1 |
| Ink / surface | 14.84:1 | 13.24:1 |
| Ink / control well | 10.90:1 | 11.75:1 |
| Secondary / paper | 9.41:1 | 9.41:1 |
| Secondary / surface | 10.23:1 | 8.39:1 |
| Secondary / control well | 7.51:1 | 7.45:1 |
| Accent / control well | 5.27:1 | 7.45:1 |
| On-accent / primary action | 7.06:1 | 9.26:1 |
| Ink / lowest-contrast ratio background | 6.99:1 | 8.84:1 |
| Secondary / lowest-contrast ratio background | 4.82:1 | 5.61:1 |

These are source-token calculations, not measurements of rendered screenshots. Native segmented-control selection, disabled controls and keyboard focus still need visual inspection. Increase Contrast adds explicit card outlines. All app-owned surfaces are opaque; they do not depend on transparency. There are no decorative result animations, so Reduce Motion needs no alternate result transition.

The heading uses the native Dynamic Type large navigation title with `.toolbarTitleDisplayMode(.large)`, collapsing to an inline title through the system navigation stack. There is no duplicate content heading. Quantities use `.title` with semibold monospaced digits; controls use `.body`/`.headline`, secondary quantities `.subheadline`, and summary/notes `.footnote`. Text is never shrunk to keep a layout. Initial spacing follows the reference: 22 pt horizontal page margins, 12 pt between results, 20 pt card padding and 23 pt corners. Interactive targets are at least 44 pt, with a primary action at least 52 pt high.

### Layout and craft

One vertical scroll view keeps the same reading order at every size. A readable composition is centred with a maximum width of 680 pt, including its outer padding.

```text
Compact portrait / regular text       Constrained width or larger text
Make chai (native large title)       Make chai (native large title)
[ Water ][ Milk ]                    [ Water                ]
Starting-liquid summary              [ Milk                 ]
[ Servings       − count + ]          Starting-liquid summary
[ Size: Small Medium Large ]         [ Servings              ]
[ Water : milk    ratio menu ]       [ − count +             ]
Tea strength: [Regular Strong]        [ Size: selectable rows ]
Sweetness: [None Regular Sweet]       [ Ratio menu            ]
Availability + measurement note      Tea + sweetness rows
          [ Methods → ]              Notes
                                     [ Methods → ] in flow
```

Results use scaled width requirements before stacking. Amount and unit stay together when possible, with a vertical fallback. Segmented pickers become selectable rows at XX Large and above or when their scaled minimum width does not fit. Servings and ratio labels stack independently. The floating Methods action uses a measured safe-area inset, so the final note can scroll above it. It moves into the content below 520 pt available height, at XX Large text or above, or while the count has keyboard focus. These breakpoints are design judgments awaiting the owner's visual checks.

The design deliberately keeps taste controls visible and removes extra decorative containers around notes. Familiar native pickers and navigation carry interaction; the native large title, cream cards and paired liquid answer carry the product identity.

## Architecture and behaviour

- `AppRoot/ChaiCoordinator.swift` owns the typed stack, measurement sheet and retained `CalculatorViewModel`. Duplicate calculator/Methods pushes are guarded. The existing single navigation stack remains at `RatioSelectionView`; only the existing measurement sheet has its own modal stack.
- `Components/Calculator/CalculatorViewModel.swift` owns batch inputs, entry validation and a stable section identifier for scroll restoration. `RatioPreferenceStore` remains the sole persisted ratio source. Returning Home and selecting a new ratio updates the retained calculator without resetting other inputs. A new app session resets the other inputs.
- `Shared/Batch/BatchSnapshot.swift` defines the typed Methods input: preset ID, count, serving size/volume, strength and sweetness. The downstream development view recalculates from that input and the shared catalog; no formatted answers travel through navigation.
- `Shared/Batch/BatchCalculator.swift` contains Foundation-only decimal arithmetic and defensive validation. It keeps unrounded quantities, uses yield 1.0 and avoids integer overflow even with extreme positive ratio parts.
- `Shared/Batch/BatchQuantityFormatter.swift` centralizes independent metric rounding, the unrounded 1 L threshold, litre equivalents, quarter-glass rounding using the selected serving volume, the size-dependent conversion note and summary pluralization.
- `ServingsEntry` keeps valid results available during malformed edits. It supports decimal Unicode digits, trims outer whitespace, clamps out-of-range signed integers and saturates very long values safely. Done, focus loss, navigation and stepping normalize the field.
- `CalculatorAnnouncements` debounces liquid announcements by 600 ms and cancels obsolete messages. Taste-only changes do not change liquids or trigger liquid announcements. Errors have inline text, count-field hints and VoiceOver announcements. Result cards expose coherent spoken quantities, expanded units and hidden decorative symbols. Info focus is restored after sheet dismissal where supported.
- `Localizable.xcstrings` contains new visible/accessibility copy, comments and English summary plurals. No numeric tea/sugar doses were invented; None sweetness is explicitly “No sugar.”

### Methods boundary

Debug builds retain the approved **Methods →** push into an explicitly labelled **Methods preview** development destination. It shows the typed batch and supports native Back and Measurements. Release builds exclude that route/view/action and show “Preparation guides are not available yet.” This keeps the temporary destination out of shipping code while the separate Methods feature is unfinished. Full product/release acceptance still requires real, reviewed Methods content and the final Methods action in Release.

## Executed checks

- Xcode 27 / iOS 27 SDK, minimum deployment target iOS 26: Debug generic-device build succeeded with **0 errors and 0 warnings**.
- Release generic-device build succeeded with **0 errors and 0 warnings**, including the compile-time Methods exclusion.
- Generic-device `build-for-testing`: app and the complete existing/new iOS test target compiled with **0 errors and 0 warnings**. This action did not execute tests.
- **12 focused XCTest tests ran directly on the Mac**, with **0 failures**. The host bundle compiled the production Foundation/Observation sources and temporary copies of the new test files, without `@testable import`, into `/private/tmp/ChaiRatio-Batch-Host/ChaiRatioBatchLogic.xctest`. Only the temporary English test helper was adjusted to resolve resources from that bundle. No app/platform target was added or changed.
- The tests cover all 10 reference-table rows, all 300 combinations, conservation and ratio preservation, independent halfway rounding, glass halves, litre threshold/formatting, summary singular/plural, defensive invalid inputs, long/Unicode/pasted entry, recovery, selected-size glass counts and notes, defaults, duplicate pushes, typed handoff, measurement/Methods return, Home re-entry, shared persistence, redundant writes, relaunch reset and unavailable/no-sugar copy.
- English string catalog compilation succeeded. Contrast calculations are recorded above.

No simulator was launched. No simulator or on-device test was run. Xcode previews were supplied but not rendered. iOS 26 runtime behaviour and actual assistive-technology behaviour remain unverified.

## Owner's manual acceptance pass

Use `CalculatorPreviews.swift` or run the app yourself. Preview definitions cover 320 × 568 portrait, 740 × 360 short landscape, 1024 × 768 iPad, a 320 pt window at Accessibility 5 and dark appearance.

- [ ] Enter from all five Home ratios; verify the selected ratio appears immediately. Default Balanced should show ≈ 2 glasses with 300 mL beneath for each liquid, and 1 glass = 150 mL.
- [ ] Edit, paste, clear, correct and step the count; test min/max disabled buttons, inline error, select-all replacement, numeric-keyboard Done and hardware-keyboard Return.
- [ ] Scroll to collapse the large “Make chai” title into the navigation bar and back to expand it. Confirm the ratio background updates from every ratio choice.
- [ ] Change each size/ratio/taste control; inspect segmented and stacked selections and multi-litre cards. Check the glass note and Measurements definition show 150 / 200 / 250 mL for Small / Medium / Large and agree with the prominent glass counts.
- [ ] Rotate and resize while editing and while scrolled. Check small portrait and landscape phones, both iPad orientations and narrow iPad windows through Accessibility 5. Ensure values/units never truncate and every control remains reachable.
- [ ] Verify Methods floats in roomy layouts and enters the scroll flow in short windows, at large text and while editing. Scroll the complete final note above the floating action.
- [ ] Open/dismiss Measurements, push Methods and go Back, then return Home and re-enter with another ratio. Verify inputs, scroll position and Back gestures. Repeated Methods taps must push once.
- [ ] Check light/dark, Increase Contrast, Reduce Transparency and Reduce Motion; inspect actual native control contrast/focus/disabled states.
- [ ] Check VoiceOver order/speech, count error announcements, coalesced result updates without focus movement, taste-only silence, and Info focus restoration. Also check Switch Control, Voice Control and Full Keyboard Access.
- [ ] Relaunch: Home should retain the ratio; other batch inputs should reset on entry. Repeat core flows on iOS/iPadOS 26 where available.
