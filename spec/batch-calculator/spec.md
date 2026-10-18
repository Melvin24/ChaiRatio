# Calculate your batch

Status: Draft feature specification for product review; implementation has not started.  
Prepared: 18 October 2026  
Platform: iPhone and iPad, iOS/iPadOS 26 or later.

## Outcome and sources

Replace the temporary Calculator destination with a usable, offline batch calculator. A person arrives with their chosen water:milk ratio, sees water and milk amounts immediately, and changes the batch without doing the arithmetic themselves.

“Calculate your batch” is this feature's name. Keep **“Make chai”** as the visible screen heading from the approved design; use **“Calculator”** as the inline navigation title, consistent with the current native destination.

Sources, in order of responsibility:

- [PRD](../../prd/PRD.md), especially §§8.2–8.5, 9–11 and 13–14: product behaviour, units and calculation rules.
- [Daily Ritual design decision](../../design-showcase/APPROVED-DESIGN.md) and [frozen approved page](../../design-showcase/daily-ritual-approved-2026-10-10.html?preview=calculator): visual hierarchy and navigation. The page's `calculatorMarkup`, `liquidResults`, `doseCopy` and `mountRitual` define the relevant reference behaviour.
- [Calculator reference image](../../design-showcase/daily-ritual-preview.png): compact layout reference.
- [17 October adaptive revision](../ratio-selection/adaptive-layout-verification.md) and [18 October revision](../ratio-selection/indicator-paging-verification.md): content must adapt; the calculator retains soft top scroll edges.
- [Current Calculator placeholder](../../ChaiRatio/Components/Calculator/CalculatorPlaceholderView.swift), [navigation](../../ChaiRatio/Components/RatioSelection/RatioSelectionView.swift) and [ratio store](../../ChaiRatio/Shared/RatioPreferences/RatioPreferenceStore.swift): integration baseline. The earlier ratio feature's proposed MVVM-C tree does not describe the current implementation.

The frozen HTML remains unchanged. This draft resolves details the approved page leaves implicit; proposed decisions below become the implementation contract when this spec is accepted. It does not mark new design or culinary content as approved.

## Scope and delivery boundary

Included:

- Water and milk calculations, metric formatting and approximate glass equivalents.
- Servings, serving size, the five existing ratios, tea strength and sweetness controls.
- Serving-entry validation, state retention and shared ratio persistence.
- Existing measurement-sheet integration and a batch handoff to Methods.
- Adaptive layouts, appearance support, accessibility and focused verification.

The next feature owns the Methods list, recipe details, cooking steps and completion. This feature defines their input contract without adding recipes or inventing doses. Custom ratios, evaporation controls, utensil customization, saved batches, analytics and new platforms remain outside scope.

**Methods dependency:** The final calculator retains the approved, working “Methods →” push. Until Methods exists, development builds may use an explicitly labelled temporary destination that receives the batch and supports Back. Do not ship a dead button or present a temporary destination as a completed Methods feature. Calculator acceptance and full journey/release acceptance are separate checks.

## Decisions carried forward and proposed defaults

| Item | Requirement | Basis |
| --- | --- | --- |
| Initial ratio | The committed ratio passed from Home | PRD and approved design |
| Initial servings | 4 | Approved prototype; resolves the PRD's unspecified count |
| Serving sizes | Small = 150 mL; Medium = 200 mL; Large = 250 mL | PRD and approved design |
| Initial size | Small | PRD and approved design |
| Tea strength | Regular / Strong; initially Regular | Approved design and prototype |
| Sweetness | None / Regular / Sweet; initially Regular | Approved design and prototype |
| Yield factor | 1.0 for this feature; no automatic boiling-loss allowance | PRD default; no validated yield supplied |
| Change ratio here | Commit immediately through the existing shared preference store; Home and the next launch use it | Proposed clarification of the shared preference |
| Return from Home during the same session | Retain other inputs and use the newly selected Home ratio | Proposed clarification of session retention |
| Relaunch | Open Home with the saved ratio; reset other batch inputs | Proposed choice within the PRD's permitted MVP behaviour |
| Tea/sugar dose data | Show unavailable states until approved content exists | PRD and approved prototype |

