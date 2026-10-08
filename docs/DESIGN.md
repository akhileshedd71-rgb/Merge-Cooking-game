# Little World Kitchen: first playable design

The mood is a sunny neighborhood café: warm cream, botanical green, clay red, soft gold, rounded food illustrations, spacious controls, and a quiet sense of travel. The source-game references inform the genre's interactions. This game's name, visual composition, art, and dialogue are its own.

## Loop

`Generate → Merge → Cook → Serve → Renovate → Travel`

The board uses seven columns and nine rows so all 63 cells fit a portrait phone. Two matching ingredients move along a linear chain; unmatched movable items swap. A successful merge clears orthogonally adjacent dusty cells. Three fixed generators supply fruit, vegetables, and pantry goods for one energy each. Energy recovers to 100, one point every 45 seconds. Ten off-board storage slots provide breathing room.

Seven appliances turn suitable ingredients into nine dishes. Cooking timers are intentionally short (8–18 seconds) for this first playable version. A boost removes five seconds; completed food waits until the player has room to collect it. Orders reward coins, stars, and experience. There is no failure clock.

Each café has three renovation steps—floor, tables, and decor—with sage, sunshine, and rose style choices. Completing its renovations unlocks the next city: New York, Bangkok, Tokyo, and Paris. All cities share the underlying board and recipe system, with their own story and renovation state. This keeps the first version focused on a complete progression loop.

## Deliberate first-version boundaries

- One board and a compact set of ingredient chains; more content can be added to `KitchenState` data.
- Local saves only; no backend or cross-device synchronization.
- Daily rewards and decorative currency, without purchases or advertisements.
- Short narrative introductions; no branching dialogue or live events.
- Touch and mouse interactions; dedicated controller and screen-reader interfaces remain future work.

The next production milestones are native-device playtesting, economy tuning, deeper city-specific recipes and art, accessibility, localization, and reliable save migrations before monetization is considered.
