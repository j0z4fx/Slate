# Slate UI Library — Documentation

Slate is a Roblox executor UI library. It renders entirely inside `CoreGui`, requires no `require()` calls, and ships as a single concatenated file loaded at runtime via `loadstring`.

---

## Installation

Paste this at the top of any executor script. The library is fetched from GitHub and executed in your environment:

```lua
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/j0z4fx/Slate/main/src/Library.luau"
))()
```

`Library` is the top-level API object. Everything else is built from it.

---

## Window & Layout

Slate's window is created automatically when the library loads. There is no separate `CreateWindow` call.

### Tab

The library starts with one default tab (`"Main"`). Access it via:

```lua
local Tab = Library.Tab  -- also available as Library.ActiveTab
```

### GroupBox

GroupBoxes are the panels inside a tab. Add them with:

```lua
local Box = Tab:AddGroupBox(name: string, column?: string)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | `string` | — | Title shown in the groupbox header |
| `column` | `string` | `"Left"` | `"Left"` or `"Right"` |

GroupBoxes can be collapsed, dragged between columns, and destroyed independently.

```lua
Box:SetCollapsed(true)   -- collapse/expand
Box:ToggleCollapsed()
Box:SetPlacement("Right", 2)  -- move to a column at a specific layout order
Box:Destroy()
```

### ViewportBox

A fixed-height GroupBox containing a proper R6 rig (HumanoidRootPart, Motor6D joints, Humanoid) slowly rotating, coloured with the accent colour. No child controls.

```lua
local vp = Tab:AddViewportBox(name: string, column?: string)
-- also: Library:AddViewportBox(name, column)
```

### BodyPartBox

A clickable 2D R6 body-part silhouette. Clicking a region selects that part.

```lua
local bp = Tab:AddBodyPartBox(name: string, column?: string)
-- also: Library:AddBodyPartBox(name, column)
```

| API | Description |
|-----|-------------|
| `bp.Value` | Currently selected part name (default `"Torso"`) |
| `bp.Changed` | Signal — fires with the new part name on selection change |
| `bp:SetPart(name)` | Programmatically select a part |

Part names: `"Head"`, `"Torso"`, `"Left Arm"`, `"Right Arm"`, `"Left Leg"`, `"Right Leg"`, `"HumanoidRootPart"`

---

## Controls

All controls that store state are registered under a unique **option key** (a string). After creation you can look them up globally:

- **Toggles / Checkboxes** → `Library.Toggles.<key>`
- **Everything else** → `Library.Options.<key>`

Every registered control exposes:
- `.Value` — the current value (type depends on control)
- `.Changed` — a signal that fires with the new value whenever it changes
- `:SetValue(v)` — programmatically set the value (runs the same validation as the UI)
- `:RawSet(v)` — set the value without firing `.Changed`
- `:Destroy()` — remove the control and clean up its resources

---

### Toggle

A boolean switch.

```lua
local t = Box:AddToggle(key: string, props: table)
```

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `Text` | string | `""` | Row label |
| `Default` | boolean | `false` | Initial value |
| `Tooltip` | string | — | Hover tooltip |
| `DisabledTooltip` | string | — | Tooltip shown when disabled |
| `Disabled` | boolean | `false` | Greys out and blocks interaction |
| `Visible` | boolean | `true` | Hides the row when false |
| `Risky` | boolean | `false` | Tints the control red |

```lua
t.Changed:Connect(function(value: boolean) end)
t:Toggle()  -- flips current state
```

---

### Checkbox

Identical logic to Toggle; renders as a classic tick-box instead of a slide switch.

```lua
local cb = Box:AddCheckbox(key: string, props: table)
```

Accepts the same props as Toggle.

---

### Button

A clickable action row. Has no persistent `.Value`.

```lua
Box:AddButton(props: table)
```

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `Text` | string | `""` | Button label |
| `Func` | function | — | Called on click (wrapped in `task.spawn(pcall)`) |
| `DoubleClick` | boolean | `false` | Require two clicks to fire `Func` |
| `DoubleClickWindow` | number | `0.35` | Seconds between clicks that count as a double-click |
| `Tooltip` | string | — | Hover tooltip |
| `DisabledTooltip` | string | — | Tooltip shown when disabled |
| `Disabled` | boolean | `false` | Prevents firing |
| `Visible` | boolean | `true` | — |
| `Risky` | boolean | `false` | Tints red |

The returned object exposes an `.OnInvoke` signal and an `:Invoke()` method to trigger the button programmatically.

---

### Slider

A single-thumb numeric slider.

```lua
local s = Box:AddSlider(key: string, props: table)
```

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `Text` | string | `""` | Row label |
| `Min` | number | `0` | Minimum value |
| `Max` | number | `1` | Maximum value |
| `Default` | number | `Min` | Initial value |
| `Rounding` | number | `1` | Snap step (e.g. `0.1` for one decimal place) |
| `Suffix` | string | `""` | Appended to the displayed value |
| `Compact` | boolean | `false` | Shorter row height (no separate label line) |
| `HideMax` | boolean | `false` | Hides the max value from the display |
| `FormatDisplayValue` | function | — | `(value) → string` custom formatter |
| `Disabled` | boolean | `false` | — |
| `Visible` | boolean | `true` | — |

```lua
s.Changed:Connect(function(value: number) end)
```

---

### RangeSlider

Two-thumb slider defining a min/max range.

```lua
local r = Box:AddRangeSlider(key: string, props: table)
```

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `Text` | string | `""` | Row label |
| `Min` | number | `0` | Absolute minimum |
| `Max` | number | `1` | Absolute maximum |
| `Default` | `{min, max}` | — | Initial range |
| `MinDistance` | number | `0` | Minimum gap enforced between the two thumbs |
| `Rounding` | number | `1` | Snap step |
| `Suffix` | string | `""` | — |
| `Disabled` | boolean | `false` | — |
| `Visible` | boolean | `true` | — |

```lua
r.Changed:Connect(function(value: {min: number, max: number}) end)
```

Value is always `{ min = number, max = number }`.

---

### Dropdown

A single- or multi-select list picker.

```lua
local d = Box:AddDropdown(key: string, props: table)
```

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `Text` | string | `""` | Row label |
| `Values` | `{string}` | `{}` | List of options |
| `DisabledValues` | `{string}` | `{}` | Options rendered greyed-out and unselectable |
| `Default` | string \| table | `nil` | Initial selection |
| `Multi` | boolean | `false` | Allow multiple selections |
| `Searchable` | boolean | `false` | Adds a search field in the open menu |
| `MaxVisibleDropdownItems` | number | — | Caps list height |
| `Tooltip` | string | — | — |
| `Disabled` | boolean | `false` | — |
| `Visible` | boolean | `true` | — |

```lua
d.Changed:Connect(function(value: string | {string}) end)

