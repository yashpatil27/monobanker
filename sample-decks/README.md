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
    "Card text 1",
    "Card text 2"
  ]
}
```

Both `name` and `cards` are required. `cards` must be an array of strings.

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