## Screen composition

The screen's characteristic element is the paired water/milk answer. Preserve the warm cream background, serif heading, rounded cream cards, brown primary action and restrained native controls. The calculator background stays paper-coloured when ratio changes; chai-tone backgrounds remain part of Home.

Compact, default-text reading order:

```text
Back                                Info
                Calculator

Make chai

[ Water                 ][ Milk                  ]
[ 300 mL                ][ 300 mL                ]
[ ≈ 1.5 glasses         ][ ≈ 1.5 glasses         ]
600 mL starting liquid · 4 × 150 mL servings

[ Servings                         −  4  +       ]
[ Size of each serving                           ]
[ Small          Medium          Large           ]
[ Water : milk                   1:1 · Balanced  ]

Tea strength
[ Regular                  Strong                ]
Sweetness
[ None           Regular         Sweet           ]

Tea/sugar availability or validated quantities
Measurement and boiling-loss note

              [ Methods → ]  (floating action)
```

This diagram describes order, not fixed dimensions or exact system navigation-bar placement. On a typical portrait phone at default text size, both ingredient results and the principal batch controls should be visible near the top. Secondary notes may require scrolling, as in the approved page.

### Visual implementation targets

- Reuse the existing `RitualPalette` ink, secondary, accent, on-accent and paper roles. Use semantic roles for raised surfaces and control wells: the HTML distinguishes `--card` (#FFFCF7 in light appearance) from `--soft` (#E9D8C3). The current native `card` token is the latter colour; add a distinct surface role rather than using tan for every calculator card or changing existing screens unintentionally.
- Match the reference's light cream result/control cards and tan control wells. Dark variants must preserve that surface hierarchy and be checked with actual foreground/background contrast measurements.
- Use a Dynamic Type serif title, with system text for labels, controls and quantities. Quantities use prominent, monospaced digits; units are smaller but readable. Keep the number and unit together when possible; allow a deliberate line break when necessary.
- Starting layout targets: 22 pt outer horizontal margin, 12 pt between ingredient cards, approximately 20 pt card padding, 23 pt card corners and 16–24 pt between groups. These are reference-derived targets, not constraints that override content fitting.
- Reuse the current primary action's visual style, with at least 52 pt height and flexible height for larger text. Use SF Symbols for navigation, info, plus/minus and ingredient illustrations where suitable. Decorative symbols have no separate accessibility focus.
- Keep taste controls visible in the main flow, as approved. Do not place them in a collapsed customization section.

## Inputs and interaction

### Servings

Support whole numbers **1–20** using minus, an editable count and plus. Each button has a minimum 44 × 44 pt target; the count field also has a comfortable editable target. Disable minus at 1 and plus at 20. A single activation changes the count by one and immediately updates the answer. A native stepper implementation or equivalent native buttons may supply the interaction, provided direct entry remains available.

Maintain a text-editing buffer separately from the last valid count. Show a numeric keyboard, provide a reachable keyboard **Done** action, and accept hardware-keyboard submission. Selecting the current count should make replacing it straightforward. Numeric entry must still be validated when pasted or entered using a hardware keyboard.

| Entry/action | Required behaviour |
| --- | --- |
| Integer 1–20 | Update the committed count and results immediately |
| Integer below 1 or above 20 | Clamp to the nearest boundary, normalize the field and show “Servings must be between 1 and 20.” |
| Empty, fractional or malformed text | Keep results at the last valid count; show “Enter a whole number from 1 to 20.” beside the field |
| Done, loss of focus, or navigation with an invalid buffer | Restore the last valid count, clear the transient error and proceed |
| Plus/minus with an invalid buffer | Start from the last valid count, apply one step, normalize the field and clear the error |
| Correction to valid text | Clear the error and update immediately |

Trim surrounding whitespace; parse supported locale digits as integers. Do not interpret decimal, exponent or grouping syntax as a valid serving count. Handle very long pasted integers safely as out-of-range values without arithmetic overflow. No modal error alerts.

Before opening measurements or pushing Methods, resolve the field as above and dismiss its keyboard. Opening a picker or changing another batch input must not send malformed text into the calculation. Default results are always usable, even while a temporary invalid buffer is visible.

### Serving size

Show **Small / Medium / Large**, under **“Size of each serving”**. A selection updates the entire liquid batch immediately. Make the corresponding 150 / 200 / 250 mL values available in accessibility values, the batch summary and the measurement sheet. Keep these named choices rather than replacing them with metric-only labels.

Use a native segmented picker when all labels fit. At larger text sizes or narrow widths, use stacked selectable rows with the same labels, visible selection and minimum 44 pt targets. Do not shrink or truncate labels to retain three columns.

### Ratio

Label **“Water : milk”**. Use a native menu picker showing the current ratio and name, e.g. **“1:1 · Balanced”**. Offer the existing catalog in order: 3:1 Tea-forward, 2:1 Light, 1:1 Balanced, 1:2 Rich, 1:3 Extra rich. Use stable preset IDs and existing localized names; provide the selected/checkmarked state.

Committing a choice updates both liquid results and the shared ratio preference immediately. A cancelled picker makes no change. Strength and sweetness remain selected. This picker changes neither serving size nor count. It does not add arbitrary ratio entry or another carousel.

### Tea strength and sweetness

Show **“Tea strength”** with Regular / Strong, then **“Sweetness”** with None / Regular / Sweet. Use segmented pickers with the same stacked-row fallback. These inputs affect tea/sugar content only; they never change water, milk, serving volume or yield.

The bundled content currently has no validated doses. In this milestone, selections update preference copy and travel with the batch; they must not imply that a numeric dose has been calculated. Keep the choices usable, with an explicit availability note beneath them:

- Regular sweetness: “Regular tea · Regular sweetness. Tea and sugar amounts are not available yet. Add to taste.” Substitute the selected strength and sweetness.
- None: “Regular tea · No sugar. Tea amount is not available yet. Add tea to taste.” Sugar is **None**, rather than an unavailable quantity.

For future validated content, show tea in grams and sugar in a defined, validated unit. The content contract must identify the ingredient, dose basis, applicable serving volume/count range, strength or sweetness mapping, and validation status. A per-serving dose is insufficient when serving sizes differ unless its scaling has also been validated. Missing or out-of-range ingredient data retains an unavailable state independently; never silently substitute or extrapolate a dose. Do not introduce a generic teaspoon-to-gram conversion.

## Calculation and display contract

Keep calculations independent from SwiftUI and formatted strings. Inputs are a valid count, serving size and resolved positive ratio parts. Tea and sugar selections are separate inputs for optional validated content.

```text
S = whole-number servings (1…20)
V = selected serving size (150, 200 or 250 mL)
R = 1.0 in this milestone
a:b = water:milk parts from the catalog

target volume       = S × V
starting liquid     = target volume / R
water               = starting liquid × a / (a + b)
milk                = starting liquid × b / (a + b)
ingredient glasses  = ingredient's unrounded mL / 200
```

`R` is a recipe-data concern for later validated content, with no exposed adjustment in this screen. Do not apply an evaporation percentage, top-up amount, tea absorption or displacement assumption. The summary describes starting liquid; it does not promise an exact finished yield.

Formatting rules:

1. Retain unrounded values internally. Round each liquid independently to the nearest 5 mL when its unrounded amount is below 1,000 mL, or nearest 10 mL at/above 1,000 mL. Positive halfway values round upward; protect exact half-step cases from floating-point artefacts.
2. Keep **mL as the primary value at every batch size**. At an unrounded ingredient amount of at least 1,000 mL, add a secondary L equivalent derived from its displayed mL, with up to two decimal places and no unnecessary trailing zeros.
3. Derive glass equivalents from each **unrounded** ingredient amount; round to the nearest quarter glass, with halfway values upward. Prefix with **≈**. Use decimal quarters (0.25, 0.5, 0.75, 1.25…), matching the approved page. Use singular only for 1 glass.
4. Summary example: **“600 mL starting liquid · 4 × 150 mL servings”**. Use singular for 1 serving and locale-aware number formatting. Starting liquid uses the underlying total, not the sum of independently rounded card values.
5. Because the card values are rounded independently, their sum can differ slightly from the total. Do not alter one ingredient to force the displayed sum to match or use displayed values as future calculation inputs. The measurement guide explains rounding.
6. Retain **“1 glass = 200 mL. Finished yield is estimated; boiling loss varies.”** below the ingredient-preference note. A household glass is not assumed to hold 200 mL.

### Reference calculations

All rows use R = 1.0. Water and milk columns are displayed mL. Glass columns are approximate equivalents from unrounded values.

| Servings × size | Water:milk | Starting mL | Water mL | Milk mL | Water glasses | Milk glasses |
| --- | --- | --- | --- | --- | --- | --- |
| 4 × 150 | 3:1 | 600 | 450 | 150 | 2.25 | 0.75 |
| 4 × 150 | 2:1 | 600 | 400 | 200 | 2 | 1 |
| 4 × 150 | 1:1 | 600 | 300 | 300 | 1.5 | 1.5 |
| 4 × 150 | 1:2 | 600 | 200 | 400 | 1 | 2 |
| 4 × 150 | 1:3 | 600 | 150 | 450 | 0.75 | 2.25 |
| 1 × 150 | 3:1 | 150 | 115 | 40 | 0.5 | 0.25 |
| 1 × 200 | 2:1 | 200 | 135 | 65 | 0.75 | 0.25 |
| 13 × 150 | 1:1 | 1,950 | 975 | 975 | 5 | 5 |
| 8 × 250 | 1:1 | 2,000 | 1,000 | 1,000 | 5 | 5 |
| 20 × 250 | 2:1 | 5,000 | 3,330 | 1,670 | 16.75 | 8.25 |

The 1,000 mL cards add **1 L**; the final row adds **3.33 L** and **1.67 L**. The 150 mL minimum case deliberately tests independent halfway rounding: 115 + 40 is 155, while starting liquid remains 150 mL.

## Navigation, state and lifetime

Use the existing navigation stack. “Let’s make chai” pushes Calculator with the committed Home ratio. Keep standard Back navigation and interactive back gestures. Keep `info.circle` top-right with the accessible name **“Know your measures”**; present the existing measurement sheet and restore the underlying calculator on dismissal.

| Transition | State requirement |
| --- | --- |
| First calculator entry this session | Supplied Home ratio, 4 servings, Small, Regular tea, Regular sweetness |
| Input change | Immediate results; no Calculate, Apply or Save action |
| Open/dismiss measurements | Retain all selections, results and calculator scroll position |
| Push Methods, then Back | Retain all selections and restore scroll position |
| Back to Home | Reflect any ratio chosen in Calculator; retain the in-memory batch |
| Choose another ratio on Home and re-enter | Apply that ratio; retain servings, size and taste preferences |
| Background/foreground, rotation or window resizing | Retain selections and editing state unless a navigation action resolves entry |
| Terminate and relaunch | Home with saved ratio; other inputs return to defaults on calculator entry |

Preserve scroll position when returning to the same layout; after resizing, retain the nearest meaningful position and keep focused content reachable rather than restoring an invalid pixel offset. Standard navigation focus moves to the destination heading; sheet dismissal restores focus to Info where supported. Guard repeated Methods taps from pushing duplicates.

### Methods handoff

Pass a typed batch snapshot with preset ID, servings, serving size in mL, strength and sweetness. Methods resolves ratio definitions from the same catalog and uses the same calculation service. Do not pass rounded strings or infer selections from card text. Any later recipe-specific yield/dose data must be explicit and applied consistently across its quantities; choosing a method must not silently change the user's ratio or taste preferences.

The snapshot and the retained calculator state initially agree. Returning from a read-only downstream screen changes neither. Editing batch inputs from later features, if introduced, needs an explicit state-update contract in that feature's spec.

## Adaptive layout and accessibility

Use a single vertical content scroll view with soft top scroll edges. Keep results before controls in reading order at all sizes. On roomy iPads, centre a readable composition rather than stretching cards across the entire display; a starting maximum width of about 680 pt is a design judgment to validate in previews. This feature does not require a second navigation column.

- Keep water and milk side by side when their full content fits. Stack Water above Milk when width or text size prevents readable amounts, units and equivalents. Do not truncate quantities or reduce text size to retain the pair.
- Let labels and values stack in the ratio and servings rows. All controls remain available in landscape, narrow iPad windows and the largest accessibility text sizes. Do not select layouts solely by device name or orientation.
- Float Methods above the bottom safe area in normal layouts, matching the approved page. Reserve measured trailing scroll space so the last note can be scrolled completely above it. No essential content may remain hidden behind the action.
- In short windows, when text growth makes the floating action consume too much usable height, or while the keyboard is present, place Methods after the content in the scroll flow. This is a proposed adaptive detail consistent with the authorised layout direction. Do not pin it above the keyboard at the expense of the count field or its error.
- Use at least 44 × 44 pt interaction targets, Dynamic Type through Accessibility 5, and visible selection cues beyond colour. Target at least 4.5:1 normal-text contrast and 3:1 large-text/essential-control contrast in both appearances; measure actual rendered colour pairs.
- VoiceOver reads heading, Water result, Milk result, batch summary, inputs, availability note and Methods in logical order. Each result is one coherent item, e.g. “Water, 300 millilitres, approximately 1.5 glasses.” Expand symbols and units in speech.
- The count has an editable value; plus/minus have explicit names. Picker accessibility values include the selected option and serving volume where applicable. A custom selectable row exposes its selected trait. Errors are associated with the count and announced without moving focus.
- Preserve focus on the changed control during recalculation. Announce a concise combined liquid result after changes settle; coalesce repeated stepper changes to avoid a queue of obsolete announcements. Taste-only changes must not announce a changed liquid quantity.
- Reduce Motion removes decorative value transitions; results remain immediate. Increase Contrast and Reduce Transparency retain readable surfaces and controls. Support system keyboard focus, Switch Control and Voice Control using native semantics and unique labels. No haptics or animation is required to understand the answer.

Design guidance consulted through the Apple design skill: `layout.md › Adaptability` (“Be prepared for text-size changes”); `typography.md › Supporting Dynamic Type`; `accessibility.md › Vision`; `color.md › Best practices`; `entering-data.md › Best practices` (“Dynamically validate field values”); `text-fields.md › Best practices`; `pickers.md › Best practices`; `virtual-keyboards.md › Best practices`; `buttons.md › Content`; `sheets.md › Platform considerations`; and `designing-for-ios.md › Best practices`. Dimensions, fallback choices and state lifetime above are product/design judgments for this feature, rather than Apple-prescribed rules.

## Implementation boundaries

Follow the current native app's lightweight observable-state structure. This feature does not require migrating the app to the historical coordinator proposal or adding a new framework.

- **Shared ratio preference store:** remains the single source of truth for the selected preset and its persisted ID. Reuse `RatioCatalog` validation and fallback. Never persist array positions, formatted names or another calculator-specific ratio preference.
- **Batch session state:** owns validated count, serving size, strength, sweetness and view-restoration needs. Its lifetime survives popping Calculator to Home; own it above the destination or inject a retained session. Do not recreate defaults every time the destination view appears. Field text/focus remains presentation state.
- **Calculation service:** pure deterministic input/output, returning unrounded numeric liquid values and total. Validate boundary inputs defensively; invalid catalog/configuration values must not produce NaN, infinity or negative results in the UI.
- **Quantity formatter:** centralizes mL, L, glass rounding, pluralization and localized output. The display model is derived from the numeric result, never a second source of batch truth.
- **Calculator view:** composes result cards, batch controls, taste controls and action; requests navigation without calculating in view markup. Reuse `MeasuresView` instead of creating a second unit glossary.
- **Navigation boundary:** replaces `CalculatorPlaceholderView` and extends the existing typed route. Own the Methods route and batch payload at the appropriate stack/session boundary; avoid nested navigation stacks.
- **Strings and content:** use the current string catalog for visible/accessibility copy, plurals and interpolation comments. Extend it for new labels and errors. Metric-first English is the release scope; respect locale number conventions and avoid concatenating translated fragments.

Suggested additions are a calculator view, retained batch state, calculation/formatting types and focused tests. Choose filenames during implementation; avoid empty coordinators, protocols or content files solely to mirror an older folder diagram. Keep unvalidated culinary data out of numeric outputs.

## Acceptance and verification

### Automated checks

- Verify every reference-table row, halfway rounding, the 1 L threshold, L formatting and singular/plural glass/serving output.
- Exercise all 300 liquid combinations (20 counts × 3 sizes × 5 ratios). Before display rounding, water + milk equals starting liquid within numerical tolerance; values are positive and finite, and the selected ratio is preserved.
- Verify that changing count/size updates volumes; ratio changes conserve starting volume; strength/sweetness changes preserve all liquid results.
- Verify field editing and recovery for empty, fractional, malformed, zero, negative, over-limit, extremely long and corrected entries, including stepping and navigating from an invalid buffer.
- Verify first-entry defaults, return from Methods/measurements, Home re-entry, changed Home ratio, and relaunch persistence/reset. Check that selecting an already selected ratio causes no redundant preference write.
- Verify unavailable-dose behaviour, including None sugar and independent missing/out-of-range ingredient content when validated-dose support is introduced.

### UI and manual checks

- On entry from each Home ratio, show its matching result and picker selection without a flash of default 1:1.
- Check the approved default case visually: 4 Small servings, Balanced, 300 mL water, 300 mL milk and approximately 1.5 glasses each.
- Verify editable count, min/max disabled controls, all named pickers, keyboard Done and hardware-keyboard submission. Check the last note and Methods remain fully reachable.
- Verify Calculator → measurements → dismiss and Calculator → Methods → Back with retained state and scroll. Verify Home → Calculator re-entry and repeated action taps.
- Inspect a small portrait iPhone, landscape iPhone, portrait/landscape iPad and narrow iPad window. Repeat critical flows at Accessibility 5, in dark appearance, with Increase Contrast, Reduce Motion and Reduce Transparency.
- Manually check actual VoiceOver speech/order, change announcements, focus restoration, Switch Control, Voice Control and Full Keyboard Access. Screenshots alone do not establish assistive-technology correctness.
- Build for the minimum supported iOS/iPadOS 26 SDK/runtime where available, plus the current project runtime. Use xcsift for Swift/Xcode build/test commands in accordance with the repository's tooling skill. Record unavailable device/runtime checks as remaining coverage.

Feature acceptance requires usable liquid results, the specified interactions and retained state. End-to-end release acceptance additionally requires a real Methods destination and the PRD's reviewed recipe content. This document records planned checks; none are claimed as executed.

## Content dependencies and review points

No additional product answer is required to draft or implement the liquid calculator. Review the proposed defaults/state lifetime and adaptive Methods placement above before treating this draft as approved.

Kitchen validation remains required for tea/sugar dose tables, applicable batch ranges, timings and any future non-1.0 recipe yield. The explicit unavailable states let the liquid calculator be built and reviewed while those content tasks continue. They do not satisfy the PRD's eventual validated ingredient and recipe requirements.
