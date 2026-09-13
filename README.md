# OneAndDone Breath

**A breathing app you buy once and own — no subscription, ever.**
Three well-established breathing techniques (box breathing, 4-7-8, coherent breathing), a calm full-screen guide, and sensible presets for the situations people actually reach for a breathing app in — before a meeting, winding down, resetting focus. That's the whole app.

---

## Why this exists

This came out of the wider iOS market-research pass on 10 breakout indie apps (see `iOS_App_Market_Research_Report.docx` in the Output folder), specifically the Yogi Breath (breathwork) research. The category's own market-gap analysis names subscription fatigue and paywall bait-and-switch as the single biggest reason people abandon a breathing app — more than narration quality, more than missing features. Nobody in the category has taken the position of simply refusing to have a subscription at all. That refusal is the entire product.

### The wedge

- **One purchase, nothing else.** No subscription, no account, no login. Buy it once, use every technique forever.
- **A few good techniques, not an ever-growing library.** Three evidence-based patterns, chosen deliberately — this app will never turn into a bloated content catalogue to justify a recurring price.
- **Context-aware without pretending to be AI.** Three honest presets (before a meeting / wind down / reset focus) map to a sensible technique and duration — a plain answer to the category's "same session regardless of context" complaint, not a fake personalisation engine.
- **No social layer.** No leaderboards, no streaks, no sharing — breathing isn't competitive, and the category's own users say so.

### Positioning

- **Headline:** *"Pay once. Breathe as often as you want, forever."*
- **Moat:** the entire pricing model is the differentiator. Any competitor could copy the techniques; copying the promise of "no subscription, ever" means giving up their own recurring revenue.
- **Target buyer:** someone who's tried Headspace or Calm, found the subscription grating for something this simple, and wants three techniques that work, not a content library they'll never finish.

### Name check (before submission)

"OneAndDone Breath" isn't taken outright on the App Store, but the breathing-app space already has "onebreath" and "One Deep Breath" as existing competitors, and there's an unrelated "One & Done" app/brand on Instagram and Google Play. Worth a deliberate decision before submitting rather than an accident — either keep it (it's not a direct collision) or pick something that doesn't share the "One ___" pattern with existing breathing apps. Not blocking the build either way.

---

## Features (v1)

- **Three techniques** — box breathing (4-4-4-4), 4-7-8, and coherent breathing (5.5 in / 5.5 out) — each with a plain-language description, no jargon.
- **Three context presets** — Before a meeting, Wind down, Reset focus — each a sensible technique + duration default; always overridable.
- **A full-screen breathing guide** — a Lottie animation per phase (inhale/hold/exhale), always paired with a plain-text phase label and countdown, never animation-only.
- **Session lengths** — 1, 3, 5, or 10 minutes.
- **Pause/resume**, and a calm completion screen — no streak, no score, no share prompt.
- **No account, no cloud, no subscription.**

## Screens

| Screen | Purpose |
|---|---|
| **Home** | Context presets, technique + duration picker, Begin. |
| **Session** | Full-screen breathing animation, phase label, countdown, pause/resume. |
| **Settings** | Sound/haptics toggles, purchase status, privacy statement. |

## Tech stack (and why)

- **Flutter + Dart**, matching your existing Flutter portfolio convention (see the `Flutter` project in this same folder) — plain `ChangeNotifier` controllers, no external state-management package, Material 3 via `ColorScheme.fromSeed`.
- **Lottie** — the breathing-phase animations, as requested. **Important:** no actual `.json` animation files ship with this scaffold — `assets/animations/` is empty. `BreathingAnimation` (in `lib/widgets/`) tries to load `inhale.json` / `hold.json` / `exhale.json` and falls back to a plain scaling circle built from stock Flutter widgets if a file is missing, so the app is fully usable today. Sourcing or commissioning the real Lottie compositions (LottieFiles.com has both free and paid breathing/circle animations, or a designer could build custom ones) is separate, trackable work — see `CLAUDE.md`.
- No third-party state or backend packages. No `in_app_purchase` package either — the app is sold as a paid download, not gated by an in-app purchase — see Monetisation below.

## Offline behaviour

Zero network requests. Every feature works permanently in airplane mode.

## Data model

- `BreathingTechnique` — a fixed set of three (box, 4-7-8, coherent), each a list of timed phases. Not user-editable in v1 — see Roadmap.
- `ContextPreset` — maps a situation to a technique + duration. Static, not learned or personalised.
- No persistence at all in v1 — there's nothing to save. A session starts fresh every time; nothing about past sessions is tracked, which is itself part of the no-data-collection pitch.

## Monetisation

**OneAndDone Breath is sold as a paid app, not a free download with an in-app purchase.** The one-time price (TBD) is set once in App Store Connect, at submission — that single App Store transaction *is* the purchase. This is deliberately not an in-app-unlock model: there's no `in_app_purchase` package, no paywall screen, no purchase stream to listen to, and no "restore purchases" button to build, because Apple already handles all of that at the store level for a paid app (re-downloads, family sharing if enabled, and account transfers all just work, the same way they do for any paid app). There is nothing in this codebase that gates a feature behind a purchase, because there's no feature-gating decision to make — either someone has the app or they don't.

If this ever needs to change (e.g. switching to free-with-IAP for better discoverability), that's a real architectural decision to make deliberately, not a default — see `CLAUDE.md`, golden rule 1.

## Roadmap (not v1)

- A custom technique builder (user-defined phase timings) — deliberately deferred so v1 stays "a few good techniques," not a power-user tool.
- Apple Watch companion for a fully screen-off session.
- Optional HealthKit mindful-minutes logging.
- Additional context presets, if real usage shows a gap the current three don't cover.

## Compliance / privacy

- No analytics, no ad SDKs, no tracking of any kind.
- No account, no login, no cloud — nothing to collect.
- App Store privacy label target: **Data Not Collected.**

## Research basis

OneAndDone Breath is Yogi Breath Idea #7 ("OneAndDone Breath") from the accompanying research report — chosen because it answers the category's #1 named defection trigger (subscription fatigue and paywall bait-and-switch) head-on, with the simplest build in the entire 100-idea pool: no APIs, no entitlements, no backend.

## Build notes

This project is being built directly in Claude Code, in `Claude Code projects/OneAndDoneBreath`. `CLAUDE.md` in this folder carries the full operating instructions (golden rules, architecture, build order, commands) — read that first, every session. **Step 1 in the build order matters:** this scaffold ships `pubspec.yaml`, `lib/`, and `test/` only — running `flutter create --org com.kayode --project-name one_and_done_breath .` in this folder is what generates the `ios/`/`android/` platform folders around them, safely, without touching the files already here.
