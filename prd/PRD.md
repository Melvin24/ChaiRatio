# ChaiRatio: Product Requirements Document

**Status:** Draft  
**Platform:** iOS  
**Product type:** Offline-first chai recipe calculator and guide

## 1. Product Summary

ChaiRatio helps people make Indian chai for a chosen number of servings without doing ratio math themselves. A user chooses a water-to-milk ratio and serving count; the app converts the recipe into clear water and milk amounts, with optional tea and sugar quantities. It also offers a small set of guided chai methods and explains the measuring units used.

The first screen makes the ratio choices the main experience: users move vertically through a finite set of ratios, see the chai color shift with the milk proportion, and can start calculating with the selected ratio.

## 2. Problem and Opportunity

People often make chai by habit or by eye. When serving more or fewer people, it can be hard to scale water, milk, tea, and sugar consistently. Household terms such as “cup,” “glass,” and “spoon” can also mean different amounts to different people.

ChaiRatio should make the quantities understandable and repeatable while leaving room for personal taste. It is a cooking aid, not a claim that there is one universally correct chai recipe.

## 3. Goals and Success Measures

### Goals

- Let a user choose a ratio and serving count and immediately see scaled ingredient amounts.
- Make the water-to-milk ratio and all measurement assumptions explicit.
- Let users adjust serving size, ratio, tea strength, and sweetness without losing the simple default flow.
- Preserve the selected ratio between launches.
- Provide at least three useful, distinct chai preparation guides.
- Work without an account or network connection.

### Success measures

- **Task completion:** percentage of first-time users who reach a usable ingredient result.
- **Time to result:** median time from launch to a displayed recipe.
- **Calculator engagement:** users who change servings or ratio and view the updated result.
- **Recipe engagement:** users who open and complete a preparation guide.
- **Return use:** users who reopen the calculator on a later day.

The first release should establish baseline measurements before setting numeric targets. Any analytics must be privacy-conscious and disclosed in the App Store privacy details.

## 4. Target Users and Core Jobs

- **Everyday chai maker:** “Scale the chai I already like to the number of people here.”
- **New chai maker:** “Give me a clear starting recipe and tell me what the measurements mean.”
- **Experimenter:** “Show me a few water-to-milk balances so I can find my preference.”

## 5. Product Principles

- Keep the answer prominent: water and milk amounts should be immediately scannable.
- Use ratio labels and ingredient names in addition to visual color; color must never be the only signal.
- Show exact metric volumes alongside familiar glass or spoon equivalents.
- Treat presets as starting points and let users change them freely.
- Separate serving volume from utensil volume so “one cup of chai” is not confused with “one glass of water.”

## 6. Scope

### MVP

- Ratio selection home screen with a finite, content-managed set of water:milk ratios.
- Chai-tone background that changes with the milk share of the selected ratio.
- Ratio name, numeric ratio, and short descriptive copy.
- Persistent selected ratio using local app storage (UserDefaults is sufficient).
- Calculator for serving count, serving size, ratio, and optional tea and sugar amounts.
- Results in milliliters, liters when appropriate, 200 mL glass equivalents, and recipe servings.
- Measurement guide defining serving cup, glass, teaspoon, and tablespoon.
- At least three step-by-step chai methods.
- Offline use, VoiceOver labels, Dynamic Type support, and metric-first formatting.

### Not in MVP

- Accounts, cloud sync, social sharing, or community recipes.
- Nutrition, caffeine, health claims, or medical guidance.
- A custom recipe editor or arbitrary ratio entry.
- Shopping lists, timers, voice control, widgets, or Apple Watch support.
- Regional claims that a ratio or method is the single authentic or most popular version.

## 7. Information Architecture

1. **Ratios** (launch and home): select a ratio, review its description, and begin making chai.
2. **Calculator**: choose servings, serving size, ratio, strength, and sweetness; view scaled ingredients.
3. **Methods**: browse and follow at least three preparation guides.
4. **Measurements**: review unit definitions and the assumptions used by the calculator.

Primary navigation may use a compact tab bar for Calculator, Methods, and Measurements, while the ratios screen remains the launch screen. The “Let’s make chai” action opens the calculator with the current ratio preselected.

## 8. Functional Requirements

### 8.1 Ratio selection

- Present one ratio at a time in a vertically paged or snapping scroll interaction.
- Each option includes a numeric water:milk ratio, a concise name, and a brief neutral description.
- Changing the selected ratio updates the background color and ratio-dependent recipe values.
- Include text or another non-color indicator of milk share for accessibility and clarity.
- Persist the selected ratio locally and restore it on next launch.
- If a saved ratio is removed in a future version, fall back to the designated default without blocking launch.

