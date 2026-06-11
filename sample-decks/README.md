# Sample Decks

These JSON files are **not** bundled with the MonoBanker app. They live outside
the Xcode source tree so the app binary stays free of preset card content. Use
them as starter decks that you (or anyone else) can import via the in-app
**Settings → Card Decks → Import JSON** button on any deck row.

## Format

Each file is a single deck:

```json
{
  "name": "Deck name shown in the app",
  "cards": [
    "Plain card text",
    { "text": "A card that players can hold", "ownable": true }
  ]
}
```

Both `name` and `cards` are required. Each item in `cards` is either:

- a plain string (a normal card that is discarded after being drawn), or
- an object `{ "text": "...", "ownable": true }` (a card that is held by
  the player after being drawn instead of discarded).

Ownable cards land in the deck's Held pile when drawn and stay out of
the shuffle until the player taps **Return** in the in-game Held Cards
sheet. Use it for things like a Get Out of Jail Free card.

Omitted `ownable` defaults to `false`.

## Importing into the app

1. Save the `.json` file somewhere iOS Files can reach (iCloud Drive, On My
   iPhone, AirDrop, Mail attachment, etc.).
2. Open MonoBanker → **Settings → Edit Card Decks**.
3. Tap **Import JSON** on the deck row you want to populate.
4. Pick the file. The deck's name and cards are replaced, and its draw pile
   resets so the next draw shuffles the new contents.

## Files in this folder

- `chance.json` — the 16-card Monopoly UK Chance deck (verbatim text)
- `community-chest.json` — the 16-card Monopoly UK Community Chest deck
  (verbatim text)

These two files contain text from Hasbro's Monopoly UK and are provided here
for personal use only. Don't redistribute them in a way that competes with or
markets against Hasbro's products.
