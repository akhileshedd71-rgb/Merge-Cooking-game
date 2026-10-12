# Little World Kitchen 0.2 — the flavor journey

The game combines a portrait merge board with a relaxed cooking and restaurant loop:

`Generate → Merge → Cook → Serve → Renovate → Travel`

## Food and travel

There are **30 ingredients in five six-tier chains** and **32 cooked dishes**. The original orchard, garden, and pantry suppliers remain on the board. The fish market opens at chef level 3, and the patisserie opens at level 5; both are available through the market opened by tapping the coin counter. All suppliers use energy. Higher ingredients come from merging, never from purchases.

The catalog lives in `scripts/catalog.gd`. Each recipe identifies an input, an optional second ingredient, a station, cooking time, and minimum chef level. All ingredients are consumed together only when the complete recipe can start. Original recipes remain available at level 1. The expanded recipes unlock through level 8, and generated orders only ask for unlocked recipes. Timers last 8–26 seconds, with no spoiled food or expiring orders.

New York, Bangkok, Tokyo, Paris, Rome, Mexico City, Istanbul, and Seoul each have a story, a signature dish, a hand-illustrated postcard, and independent restaurant renovation progress. Finishing the three details of a restaurant unlocks the next city. Floor, table, and décor selections retain their individual styles across all 64 visual combinations.

## Progression and economy

Chef levels run from 1 through 20, at 100 XP per level. Merging, cooking, and serving grant XP. The chef portrait opens the level roadmap and ten goals. Each new level has a one-time claim of `25 × level` coins, 10 energy, and a cooking boost. Goals reward coins and renovation stars; claims persist across saves.

Coins now buy 30 energy (120 coins), three cooking boosts (75 coins), or one extra pantry slot (250 coins). The pantry starts with ten slots and expands to twenty. Full energy and full storage capacity reject purchases without spending. An ingredient's detail panel also allows selling it for `2 × tier` coins to free space. Generators cannot be sold. No payment, ad, premium currency purchase, or external service is involved.

## Guided first session

Lea's six-step tutorial advances from real gameplay actions: generate, merge, start a recipe, collect it, serve a guest, and renovate. It highlights useful tiles and supplies a contextual “Show me” action. The player can skip or replay it from Guide & settings. It resumes after closing the game, including active cooking jobs. The first completion grants 50 coins, one star, and ten energy; replay never repeats the reward. Returning version-1 players continue without an interrupting welcome screen.

## Interaction and feedback

- Tap matching ingredients to merge, or tap an empty tile to move. Tapping a different ingredient changes selection; dragging still supports swaps.
- Hint highlights an available pair. The detail panel shows the next merge result and cooking/storage/sale choices.
- Cooking-ready badges appear on the Cook tab even while exploring another screen.
- The notebook filters all, ready-to-cook, and unlocked recipes, and shows all ingredient chains.
- Pantry, recipe, goal, and travel screens preserve their scroll position.
- Merge pops, sparkles, soft synthesized sounds, and short screen fades supply feedback. Sound and gentle-motion preferences persist.
- Notifications stay above the play area. Touch devices do not show desktop hover tooltips.

## Persistence and boundaries

Save schema 2 migrates schema 1 while preserving the board, storage, resources, active orders, jobs, discoveries, and restaurant styles. Newly added destinations and progression fields receive defaults. Unknown versions and malformed saves are rejected without mutating the currently loaded state. Tests include an actual version-1 fixture produced by the original Git revision.

This remains a local, offline game. Cloud synchronization, native iOS export, app-store signing, physical-device performance tests, and monetization are outside this version.
