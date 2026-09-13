# CLAUDE.md — OneAndDone Breath

Operating instructions for Claude Code working in this repo. Read this first, every session. `README.md` is the product overview and the research rationale. This file is *how we build*.

---

## What we're building

A Flutter breathing app offering three evidence-based techniques (box breathing, 4-7-8, coherent breathing), sold as a single paid download — no subscription, no account, no cloud, and no in-app purchase either (see golden rule 1). Context-aware presets (before a meeting / wind down / reset focus) map to a sensible technique + duration; the user can always override both.

**Positioning (keep all copy consistent with this):** the anti-subscription breathing app. Lead on **"pay once, breathe forever"** — never on feature count or content-library size. There is no code path anywhere that gates a technique behind a second purchase, because the entire pitch is that there is only one purchase.

---

## Golden rules (do not break these)

1. **Sold as a paid app. Never a subscription, never an in-app purchase.** The one-time price is set in App Store Connect and paid once, at download — that transaction is the entire monetisation model. Do not add the `in_app_purchase` package, a paywall screen, a "premium techniques" upsell, or any in-app purchase of any kind: doing so would mean re-litigating a decision this file has already made, not extending it. If that decision is ever deliberately revisited (e.g. switching to free-with-unlock for discoverability), it needs an explicit note here first, not code that quietly assumes it.
2. **A fixed, small set of techniques.** V1 ships exactly three (box, 4-7-8, coherent). Do not add a "browse more techniques" library or turn this into a content app — see README → Roadmap for what's deliberately deferred and why.
3. **Context presets are honest, not fake AI.** `ContextPreset` is a static, hand-picked mapping — never dress this up as personalisation, machine learning, or adaptive difficulty. If real usage data ever justifies more presets, add them explicitly; don't infer them.
4. **Offline-first. Zero network calls, ever.** Every feature — picking a technique, running a session, the presets — must work permanently in airplane mode. There is no future "sync" feature planned; don't leave seams for one.
5. **No account, no backend, no analytics, no ad SDKs.** Nothing about a session is persisted or transmitted anywhere. The App Store / Play Store privacy label must be able to say **Data Not Collected**.
6. **The phase label is never animation-only.** Every phase (inhale/hold/exhale) is always shown as plain text alongside whatever animation is playing — colour or motion is never the only signal (accessibility; also protects the app when the Lottie asset is missing and the fallback circle is showing instead).
7. **No real Lottie assets ship with this scaffold — that's expected, not a bug.** `assets/animations/` is empty. `BreathingAnimation` degrades gracefully to a plain Flutter-drawn circle via `errorBuilder` when an asset fails to load, so the app is fully functional before real animations exist. Sourcing/commissioning `inhale.json`, `hold.json`, and `exhale.json` is separate, explicit work — do not fabricate placeholder JSON or claim this is done until real compositions are in `assets/animations/` and load without hitting the fallback.
8. **There is no purchase-status object in this codebase, and that's deliberate.** An earlier draft of this scaffold had a `PurchaseStatus`/`ProStatus`-style entitlement class (matching the pattern used in Ballast, QuietCheck, StorageSense); it was removed once the monetisation model was settled as a paid app rather than free-with-unlock, because there is no feature to gate. Do not re-add one "to match the other apps' pattern" — that pattern exists specifically for apps with a free tier, which this isn't.
9. **No social features.** No leaderboards, no streaks, no sharing, no accountability partners — the category's own users cite this kind of feature creep as a reason to leave. If a future idea wants this, it's a different app.
10. **No guilt-based or hype-y copy.** Calm, plain language throughout — "Breathe in" / "Hold" / "Breathe out," not "Crush your goals" or "Don't break your streak" (there is no streak).

---

## Stack & platform

- **Flutter + Dart**, matching the existing Flutter project's conventions (plain `ChangeNotifier`, no Provider/Riverpod/Bloc, Material 3 via `ColorScheme.fromSeed`).
- **Lottie** (`lottie: ^3.5.1`) for the breathing-phase animations — see golden rule 7 for what's not included yet.
- No backend, no third-party state management, no `in_app_purchase` package (golden rule 8) — the app is sold as a paid download, not a free app with an unlock.
- iOS-first, matching the rest of the portfolio; Android/web are free later given Flutter's cross-platform base, but not a v1 goal.

---

## Architecture

```
lib/
├── main.dart                       # runApp, MaterialApp, theme (ThemeMode.dark — Night Tide is a dark design)
├── theme/
│   └── app_theme.dart                # "Night Tide" Material 3 theme + NightTide ThemeExtension (aurora/glow tokens)
├── motion/
│   ├── motion.dart                   # shared durations/curves + Motion.reduced(context) for "reduce motion"
│   ├── fade_rise.dart                # staggered fade+rise entrance used on every screen
│   └── tide_route.dart               # fade+settle page transition (no slides)
├── models/
│   ├── breathing_technique.dart        # BreathPhase, BreathPhaseType, the 3 fixed techniques
│   └── context_preset.dart              # the 3 fixed situational presets
├── state/
│   └── session_controller.dart           # ChangeNotifier: phase/timing logic, framework-agnostic (tick(deltaSeconds))
├── screens/
│   ├── home_screen.dart                  # presets (fill the pickers) + technique/length pickers + Begin
│   ├── session_screen.dart                # owns the real Ticker driving SessionController.tick; ring + plain-text phase label
│   └── settings_screen.dart                # sound/haptics toggles, one-purchase statement, privacy statement
└── widgets/
    ├── aurora_background.dart              # slow-drifting aurora blooms behind every screen
    ├── breathing_animation.dart            # Lottie-per-phase; falls back to BreathingRing (golden rule 7)
    ├── breathing_ring.dart                 # CustomPainter ring: disc swells with breath, progress arc, echo rings, glow
    └── glow_button.dart                    # gradient primary / quiet secondary pill

assets/
├── animations/                     # empty until real Lottie compositions exist (golden rule 7)
└── fonts/                          # Geist (OFL) — bundled, never fetched (golden rule 4)

test/
├── session_controller_test.dart    # phase advancement, pause/resume, completion, reset
├── breathing_technique_test.dart    # cycle-length and label sanity checks
├── breathing_ring_test.dart         # breathScale: monotonic, continuous across phase boundaries
└── session_screen_test.dart         # phase label is plain text; pause/resume; completion state

integration_test/screens_test.dart  # Home → Session → Settings on a simulator, screenshots to build/screenshots/
```

