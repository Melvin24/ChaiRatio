# Indicators, landscape paging, and soft scroll edges

Implemented: 18 October 2026, following the product owner's feedback on the adaptive layout.

## Changes

- Replaced the visible ratio-choice labels and heading with five tappable indicators. The selected indicator is an elongated capsule; others are dots. Shape communicates selection in addition to color. Every indicator retains a 44 × 44 point target, its ratio/name accessibility label, and selected trait.
- Restored native horizontal paging at every screen size and text size. The prior constrained layout displayed only the selected ratio and therefore lost swipe navigation in landscape.
- Short windows and larger text keep each horizontal page's content, indicators, and primary action together in a vertical scroll view. Horizontal gestures change ratios; vertical gestures read the page. Roomy layouts keep the controls below the carousel.
- Selected-ratio persistence still commits only after a user scroll settles. The pager retains its identity across rotation and navigation instead of being recreated, which could show the first page despite retaining a different selected ID. Page widths match the available geometry; centered, view-aligned snapping accounts for landscape safe areas and limits each gesture to one page. Offscreen pages are hidden from accessibility; only the selected page's ratio summary accepts keyboard focus.
- Set `.scrollEdgeEffectStyle(.soft, for: .top)` on ratio scrolling views, Calculator, and Measurements. The installed SDK confirms availability from iOS 26, matching the deployment target.

## Verification

- The app builds with zero warnings and errors through xcsift.
- iPhone 17e / iOS 27: the targeted UI scenario passed with zero warnings/errors. Verified portrait swipe and indicator tap; the selected hero visibly remains on screen after rotation; landscape swipes commit Balanced → Rich → Balanced; indicator tap selects Extra rich; vertical scrolling reaches the primary action; Calculator/Back preserves selection; returning to portrait retains it.
- Accessibility 5 on iPhone: swiping changes the selected ratio, indicators remain tappable after scrolling, and the primary action opens Calculator with the chosen ratio.
- iPad mini / iOS 27: the same complete interaction scenario passed with zero warnings/errors, including both landscape swipe directions, visible selection after rotation, indicator taps, Calculator/Back, and Accessibility 5 swiping and navigation.
- Inspected the portrait, landscape, scrolled footer, and largest-text screenshots. Pages are centered without adjacent-page peeking, and controls remain reachable. Subsequent user feedback identified a sharp cutoff at the navigation bar that the original visual review missed; see the correction below.
- Verification uses a temporary XCUITest harness outside the project; no testing targets or hooks were added to the app.

Evidence:

- [Portrait indicators](indicator-iphone-portrait-initial.png)
- [Selected page after rotation](indicator-iphone-landscape-balanced.png)
- [Landscape swipe](indicator-iphone-landscape-swiped-rich.png)
- [Scrolled footer and soft top edge](indicator-iphone-landscape-footer.png)
- [Largest text footer](indicator-iphone-accessibility5-footer.png)
- [iPad landscape swipe](indicator-ipad-landscape-swiped-rich.png)

Physical devices, OS 26 runtimes, narrow iPad windows, and actual VoiceOver speech remain unverified.

## Navigation-bar clipping correction — 18 October 2026

The horizontal pager's rectangular `.clipped()` modifier also clipped vertical content at the pager bounds, producing an abrupt edge beneath the navigation bar even with `.soft` configured. The earlier visual review did not adequately check text crossing that boundary.

The horizontal pager now disables its default scroll clipping and uses a custom clip that keeps the horizontal bounds while extending vertically through the surrounding safe areas. Each inner vertical scroll view retains native clipping and its soft top scroll-edge style. This preserves page alignment and hides neighboring pages while allowing the system's navigation-bar fade to render over scrolled content. This follows Apple's documented support for [custom clipping after disabling default scroll clipping](https://developer.apple.com/documentation/swiftui/view/scrollclipdisabled(_:)).

The app builds with zero warnings/errors. Targeted before/after visual verification is in progress.