-- Mutate the options list at runtime:
d:AddValue("NewOption")
d:RemoveValue("OldOption")
d:RefreshValues({ "A", "B", "C" })
```

In `Multi = false` mode `.Value` is a `string`; in `Multi = true` mode it is a `{string}` table.

---

### Input

A text input field.

```lua
local i = Box:AddInput(key: string, props: table)
```

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `Text` | string | `""` | Row label |
| `Placeholder` | string | `""` | Ghost text when empty |
| `Default` | string | `""` | Initial value |
| `MaxLength` | number | `∞` | Truncates input at this character count |
| `Numeric` | boolean | `false` | Strips non-numeric characters (allows `-` and `.`) |
| `Finished` | boolean | `false` | Fire `Changed` only on focus-lost / Enter, not every keystroke |
| `ClearTextOnFocus` | boolean | `false` | Wipes the field when the user clicks in |
| `Tooltip` | string | — | — |
| `Disabled` | boolean | `false` | — |
| `Visible` | boolean | `true` | — |

```lua
i.Changed:Connect(function(value: string) end)
```

---

### ColorPicker

A full HSV color picker with hex input.

```lua
local cp = Box:AddColorPicker(key: string, props: table)
```

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `Title` | string | `""` | Label on the swatch row |
| `Default` | Color3 | `Color3.new(1,1,1)` | Initial color |
| `Transparency` | number | `0` | Initial alpha (0 = opaque, 1 = invisible) |
| `Disabled` | boolean | `false` | — |
| `Visible` | boolean | `true` | — |

```lua
cp.Changed:Connect(function(value: Color3) end)
cp:SetTransparency(0.5)  -- change alpha independently; does not fire `.Changed`
```

Can also be **attached inline** to a Toggle, Checkbox, or Label row:

```lua
local toggle = Box:AddToggle("MyToggle", { Text = "Feature" })
toggle:AddColorPicker("MyColor", { Default = Color3.new(1, 0, 0) })
```

---

### KeyPicker

A keybind control.

```lua
local kp = Box:AddKeyPicker(key: string, props: table)
```

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `Text` | string | `""` | Row label |
| `Default` | string | `"None"` | Initial key name (e.g. `"E"`, `"RightShift"`) |
| `Mode` | string | `"Toggle"` | `"Always"` · `"Toggle"` · `"Hold"` |
| `SyncToggleState` | string | — | Option key of a Toggle to mirror (Toggle mode only) |
| `WaitForCallback` | boolean | `false` | Waits for the `Clicked` handler to finish before re-arming |
| `NoUI` | boolean | `false` | Registers the keybind silently without showing a row |
| `Disabled` | boolean | `false` | — |
| `Visible` | boolean | `true` | — |

```lua
kp.Changed:Connect(function(value: EnumItem) end)  -- fires when the binding changes
kp.Clicked:Connect(function() end)                  -- fires when the bound key is pressed
```

**Modes:**
- `Always` — `Clicked` fires on every keypress.
- `Toggle` — keypresses flip an internal on/off state; `Clicked` fires on each flip.
- `Hold` — `Clicked` fires while the key is held; stops when released.

Can also be **attached inline** to a Toggle, Checkbox, or Label row (same as ColorPicker).

---

### Label

A read-only text row. Supports inline ColorPicker and KeyPicker addons.

```lua
local lbl = Box:AddLabel(text: string, props?: table)
lbl:AddColorPicker(key, props)
lbl:AddKeyPicker(key, props)
```

---

### Divider

A thin horizontal rule for visual grouping. No state.

```lua
Box:AddDivider()
```

---

## Theme

`Library.Theme` is a nested table. Mutate keys at runtime to restyle the UI immediately:

```lua
Library.Theme = {
    Surface = {
        Background = Color3.fromHex("#181818"),
        S0  = Color3.fromHex("#212121"),  -- deepest surface
        S1  = Color3.fromHex("#282828"),
        S2  = Color3.fromHex("#2e2e2e"),
        S3  = Color3.fromHex("#353535"),
        S4  = Color3.fromHex("#3d3d3d"),
        S5  = Color3.fromHex("#464646"),  -- shallowest surface
    },
    Text = {
        Primary   = Color3.fromHex("#ffffff"),
        Secondary = Color3.fromHex("#aaaaaa"),
        Tertiary  = Color3.fromHex("#868686"),
        Muted     = Color3.fromHex("#6f6f6f"),
    },
    Status = {
        Accent   = Color3.fromHex("#5c79fa"),  -- interactive highlights
        Info     = Color3.fromHex("#5b96fa"),
        Error    = Color3.fromHex("#e76761"),
        Success  = Color3.fromHex("#54b66e"),
        Question = Color3.fromHex("#a497ea"),
    },
}
```

Override individual keys without replacing the whole table:

```lua
Library.Theme.Status.Accent = Color3.fromHex("#e07050")
```

---

## Imperative Value Access

All registered controls can be read and mutated from outside any UI callback:

```lua
-- Toggles and Checkboxes
Library.Toggles.MyToggle.Value          -- boolean
Library.Toggles.MyToggle:SetValue(true)

