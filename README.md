# MonoBanker

**Cash, for the table.**

MonoBanker is a sleek, single-device iOS companion app for board games like Monopoly. It replaces the paper money — track every player's balance and every transaction with a quick drag of a card. Built for game nights, not for accountants.

---

## Why MonoBanker?

Counting paper bills, finding change, arguing about who paid what — it slows the game down. MonoBanker keeps the table moving:

- **One device** sits in the middle and acts as the banker.
- **Drag a card onto another** to pay. That's it. No menus, no forms.
- **Bank** has unlimited funds; **All** splits or collects from everyone at once.
- **Every change is logged**, with one-tap undo if you fat-finger an amount.

---

## Features

### Core gameplay

- **Drag-to-pay** — touch any card and drag it onto another. The dragged card is the payer, the dropped-on card is the recipient. Works instantly (no long-press delay).
- **Live drag preview** — a floating copy of the card follows your finger; valid drop targets light up in pink as you hover.
- **Bank card** — represents the bank, with unlimited funds. Drag a player onto Bank to pay taxes/fees; drag Bank onto a player when they pass GO.
- **All card** — drag a player onto All to split a payment evenly between everyone else; drag All onto a player to collect from everyone else. Bank and All can't interact (it doesn't make sense).
- **POS-style numpad** — once a drop happens, a clean numeric pad slides up to enter the amount. Confirm is disabled if the payer can't afford it (with a shake and warning haptic if you tap anyway).
- **Last-change indicator** — every player card shows the signed delta of their last transaction (`+$50` green, `-$30` red, `$0` muted), so the table can instantly see who paid what.

### Roster management

- **Adaptive grid** — 2 columns up to 6 players, 3 columns above that, so every card stays visible without scrolling.
- **Rearrange mode** — tap the rearrange button (the grid icon in the side column) and the player cards start wobbling, iOS-home-screen style:
  - **Drag** any card to reorder. Other cards shift smoothly to make room.
  - **Tap the X** on any card to remove that player. Their historical transactions stay in the log.
  - **Add another player** mid-game from the same toolbar.
  - **Tap Done** (the pink checkmark) when you're happy with the new layout.
- **Bank and All** never wobble — they stay in their fixed top-row slot.

### Transaction tracking

- **Recent strip** at the bottom of the game view shows the last couple of transactions inline.
- **Full history sheet** — tap the strip (or open History from the menu) for a reverse-chronological list with relative timestamps and the full sequence of every payment.
- **Undo Last** — one tap reverses the most recent transaction. Works for direct payments, split-pay, and collect-from-all.
- **Restart** — reset every player to the starting balance and clear the transaction log without losing the roster.
- **End Game** — wipe everything and return to the launch screen.

### Optional features

- **Dice card** — turn on in Settings → Game Defaults to add a tappable two-die roller right beside the Bank card. Tap to roll two dice (1–6 each), with a bouncy SF Symbol animation every time, even if you roll the same number twice.
- **Default players** — save up to 8 names and colors that automatically pre-fill the New Game screen, so you never type the same names again.
- **Default starting balance** — set your usual buy-in once (Monopoly's classic $1500, your own $5000 cash-game, whatever).
- **Haptic feedback toggle** — turn off vibration if you find it distracting.
- **Game state persistence** — kill the app mid-game, come back hours or days later, and the game picks up exactly where you left it (balances, transaction log, player order, everything). Tap **Continue Game** on the launch screen.

### Support

- **In-app tipping** — there's a small Support Development page with three optional tip tiers, processed securely through Apple's In-App Purchase system. Tips unlock nothing — they just help me keep building. Tip in your local currency; Apple handles the conversion.
- **How to use** — an in-app guide walks through every interaction in 7 numbered steps.
- **About** — version number, credits.

---

## Privacy, data, and pricing

**This is the section that matters most:**

- 🔒 **Completely local.** No accounts, no logins, no servers, no cloud sync. Every byte of your game data lives in your phone's local storage (`UserDefaults`).
- 📵 **Zero data collection.** No analytics SDKs. No crash reporters. No tracking pixels. No telemetry of any kind. The app doesn't know who you are and never asks.
- 🚫 **No ads.** Not now. Not ever.
- 💸 **Free to use.** Every feature is unlocked from install. The optional tip jar is exactly that — optional — and the app behaves identically whether you tip or not.

The only network call the app can possibly make is the in-app-purchase flow when (and only when) you actively tap a tip option, which is handled entirely by Apple's StoreKit. Even then, no purchase data is ever sent to me — Apple processes everything and pays out monthly in aggregate.

---

## How to play, in 30 seconds

1. Open the app, tap **New Game**, add your players (name + color), set the starting balance, tap **Start**.
2. To pay someone: drag your card onto theirs. Enter the amount on the numpad. Confirm.
3. To pay/collect from everyone: drag your card onto **All** (or vice versa). Enter the per-player amount.
4. To rearrange or remove players, tap the grid button in the side column.
5. To see history or undo, tap the recent strip at the bottom.
6. Tap the **☰** in the side column for End Game / Restart / View History.

---

## Tech stack

- **Swift 5.9+** and **SwiftUI**, iOS 17+ minimum.
- **Observation framework** (`@Observable`) for app state and game session.
- **StoreKit 2** for the optional tip jar (consumable IAPs).
- **No third-party dependencies.** Standard Apple frameworks only.
- **Project generated with [xcodegen](https://github.com/yonaskolb/XcodeGen)** — see `project.yml` for the source of truth.

### File layout

```
MonoBanker/
├── MonoBankerApp.swift          # @main, environment wiring
├── Design/                      # Color tokens, design system, button styles
├── Models/                      # GameSession, Player, Transaction, AppSettings, etc.
├── Views/
│   ├── LaunchView.swift
│   ├── RootView.swift
│   ├── Setup/                   # New game player editor
│   ├── Game/                    # Game grid, drag/drop, dice card
│   ├── Transaction/             # Numpad + payment overlay
│   ├── History/                 # Transaction list sheet
│   ├── Menu/                    # Menu and Add Player sheets
│   └── Settings/                # Settings, defaults, How to Use, About, Support
└── Assets.xcassets              # App icon, accent color
```

---

## Building from source

1. Install [xcodegen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
2. Clone this repo and `cd` into it.
3. Run `xcodegen generate` to produce `MonoBanker.xcodeproj`.
4. Open `MonoBanker.xcodeproj` in Xcode 15+.
5. ⌘R to build & run on the simulator or your device.

For local tip-jar testing the bundled `MonoBanker/MonoBanker.storekit` config is already wired into the run scheme — tipping in the simulator will use the local Apple sandbox.

---

## Roadmap ideas

These aren't promises — just what's on the back of the napkin:

- Sound effects toggle.
- Light theme variant.
- A few more die faces / dice count options.
- Currency symbol setting (`$`, `£`, `€`, `₹`, …).

---

## License

This is a personal project. The source is published for transparency and educational reasons. If you want to use parts of it, drop a credit and we're good.

---

Built with care for game nights that should be about the game, not the bookkeeping.
