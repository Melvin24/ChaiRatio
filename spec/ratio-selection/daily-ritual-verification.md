# Daily Ritual ratio screen verification

Platform revision, 11 October 2026: the project now supports iPhone and iPad only. Earlier Mac requirements and verification results below are historical. Native macOS, Mac Catalyst, and Designed for iPhone/iPad on Mac are excluded. The iOS simulator app and unit-test targets build successfully with zero warnings/errors. Xcode lists only iOS destinations as compatible and marks My Mac incompatible.

Reviewed: 11 October 2026. Changes remain uncommitted.

The screen follows the approved design and frozen prototype. The frozen HTML remains unchanged; its SHA-256 matches the design decision.

## Implementation

The screen uses the serif heading and ratio, approved chai backgrounds, brown text, water/milk distribution bar, percentages, horizontal paging, tappable page indicators, and fixed “Let’s make chai” pill button. The exploratory style picker and up/down controls were removed.

The native info button opens “Know your measures” with Small/Medium/Large serving examples and volume/weight definitions. The existing calculator placeholder also exposes this sheet. Calculator functionality remains outside this task.

Persistence and navigation use the existing shared observable store and local SwiftUI state. Horizontal scrolling commits only at rest. Indicator taps, VoiceOver adjustment, and focused Left/Right keys use validated selection. Navigation captures the committed ID and guards duplicate pushes. Content can scroll vertically in short windows or at large text sizes. Reduce Motion disables background transitions.

Secondary text is slightly darker than the HTML prototype to meet 4.5:1 on every light background. No coordinator or input/output protocol layers were introduced.

## Evidence

- Mac: seven tests passed with zero warnings/errors, including strengthened checks using the actual foreground and background colors.
- iPhone: seven tests passed with zero warnings/errors before the secondary text adjustment and strengthened contrast test. An extra rerun was declined and was not repeated.
- iPad: final build passed with zero warnings/errors.
- iPhone 18 Pro simulator screenshot inspected: correct 1:1 Balanced, third indicator, typography, proportion bar, percentages, info button, and primary action. [Screen capture](daily-ritual-iphone.png).
- Frozen prototype SHA-256: `03bc332b76c29493a78356337a9af581685cc0664afdb915baf41ed05812b7e4`.

Build/test output was parsed by xcsift. The simulator plugin could not find simctl because the system developer directory points to Command Line Tools. The installed Xcode path was used directly; the system setting was not changed.

## Remaining verification

Interactive swipes/cancellation, indicator taps, Back and sheet dismissal, VoiceOver, largest Dynamic Type, landscape, Mac resizing/keyboard focus, and Reduce Motion require manual verification. Physical devices and OS 26 runtimes were not verified; deployment minimums remain 26. The older feature spec contains historical UI requirements superseded by the approved design.

## Landscape correction — 12 October 2026

Removed “A cup, your way.” at the user's request. Ratio pages retain their intrinsic vertical content height, with overflowing content aligned at the top of a vertical scroll view. Removed negative spacing on the serif numerals and added trailing glyph clearance. Wide, short layouts place the ratio beside its details; portrait and accessibility text sizes retain the stacked layout.

The iOS simulator build passes with zero warnings/errors through xcsift. Inspected the running iPhone 18 Pro Max in landscape at 1:3 Extra rich: the complete ratio, name, description, proportion bar, percentages, endpoint, indicators, and primary action are visible. [Verified landscape screenshot](daily-ritual-landscape-fixed.png). No tests were added for this visual layout change.