Initial finite preset set (names and descriptions require product review), ordered from tea-forward to milk-forward:

| Water:milk | Working label | Description direction |
|---|---|---|
| 3:1 | Tea-forward | More water relative to milk |
| 2:1 | Light | More water than milk |
| 1:1 | Balanced | Equal parts water and milk |
| 1:2 | Rich | More milk than water |
| 1:3 | Extra rich | A milk-heavy result; simmer carefully |

The ratio set is finite for the first release. These five presets provide a broad range without adjacent near-duplicate choices or special zero-water handling. Copy should describe flavor and texture rather than claim a preset is the most widely used, weak, or the only authentic chai. Identify 3:1 and 1:3 as the ends of the range.

### 8.2 Calculator

- Default to the ratio selected on the home screen.
- Allow the user to change ratio without navigating away.
- Let the user set a whole-number serving count from 1 to 20 using a stepper and direct numeric entry.
- Let the user choose a serving size, with a default of 150 mL and selectable 150, 200, or 250 mL options.
- Display water and milk quantities in mL; show L for larger amounts where useful.
- Show equivalent 200 mL glasses, including fractions to the nearest quarter glass, while retaining mL as the precise value.
- Offer a simple tea strength choice (Mild, Regular, Strong) and sweetness choice (None, Light, Regular, Sweet). These choices adjust tea and sugar only, not water-to-milk ratio.
- Show tea quantity in grams where recipe content has been validated, and show sugar in teaspoons or grams only when its conversion is defined and tested.
- Recalculate immediately when any input changes.
- Keep calculator values stable when moving to another tab and back during the current session. On a new launch, restore the preferred ratio; other calculator inputs may reset to defaults in MVP.

### 8.3 Calculation and rounding

Let:

- `S` = serving count
- `V` = selected serving size in mL
- `R` = recipe yield factor, defined as expected finished chai volume divided by starting liquid volume
- `a:b` = water:milk ratio

Then:

- `target finished volume = S × V`
- `starting liquid volume = target finished volume ÷ R`
- `water = starting liquid volume × a ÷ (a + b)`
- `milk = starting liquid volume × b ÷ (a + b)`
- `glass equivalents = ingredient volume ÷ 200 mL`

For initial calculator presets, `R` should be 1.0 unless kitchen testing establishes a consistent, recipe-specific finished yield. The app must not imply that boiling losses are precisely predicted if they are not. If the recipe uses an empirically validated yield factor, identify it in the recipe content and preserve the requested final serving volume in the calculation.

Calculations use unrounded values internally. Display liquid amounts rounded to the nearest 5 mL below 1 L and nearest 10 mL at or above 1 L. Glass equivalents display to the nearest quarter glass. The displayed units should not imply more precision than the recipe supports.

Example with the default yield factor: 4 servings × 150 mL = 600 mL starting liquid. At 1:1, show 300 mL water and 300 mL milk, or 1.5 glasses of each using the 200 mL glass definition.

### 8.4 Methods and instructions

Include at least three editorially reviewed recipes with ingredient quantities, yield, equipment, preparation steps, and optional variations:

- **Everyday stovetop chai:** tea brewed with water and milk together or in sequence, with a balanced flavor profile.
- **Kadak chai:** stronger tea flavor with a method and tea quantity tested for the intended servings.
- **Ginger and cardamom chai:** a spiced method that explains when to add fresh ginger and cardamom.
- Include a water-first method where tea is brewed in water and the measured milk is added near the end. This is a preparation sequence, not a separate water:milk ratio; the selected ratio still determines the total water and milk amounts.

Each recipe must state its ratio, serving size, preparation time, and whether its yield is measured or estimated. Steps should be numbered, concise, and usable while cooking. Recipe quantities and timings require kitchen testing before release; these examples define content categories, not final culinary authority.

### 8.5 Measurements and definitions

The Measurements page must define:

- **Serving:** the intended finished amount poured for one person; default 150 mL, configurable in the calculator.
- **Glass:** a calculator unit equal to 200 mL. It is an equivalence, not an assumption that every household glass has this capacity.
- **Teaspoon:** 5 mL by volume.
- **Tablespoon:** 15 mL by volume.
- **Grams:** weight, distinct from spoon volume. Spoon-to-gram conversion varies by ingredient and must be recipe-specific.

Do not label a teaspoon as a fixed 10 g. If ingredient amounts are shown in grams, those values must be validated for the specific ingredient and recipe. Explain that personal taste, tea type, stove, vessel, and boiling time can change the result.

## 9. User Flows

