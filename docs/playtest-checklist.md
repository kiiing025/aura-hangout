# Playtest Checklist

Use Roblox Studio Play mode after syncing with Rojo.

## One-player test

- [ ] Player spawns on Sunset Dream Island.
- [ ] HUD appears with Aura Points, current aura, message, and Roll button.
- [ ] `AuraZone` is visible as a glowing circle.
- [ ] Standing inside the aura zone increases points by the stillness bonus.
- [ ] Moving inside the aura zone pauses or slows point gain.
- [ ] Leaving the aura zone stops point gain.
- [ ] Pressing the manual roll button with fewer than 25 points shows "Not enough points."
- [ ] Pressing the manual roll button with at least 25 points subtracts 25 points.
- [ ] Successful roll shows an aura name and rarity.
- [ ] Successful roll equips a visible aura effect on the character.

## Two-player test

- [ ] Both players have separate Aura Points.
- [ ] Each player can roll independently.
- [ ] One player's aura does not overwrite the other player's aura.
- [ ] Auras are visible to the other player.

## DataStore save test

- [ ] Enable Studio Access to API Services.
- [ ] Publish the place once.
- [ ] Earn points and roll an aura.
- [ ] Stop the session.
- [ ] Start a new session with the same test account.
- [ ] Confirm saved points and equipped aura restore.

## Rarity feel test

- [ ] Roll at least 50 times in a test session with temporary extra points.
- [ ] Common auras appear often.
- [ ] Uncommon auras appear sometimes.
- [ ] Rare, Epic, and Legendary auras feel noticeably harder to get.
