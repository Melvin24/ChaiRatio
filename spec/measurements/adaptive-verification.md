# Adaptive “Know your measures” sheet

Implemented: 18 October 2026.

## Reference and scope

The reference is the “Understand the units” preview in `design-showcase/daily-ritual-approved-2026-10-10.html`, implemented by `measurementsMarkup()`. That preview opens “Know your measures” as a sheet. This revision preserves its order and exact educational copy: heading/subtitle, serving-size comparison, serving caveat, Glass/Teaspoon/Tablespoon/Grams cards, then display precision.

The frozen HTML is unchanged. Its SHA-256 remains `03bc332b76c29493a78356337a9af581685cc0664afdb915baf41ed05812b7e4`.

## Design and SwiftUI changes

- Restored individual rounded unit cards using the prototype's light `--card` color (`#fffcf7`). The serving guide retains the warmer `--soft` treatment and three distinct cup sizes.
- Serving examples compare Small (150 mL), Medium (200 mL), and Large (250 mL) side by side when their content fits. Narrow widths use rows; larger text uses rows or vertically stacked icon/text to protect reading space.
- Unit cards use a two-column grid when its scaled minimum widths fit, and a single column otherwise. At XX Large text and above, they always use one column. Names and values stack independently when they cannot share a line.
- A single native vertical scroll view keeps every reference item reachable in short landscape windows. No fixed content heights, pinned content footer, or geometry/state feedback loop is used.
- The sheet keeps native navigation, a persistent Done button, swipe dismissal, a grabber, and soft top scroll edges. The long reference uses the large sheet detent. Maximum reading width is 760 points, with system safe areas respected.
- Sections are separate SwiftUI view types. Examples and definitions use stable enum identities and localizable resources. The guide has no selection/persistence state: it remains an educational reference, like the HTML.
- Heading traits and combined per-example/per-definition accessibility elements keep related content together. Decorative cup symbols are hidden from VoiceOver. Text uses semantic styles and can grow vertically.

Apple design references applied:

- `layout.md › Adaptability`: “Be prepared for text-size changes.” Content fitting and explicit larger-text layouts replace reliance on a single arrangement.
- `typography.md › Supporting Dynamic Type`: “Consider adjusting your layout at large font sizes.” Reference values and descriptions remain complete instead of being scaled down or truncated.
- `sheets.md › Platform considerations`: native sheet sizing, toolbar dismissal, grabber, and swipe dismissal preserve the app context.
- `scroll-views.md › Best practices`: one vertical scroll container avoids nested scrolling on the same axis.

On the new light unit-card surface, measured WCAG contrast is 14.84:1 for primary text, 10.23:1 for secondary text, and 7.17:1 for the accent.

## Validation

- iOS Simulator build passed with zero warnings/errors through xcsift.
- Localizable string catalog parses successfully.
- iPhone 17e (iOS 27) UI verification passed: one scenario, zero failures/warnings. Normal-text portrait and landscape checks reach all three serving examples, all four definitions, and the precision note. The largest accessibility text size also keeps the content reachable, including the landscape precision note. Done stays available and dismissal preserves the selected Balanced ratio.
- iPad mini (iPadOS 27) normal-text portrait and landscape screenshots show the serving guide, all four unit cards, and the precision note without clipping. A focused native-scroll scenario at the largest accessibility text size passed with zero failures/warnings. Its overlapping captures verify all three servings, the serving caveat, all four definitions, and the full precision note; the landscape capture also shows the complete note. Done dismisses to the same selected ratio.

The phone UI check reads combined accessibility labels and scrolls actual text into view. The final iPad check targets the foreground sheet's scroll view and captures native swipes for visual review. Earlier harness failures came from decorative padding in visibility bounds, floating-sheet coordinates, static-text hittability, and selecting an underlying scroll view. Validation corrections required no app-code changes.

Selected iPhone evidence (each image has a matching `-hierarchy.txt` file):

- [Portrait guide and first definitions](measures-iphone-portrait-top.png)
- [Landscape serving comparison](measures-iphone-landscape-small.png) and [unit cards](measures-iphone-landscape-grams.png)
- [Largest-text Glass definition](measures-iphone-accessibility5-glass.png) and [Grams definition](measures-iphone-accessibility5-grams.png)
- [Largest-text landscape precision note](measures-iphone-accessibility5-landscape-precision.png)

Selected iPad evidence (each image also has a matching hierarchy):

- [Portrait guide](measures-ipad-portrait-top.png) and [landscape definitions](measures-ipad-landscape-definitions.png)
- [Largest-text Small and Medium](measures-ipad-ax5-small-medium.png), [Large and serving caveat](measures-ipad-ax5-large-caveat.png), and [Glass](measures-ipad-ax5-glass.png)
- [Largest-text spoon definitions](measures-ipad-ax5-spoons.png), [Grams](measures-ipad-ax5-grams.png), and [precision note](measures-ipad-ax5-precision.png)
- [Largest-text landscape precision note](measures-ipad-ax5-landscape-precision.png)

Passing result bundles: `/private/tmp/ChaiRatio-Measures-iPhone-Retry.xcresult` and `/private/tmp/ChaiRatio-Measures-iPad-AX5-Visual.xcresult` (temporary verification harness; app source/project structure was not changed to add UI tests).
