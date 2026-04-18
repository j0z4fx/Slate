-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │  Slate UI Library — Example Script                                      │
-- │  Run this inside any executor (not Studio). The library is fetched      │
-- │  from GitHub at runtime via loadstring so no local files are needed.    │
-- └─────────────────────────────────────────────────────────────────────────┘

-- Fetch and execute the library source from GitHub.
-- `loadstring` compiles the remote string into a Luau function, which is
-- then called immediately. It returns the `Library` table.
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/j0z4fx/Slate/main/src/Library.luau"
))()

-- ── Tab & GroupBox setup ─────────────────────────────────────────────────────
-- The library ships with a single default Tab called "Main".
-- Retrieve it via Library.Tab (or Library.ActiveTab — both point to the same object).
local Tab = Library.Tab

-- GroupBoxes are the panels inside a tab. The second argument is the column:
--   "Left"  — left side of the window  (default if omitted)
--   "Right" — right side
local LeftBox  = Tab:AddGroupBox("Controls",  "Left")
local RightBox = Tab:AddGroupBox("Appearance", "Right")

-- ── Toggle ───────────────────────────────────────────────────────────────────
-- A Toggle is a boolean switch. The first argument is a unique registry key
-- used to look it up later via `Library.Toggles.<key>`.
local SpeedToggle = LeftBox:AddToggle("SpeedBoost", {
    Text    = "Speed Boost",      -- label shown next to the switch
    Default = false,              -- initial value
    Tooltip = "Enables speed boost when active",
})

-- React to value changes. `NewValue` is the new boolean state.
SpeedToggle.Changed:Connect(function(NewValue)
    -- Your game logic here — e.g. set character walk speed
    print("[SpeedBoost] →", NewValue)
end)

-- You can also read the current value at any time:
--   Library.Toggles.SpeedBoost.Value  →  boolean

-- ── Checkbox ─────────────────────────────────────────────────────────────────
-- Visually a classic checkbox; logic is identical to Toggle (boolean).
local LogCheckbox = LeftBox:AddCheckbox("Logging", {
    Text    = "Enable Logging",
    Default = true,
    Tooltip = "Print debug output to the developer console",
})

LogCheckbox.Changed:Connect(function(NewValue)
    print("[Logging] →", NewValue)
end)

-- ── Divider ───────────────────────────────────────────────────────────────────
-- A thin horizontal rule for visual separation. No registry key, no value.
LeftBox:AddDivider()

-- ── Button ────────────────────────────────────────────────────────────────────
-- Buttons are fire-and-forget; they have no persistent `.Value`.
-- `Func` is called inside `task.spawn(pcall)` so errors can't crash the UI.
LeftBox:AddButton({
    Text    = "Teleport to Spawn",
    Tooltip = "Instantly moves your character to the map spawn point",
    Func    = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        end
    end,
})

-- DoubleClick mode: `Func` only fires after two clicks within `DoubleClickWindow` seconds.
-- Useful for destructive actions where accidental single-clicks would be bad.
LeftBox:AddButton({
    Text              = "Reset Character",
    DoubleClick       = true,
    DoubleClickWindow = 0.4,   -- seconds; defaults to 0.35 if omitted
    Risky             = true,  -- tints the button red as a visual warning
    Func              = function()
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0
    end,
})

-- ── Slider ────────────────────────────────────────────────────────────────────
-- A single-thumb numeric slider. Registered in `Library.Options`.
local WalkSlider = LeftBox:AddSlider("WalkSpeed", {
    Text     = "Walk Speed",
    Min      = 16,
    Max      = 100,
    Default  = 16,
    Rounding = 1,      -- snap increment; 1 = whole numbers, 0.5 = half-steps, etc.
    Suffix   = " u/s", -- appended to the displayed value
})

WalkSlider.Changed:Connect(function(NewValue)
    -- `NewValue` is already clamped and rounded by the library
    local hum = game.Players.LocalPlayer.Character
        and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = NewValue
    end
end)

-- ── RangeSlider (Dual-Thumb) ───────────────────────────────────────────────
-- Two thumbs defining a min/max range. Value is `{min = number, max = number}`.
local TimeRange = LeftBox:AddRangeSlider("DayNightRange", {
    Text        = "Day/Night Range",
    Min         = 0,
    Max         = 24,
    Default     = { min = 6, max = 18 },
    MinDistance = 1,   -- enforced gap between the two thumbs
    Rounding    = 0.5,
    Suffix      = "h",
})

TimeRange.Changed:Connect(function(NewValue)
    -- NewValue.min and NewValue.max are both guaranteed valid at this point
    print(string.format("[DayNightRange] %.1f h – %.1f h", NewValue.min, NewValue.max))
end)

-- ── Dropdown (Single-select) ──────────────────────────────────────────────────
local BiomeDropdown = LeftBox:AddDropdown("Biome", {
    Text       = "Biome",
    Values     = { "Forest", "Desert", "Snow", "Swamp" },
    Default    = "Forest",
    Searchable = true,  -- adds a search box when the list is open
    Tooltip    = "Select the active biome",
})

BiomeDropdown.Changed:Connect(function(NewValue)
    print("[Biome] →", NewValue)  -- NewValue is a string
end)