- **Visual direction: "Night Tide"** (chosen 13 Sep 2026 from five Pencil directions). Dark-first, `#0D1320` ground, sea-glass accent `#7FD1C4`, aurora blooms, Geist. `ThemeMode.dark` is forced; the light theme exists only so nothing breaks if that's ever revisited.
- **Motion is Flutter-native, not Lottie.** The breathing ring, aurora, entrances and route transition are all drawn/animated in Dart. Lottie remains the per-phase artwork slot (golden rule 7). Every decorative animation checks `Motion.reduced(context)`.

- **`SessionController` never imports Flutter's animation/Ticker APIs.** It exposes `tick(double deltaSeconds)` so it's driven identically by `SessionScreen`'s real `Ticker` or by a plain unit test — mirrors the existing Flutter project's `SimulationController` pattern. Don't fold Ticker logic into the controller.
- **`BreathingAnimation` is the only place a Lottie asset is loaded.** Screens never call `Lottie.asset` directly.
- **No screen references a purchase, entitlement, or "unlocked" concept.** There is nothing to check — see golden rules 1 and 8.

---

## Conventions

- Material 3 throughout; no custom widget library.
- Copy: sentence case, calm, plain language, never jargon or hype (golden rule 10). British spelling ("colour", "organise") — but "color" is fine inside Dart/Flutter API names, obviously.
- Prefer `const` constructors everywhere possible (the models are already fully `const`).
- Tests live in a top-level `test/` mirroring `lib/`'s structure (not co-located), matching the existing Flutter project's convention.

---

## Build order

1. **Run `flutter create --org com.kayode --project-name one_and_done_breath .` in this folder first.** This scaffold ships `pubspec.yaml`, `lib/`, and `test/` only — `flutter create .` on a non-empty directory adds the missing `ios/`/`android/`/etc. platform folders without touching files that already exist, as long as `--overwrite` isn't passed. Do not pass `--overwrite`.
2. `flutter pub get`.
3. Confirm `flutter analyze` is clean and `flutter test` passes against the scaffolded `session_controller_test.dart` and `breathing_technique_test.dart` before adding anything new.
4. Source or commission the three real Lottie compositions (`inhale.json`, `hold.json`, `exhale.json`) into `assets/animations/` — until then, the app runs correctly on the plain-circle fallback (golden rule 7), so this can happen in parallel with everything else.
5. Manual pass on `HomeScreen` → `SessionScreen` → `SettingsScreen` navigation and the pause/resume/reset flow on a real simulator (the countdown and phase timing need to be felt, not just unit-tested).
6. Sound (a soft chime on phase change) and haptics (`HapticFeedback.lightImpact()` on phase change) — currently toggleable in Settings but not yet wired to anything; wire them up.
7. Set the app's price in App Store Connect when submitting — this is a store-listing decision, not a code change (golden rule 1).
8. Accessibility pass — Dynamic Type on all text, VoiceOver labels on the animation region (announce the phase label, not the animation), sufficient contrast in both light and dark themes.

---

## Commands

```bash
# one-time: generates ios/, android/, etc. around the existing lib/ and pubspec.yaml
flutter create --org com.kayode --project-name one_and_done_breath .

# install packages
flutter pub get

# static analysis
flutter analyze

# run unit tests
flutter test

# run on a connected simulator/device
flutter run
```

- This repo was scaffolded and its Dart source written by Claude running in a sandboxed environment with no Flutter/Dart toolchain available, so nothing in it has been run yet — `flutter create` (step 1) is step zero of this session, same principle as `xcodegen generate` on the native side of the portfolio.
- Don't commit `build/`, `.dart_tool/`, or Xcode/Gradle build noise (see `.gitignore`) — but do commit the `ios/`/`android/` platform folders themselves once `flutter create` generates them; they carry real project configuration (bundle ID, signing), not just build output.

---

## Definition of done (v1.0)

- Home → Session → Settings all working offline, on a real device or simulator, not just in theory.
- `flutter test` passes for `session_controller_test.dart` and `breathing_technique_test.dart`.
- Real Lottie animations in place for all three phases (or a deliberate decision recorded here to ship v1 on the fallback circle — either is fine, silence about which one shipped is not).
- Sound and haptics toggles actually do something.
- No `in_app_purchase` dependency, no paywall screen, no purchase/entitlement class anywhere in the codebase — the app's price is an App Store Connect listing decision, not a runtime check (golden rules 1 and 8).
- No analytics, no backend, no account anywhere (grep clean for "login", "sign in", "account").
- Privacy policy URL ready and store privacy label set to Data Not Collected.
- A decision made on the "Name check" question in `README.md` before submission.

## Out of scope for v1 (do not build yet)

A custom technique builder, Apple Watch companion, HealthKit mindful-minutes logging, additional context presets, Android/web release (the code is cross-platform by construction, but v1 ships iOS-first to match the rest of the portfolio). These are roadmap items (`README.md` → Roadmap) — leave clean seams for them, don't implement.