### First use

1. User lands on the default ratio with its label and description.
2. User scrolls through ratio options and selects one.
3. User taps “Let’s make chai.”
4. Calculator opens with that ratio, default serving count, and serving size.
5. User adjusts servings or preferences and reads the ingredient amounts.
6. User optionally opens a matching method or the Measurements page.

### Repeat use

1. App opens on the last selected ratio.
2. User taps “Let’s make chai.”
3. User changes the serving count and reads updated quantities.

## 10. UX and Accessibility Requirements

- Ratio typography is visually prominent, but remains responsive to larger accessibility text sizes.
- Vertical scrolling has clear selection feedback and does not trap users in an animation.
- Chai background colors maintain readable foreground contrast in light and dark appearances.
- The selected ratio, milk share, and calculator quantities are available to VoiceOver as text.
- Controls have accessible names, values, and adjustable actions where applicable.
- Support Dynamic Type, Reduce Motion, sufficient contrast, and touch targets of at least 44 × 44 points.
- The calculator result remains readable without relying on color or decorative imagery.
- Use concise, inclusive copy; avoid framing any one ratio as the only authentic chai.

## 11. Data and Technical Requirements

- Native iOS app; use local, structured recipe and ratio data bundled with the app for MVP.
- Store the selected ratio identifier with UserDefaults; no Core Data is needed for one preference.
- Store ratio definitions, labels, descriptions, strength multipliers, and recipe yields as data rather than scattering values across views.
- Keep calculation logic independent from presentation so it can be tested deterministically.
- No login, remote service, or personal data is required for core functionality.
- Preserve preferences across app updates where possible; handle missing or invalid stored values gracefully.

## 12. Analytics and Privacy

If analytics are included, collect only aggregate product events needed to understand the core journey, such as app opened, ratio selected, calculator opened, inputs changed, and method viewed. Do not collect free-form user data or precise location. Provide clear privacy disclosures and an analytics opt-out if the selected analytics framework supports it. The MVP remains useful with analytics disabled or unavailable.

## 13. Edge Cases and Error Handling

- Clamp servings to the supported 1–20 range and prevent empty or malformed numeric entry from producing confusing results.
- Ensure all preset ratio parts are positive and all calculations produce finite, nonnegative ingredient amounts.
- Use a reasonable layout for quantities under one glass and for multi-liter batches.
- If there is not enough room to show all units, retain the mL value and make glass equivalents accessible.
- If recipe-specific tea or sugar values are unavailable for a serving range, show a clear unavailable state rather than extrapolating unvalidated values.
- Make the result update immediately after correcting invalid input.

## 14. Acceptance Criteria

- A user can select each available ratio by vertical scrolling and see a corresponding chai-color change.
- Presets include 3:1, 2:1, 1:1, 1:2, and 1:3, ordered from tea-forward to milk-forward.
- The ratio label and description update with selection, and the selected ratio persists after relaunch.
- “Let’s make chai” opens the calculator with the selected ratio applied.
- Changing serving count, serving size, ratio, strength, or sweetness updates the appropriate ingredient results.
- Water and milk are shown in mL and 200 mL glass equivalents, with ratio math matching the documented formula within display rounding.
- A four-serving, 150 mL, 1:1 calculation at yield factor 1.0 displays 300 mL water and 300 mL milk.
- The Measurements page clearly distinguishes serving volume, 200 mL glass volume, teaspoon volume, tablespoon volume, and ingredient weight.
- At least three complete, reviewed preparation guides are available offline.
- Core screens support VoiceOver, Dynamic Type, and usable contrast without communicating ratio selection by color alone.

## 15. Release Plan

1. **Content and culinary validation:** approve ratio labels, test recipe yields, and validate tea/sugar quantities.
2. **MVP build:** implement ratio selection, persistence, calculator, measurements, and the three guides.
3. **Usability review:** test with new and experienced chai makers, including accessibility checks.
4. **App Store readiness:** prepare screenshots, privacy disclosures, supported device and iOS version policy, and final content review.
5. **Post-launch iteration:** review task completion and user feedback; adjust defaults and copy based on observed use.

## 16. Open Decisions

- Confirm whether all presets use the same yield factor.
- Decide whether 150 mL should remain the default serving size or whether the audience expects a different cup size.
- Kitchen-test the three methods, including the point at which milk is added and how long the tea is boiled.
- Confirm tea and sugar dose tables for strength and sweetness options, including whether both grams and spoon equivalents should be displayed.
- Confirm supported iOS version and whether the first release should localize units or language beyond English and metric.
- Decide whether calculator servings above 20 are needed for family or event batches.