-- Everything else (Slider, Dropdown, Input, ColorPicker, KeyPicker, RangeSlider)
Library.Options.MySlider.Value          -- number
Library.Options.MyDropdown.Value        -- string or {string}
Library.Options.MyInput.Value           -- string
Library.Options.MyColor.Value           -- Color3
Library.Options.MyKey.Value             -- Enum.KeyCode
Library.Options.MyRange.Value           -- { min: number, max: number }
```

---

## Lifecycle

### Re-injection safety

When the library loads it checks `getgenv().__SlateActiveExecution_Library`. If a previous instance exists it is automatically destroyed before the new one initialises. Re-injecting the script is safe.

### Destroying manually

```lua
Library:Destroy()
```

Removes the `ScreenGui`, disconnects every `RBXScriptConnection` created by the library, and clears the execution registry key so the next injection starts clean.

---

## Notes

- **No `require()`** — the library is self-contained. Every sub-system is an upvalue closure inside the single file.
- **CoreGui** — the root `ScreenGui` is parented to `CoreGui`. `syn.protect_gui` (or an executor equivalent) is applied automatically when available.
- **Error isolation** — all user-supplied callbacks (`Func`, `.Changed`, `.Clicked`) run inside `task.spawn(pcall)`. A runtime error inside your handler will not take down the UI.
- **Yield safety** — the library is fully event-driven. There are no `RenderStepped` polling loops in the state layer.
