# Executor API

## Global Functions

### `addScript(name, code)`

Registers a script to the Scripts dropdown menu.

```lua
addScript("Speed", "game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100")
```

### `removeScript(name)`

Removes a registered script by name. Returns `true` if found, `false` otherwise.

```lua
removeScript("Speed")
```

### `listScripts()`

Returns an array of all registered script names.

```lua
local scripts = listScripts()
for _, name in scripts do
    print(name)
end
```

---

## `executor` Table

### Tabs

#### `executor.addTab(name, content)`

Creates a new tab and switches to it. Returns the tab ID.

```lua
local id = executor.addTab("My Script", "print('hello')")
```

#### `executor.closeTab(id)`

Closes a tab by ID. Will not close the last remaining tab. Returns `true`/`false`.

```lua
executor.closeTab(id)
```

#### `executor.getActiveTab()`

Returns a table with the active tab's info, or `nil`.

```lua
local tab = executor.getActiveTab()
print(tab.id, tab.name, tab.content)
```

#### `executor.getTabs()`

Returns an array of all open tabs.

```lua
for _, tab in executor.getTabs() do
    print(tab.id, tab.name)
end
```

#### `executor.switchTab(id)`

Switches the editor to the given tab. Returns `true`/`false`.

#### `executor.renameTab(id, newName)`

Renames a tab. Returns `true`/`false`.

```lua
executor.renameTab(id, "Renamed Script")
```

### Editor

#### `executor.getActiveCode()`

Returns the current editor text as a string.

#### `executor.setActiveCode(code)`

Replaces the current editor text.

```lua
executor.setActiveCode("print('overwritten')")
```

#### `executor.execute(code?)`

Runs the given code via `loadstring`. If `code` is nil, runs the current editor text. Returns `success, err`.

```lua
local ok, err = executor.execute("print('hey')")
if not ok then
    warn(err)
end
```

### Files

#### `executor.openFile(path)`

Reads a file and opens it in a new tab. Returns `true`/`false`.

```lua
executor.openFile("executor_workspace/script.lua")
```

#### `executor.saveFile(path?)`

Saves the active tab to the given path. If no path is provided, saves to `executor_workspace/{tab name}.lua`. Returns `true`/`false`.

```lua
executor.saveFile()
executor.saveFile("executor_workspace/custom_name.lua")
```

### Window

#### `executor.minimize()`

Toggles the minimize state.

#### `executor.isMinimized()`

Returns `true` if the window is currently minimized.

#### `executor.notify(text, color)`

Pushes a toast notification. `color` is a `Color3`.

```lua
executor.notify("Hello!", Color3.fromHex("#a6e3a1"))
```

#### `executor.destroy()`

Destroys the executor UI entirely.

---

## Autoexec

Place a `.lua` file in your executor's `autoexec` folder to register scripts at load time:

```lua
addScript("Speed", "game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100")
addScript("Reset Speed", "game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16")
addScript("Rejoin", "game:GetService('TeleportService'):Teleport(game.PlaceId)")
```

## Workspace

Files are saved to and loaded from `executor_workspace/`. The folder is created automatically on first run.
