# serhii-internal

A Roblox script executor UI built in Luau. Catppuccin Mocha themed, multi-tab editor with file I/O, a custom script menu, and a runtime API.

## Features

- **Multi-tab editor** with line numbers
- **File management** — open and save scripts to `serhii-internal/`
- **Quick Script menu** — register scripts at runtime with `addScript()`, saved automatically
- **Notifications** — toast notifications for actions
- **Draggable, minimizable window** — persists through respawns and teleports
- **Catppuccin Mocha** color scheme
- **Confirmation dialogs** for destructive actions (clear, close)

## Usage

Execute the script in your executor. The UI will appear in the center of your screen.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderSerg/serhii-internal/refs/heads/main/internal.luau", false))()
```

## Quick Scripts

Scripts registered with `addScript()` are saved to `serhii-internal/scripts.json` and persist across sessions. No need to put them in autoexec — they'll be there next time you inject.

```lua
addScript("Speed", "game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100")
addScript("Rejoin", "game:GetService('TeleportService'):Teleport(game.PlaceId)")
```

Use `removeScript("Name")` to delete one, or `listScripts()` to see what's registered.

## API

See the wiki for the full API reference.

## File Structure

```
serhii-internal/     <- saved scripts (auto-created)
  scripts.json       <- persisted quick scripts
```

## License

do whatever you want with it, its open source for a reason
