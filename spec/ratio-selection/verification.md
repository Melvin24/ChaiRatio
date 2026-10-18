# Ratio selection implementation and verification

Platform revision, 11 October 2026: the project now supports iPhone and iPad only. Earlier Mac requirements and verification results below are historical. Native macOS, Mac Catalyst, and Designed for iPhone/iPad on Mac are excluded.

Date: 6 October 2026
Status: Implemented and available for review; manual acceptance checks remain pending.
All changes are uncommitted.

## Implemented

- Five structured presets, exact fractions, display percentages, stable IDs, and default resolution.
- Injected shared UserDefaults store with validated writes, current-state replay, and no redundant writes.
- AppRoot dependency assembly, feature coordinators, typed calculator payload, input/output contracts, Combine binding helpers, and per-window ViewModel lifetime.
- Vertical snapping with commits at user-scroll idle, finite previous/next controls, committed-selection navigation, duplicate-push protection, and Back synchronization.
- Temporary calculator content constructed by its coordinator and forwarded through the selector ViewModel.
- Warm light/dark palettes, immediate paging, Reduce Motion-aware background transitions, adjustable accessibility summary, focused arrow keys, and scrollable content at constrained sizes.
- iOS/iPadOS 26 and native macOS 26 minimums; visionOS configuration and starter playground removed. Mac Catalyst is disabled.
- Executable ChaiRatioTests target and shared ChaiRatio scheme.

The calculator is intentionally read-only. It has no unused input protocol or empty binding utility. Each window owns navigation while sharing the application preference store.

## Automated results

Xcode 27.0 (27A266a), macOS 27.0, installed iOS 27.0 simulator runtime. Xcode was invoked by absolute path because the system developer directory points to Command Line Tools; that system setting was not changed.

| Check | Result |
| --- | --- |
| Native Mac build and tests, arm64 | Passed: 13 tests; 0 failures, warnings, or errors |
| iPhone 18 Pro simulator build and tests | Passed: 13 tests; 0 failures, warnings, or errors |
| iPad Pro 13-inch (M5) simulator build | Passed: 0 warnings or errors |
| Git whitespace validation | Passed |

Final build and test output was parsed with xcsift in TOON format. Initial missing Combine imports were corrected before these passing runs.

The tests cover catalog order/uniqueness/positive parts/default/fractions; all saved presets; malformed and removed values; valid writes and no-op writes; late subscribers; settled selection; finite adjacent selection; external store updates without write loops; committed navigation payloads; duplicate pushes; Back and reopening; destination-content forwarding; component lifetime; placeholder resolution; and application restoration.

The contrast test computes WCAG relative luminance from all ten palette colors and checks opaque black/white foregrounds at 4.5:1 or greater. Enabled control borders use the same foregrounds, and the primary button uses black/white at 21:1. Disabled controls are visually dimmed. This is numeric contrast verification, not a visual accessibility audit.

## Reproduce

Run from the repository root. Change simulator destinations to installed devices as necessary. Build products remain outside the repository.

```sh
set -o pipefail
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
  -project ChaiRatio.xcodeproj -scheme ChaiRatio \
  -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath /tmp/ChaiRatioDerivedData \
  CODE_SIGNING_ALLOWED=NO test 2>&1 | xcsift -f toon -w

/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
  -project ChaiRatio.xcodeproj -scheme ChaiRatio \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  -derivedDataPath /tmp/ChaiRatioIOSDerivedData \
  CODE_SIGNING_ALLOWED=NO test 2>&1 | xcsift -f toon -w

/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
  -project ChaiRatio.xcodeproj -scheme ChaiRatio \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)' \
  -derivedDataPath /tmp/ChaiRatioIPadDerivedData \
  CODE_SIGNING_ALLOWED=NO build 2>&1 | xcsift -f toon -w
```

Unit tests create UUID-named preference suites and remove only those suites. They do not modify or clear the developer's actual ratio preference.

## Pending manual acceptance

The Mac application launched successfully, but Computer Use returned “Computer Use permissions are not granted.” No UI interaction or visual result is claimed as verified. The following checks still require a person or an authorized UI session:

- Fresh launch and nondefault relaunch show the correct initial page without flashing the default.
- Slow, cancelled, and rapid multi-page drags commit only at rest; endpoints do not wrap.
- Primary-action taps during dragging open the last committed ratio; Back restores its page; repeated taps do not stack destinations.
- iPhone portrait/landscape, expanded iPad, short Mac windows, and resizing across layout modes preserve selection and readable content.
- Largest Dynamic Type settings keep essential content and controls reachable.
- VoiceOver traversal, selection adjustment, disabled-control announcements, and absence of confusing duplicate focus stops.
- Reduce Motion removes color transitions; light/dark visual appearance and native button focus remain clear.
- Mac focused Up/Down selection and normal arrow-key content scrolling in constrained mode.

The installed runtime is version 27. Minimum deployment targets are 26, but OS 26 runtime/device behavior and signed physical-device builds have not been verified. The spec's acceptance checklist remains unchecked until its full manual verification is completed.