-- Values can be mutated at runtime:
--   BiomeDropdown:AddValue("Ocean")
--   BiomeDropdown:RemoveValue("Swamp")
--   BiomeDropdown:RefreshValues({ "A", "B", "C" })

-- ── Dropdown (Multi-select) ───────────────────────────────────────────────────
-- When `Multi = true`, `.Value` is a table of selected strings.
local TagsDropdown = RightBox:AddDropdown("Tags", {
    Text    = "Active Tags",
    Values  = { "Admin", "VIP", "Tester", "Moderator" },
    Default = {},
    Multi   = true,
})

TagsDropdown.Changed:Connect(function(NewValue)
    -- NewValue is a table, e.g. { "Admin", "Tester" }
    for _, tag in ipairs(NewValue) do
        print("[Tags] active:", tag)
    end
end)

-- ── Input (TextBox) ───────────────────────────────────────────────────────────
local NameInput = RightBox:AddInput("PlayerName", {
    Text             = "Target Player",
    Placeholder      = "Enter username…",
    Default          = "",
    MaxLength        = 20,
    Numeric          = false,  -- set true to strip non-numeric characters
    Finished         = true,   -- fires Changed only when Enter is pressed / focus lost
    ClearTextOnFocus = false,
})

NameInput.Changed:Connect(function(NewValue)
    print("[PlayerName] →", NewValue)
end)

-- ── ColorPicker ───────────────────────────────────────────────────────────────
-- Opens a popup with a SV square, hue strip, and hex input.
-- Can be attached to a GroupBox directly (standalone row) or inline on a Label/Toggle.
local EspColorPicker = RightBox:AddColorPicker("EspColor", {
    Title   = "ESP Color",          -- label shown on the swatch row
    Default = Color3.fromHex("#5c79fa"),
    Transparency = 0,               -- initial alpha (0 = opaque, 1 = fully transparent)
})

EspColorPicker.Changed:Connect(function(NewValue)
    -- NewValue is a Color3
    print("[EspColor] →", tostring(NewValue))
end)

-- Set transparency separately at runtime:
--   EspColorPicker:SetTransparency(0.5)

-- ── Attaching controls inline to a Toggle ─────────────────────────────────────
-- ColorPicker and KeyPicker can be attached to a Toggle/Checkbox/Label row
-- so they share the same horizontal space instead of occupying a new row.
local EspToggle = RightBox:AddToggle("EspEnabled", {
    Text    = "ESP",
    Default = false,
})

-- Attach a color swatch directly onto the toggle row
EspToggle:AddColorPicker("EspBoxColor", {
    Default = Color3.fromRGB(255, 255, 255),
})

-- Attach a key binding onto the same toggle row
EspToggle:AddKeyPicker("EspKey", {
    Default = "RightShift",
    Mode    = "Toggle",   -- "Always" | "Toggle" | "Hold"
    Text    = "ESP Keybind",
    -- SyncToggleState = "EspEnabled"  ← uncomment to mirror the toggle state
})

-- ── KeyPicker (standalone) ────────────────────────────────────────────────────
-- A standalone keybind row (not attached to another control).
local PanicKey = RightBox:AddKeyPicker("PanicKey", {
    Default = "End",
    Mode    = "Always",  -- callback fires every time the key is pressed
    Text    = "Panic Key",
    NoUI    = false,     -- set true to hide the row from the UI entirely
})

PanicKey.Changed:Connect(function(NewValue)
    -- NewValue is the newly bound Enum.KeyCode
    print("[PanicKey] rebound to:", tostring(NewValue))
end)

-- `Clicked` fires each time the bound key is actually pressed (in its Mode context)
PanicKey.Clicked:Connect(function()
    Library:Destroy()  -- tear down the entire UI and clean up all connections
end)

-- ── Label ─────────────────────────────────────────────────────────────────────
-- A read-only text row. Useful for version info or status lines.
-- A Label also supports :AddColorPicker and :AddKeyPicker as inline addons.
RightBox:AddLabel("Slate UI Library — v0.1.0")

-- ── Theme customization ───────────────────────────────────────────────────────
-- The theme table is a nested structure with Surface, Text, and Status palettes.
-- Mutate individual keys to override specific colours; unset keys fall back to defaults.
Library.Theme.Status.Accent = Color3.fromHex("#e07050")  -- changes highlight colour

-- ── Reading values imperatively ───────────────────────────────────────────────
-- All Toggles (and Checkboxes) live in `Library.Toggles`.
-- All Options (Slider, RangeSlider, Dropdown, Input, ColorPicker, KeyPicker) live
-- in `Library.Options`.  Both tables accept string key indexing.
--
--   Library.Toggles.SpeedBoost.Value   → boolean
--   Library.Options.WalkSpeed.Value    → number
--   Library.Options.Biome.Value        → string
--   Library.Options.Tags.Value         → table
--   Library.Options.EspColor.Value     → Color3
--   Library.Options.PanicKey.Value     → Enum.KeyCode
--
-- Programmatic mutations respect the same validation the UI does:
--   Library.Toggles.SpeedBoost:SetValue(true)
--   Library.Options.WalkSpeed:SetValue(50)

-- ── Destroying the library ────────────────────────────────────────────────────
-- Call Library:Destroy() to remove the GUI, disconnect every event, and
-- clean up the execution registry so re-injecting creates a fresh instance.
-- (The PanicKey handler above does this automatically on keypress.)
