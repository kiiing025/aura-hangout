# Studio Setup

This project is designed for Roblox Studio plus Rojo. Codex edits the Luau files in this repo. Rojo syncs those files into Roblox Studio.

## Install Rojo

Follow the official Rojo installation guide:

https://rojo.space/docs/v7/getting-started/installation/

Install both:

- Rojo command line tool
- Rojo Roblox Studio plugin

## Start The Rojo Server

From this project folder, run:

```powershell
rojo serve default.project.json
```

Keep that terminal open while working in Roblox Studio.

## Connect Roblox Studio

1. Open Roblox Studio.
2. Create a new Baseplate place.
3. Open the Rojo plugin.
4. Connect the plugin to the running Rojo server.
5. Confirm these folders/scripts appear:
   - `Workspace.SunsetIsland`
   - `ReplicatedStorage.Shared.AuraDefinitions`
   - `ServerScriptService.Server`
   - `StarterPlayer.StarterPlayerScripts.Client.AuraHud`

## Enable DataStore Testing

Saving uses Roblox DataStores. In Studio:

1. Open Game Settings.
2. Open Security.
3. Enable Studio Access to API Services.
4. Publish the place once before relying on DataStore saves.

If DataStore loading fails during early testing, the server uses a safe default profile for that session.

## Expected World Objects

After Rojo syncs, the editable place should include:

- `Workspace.SunsetIsland`
- `Workspace.SunsetIsland.FloatingGrassIsland`
- `Workspace.SunsetIsland.AuraZone`
- `Workspace.SunsetIsland.SpawnLocation`

The server reuses those objects when Play starts. The important object for point earning is `AuraZone`.
