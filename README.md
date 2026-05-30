# serhii-internal

A Roblox script executor UI built in Luau. Catppuccin Mocha themed, multi-tab editor with file I/O, a custom script menu, and a runtime API.

## Features

- **Multi-tab editor** with line numbers
- **File management** — open and save scripts to `serhii-internal/`
- **Quick Script menu** — register scripts at runtime with `addScript()`
- **Notifications** — toast notifications for actions
- **Draggable, minimizable window** — persists through respawns and teleports
- **Catppuccin Mocha** color scheme
- **Confirmation dialogs** for destructive actions (clear, close)

## Usage

Execute the script in your executor. The UI will appear in the center of your screen.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/CoderSerg/serhii-internal/refs/heads/main/internal.lua", false))()
```

### Autoexec

Drop a `.lua` file in your executor's `autoexec/` folder to pre-load scripts into the menu:

```lua
addScript("Speed", "game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100")
addScript("Rejoin", "game:GetService('TeleportService'):Teleport(game.PlaceId)")
```

## API

See the wiki for the full API reference.

## File Structure

```
serhii-internal/     <- saved scripts (auto-created)
```

## License

do whatever you want with it, its open source for a reason
