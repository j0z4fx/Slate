-- Slate UI Library — Example
-- Run inside an executor. Fetches the library from GitHub via loadstring.

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/j0z4fx/Slate/main/src/Library.luau"
))()

local Tab = Library.Tab

local LeftBox  = Tab:AddGroupBox("Player",    "Left")
local RightBox = Tab:AddGroupBox("Visuals",   "Right")

-- ── Label ────────────────────────────────────────────────────────────────────
LeftBox:AddLabel("Movement Settings")

-- ── Toggle ───────────────────────────────────────────────────────────────────
local SpeedToggle = LeftBox:AddToggle("SpeedEnabled", {
    Text    = "Speed Boost",
    Default = false,
    Tooltip = "Doubles your walk speed while active",
})

SpeedToggle.Changed:Connect(function(value)
    print("SpeedEnabled changed:", value)
end)

-- ── Checkbox ─────────────────────────────────────────────────────────────────
local InfiniteJump = LeftBox:AddCheckbox("InfiniteJump", {
    Text    = "Infinite Jump",
    Default = false,
    Tooltip = "Lets you jump while already in the air",
})

InfiniteJump.Changed:Connect(function(value)
    print("InfiniteJump changed:", value)
end)

-- ── Divider ───────────────────────────────────────────────────────────────────
LeftBox:AddDivider()

-- ── Slider ────────────────────────────────────────────────────────────────────
local WalkSpeed = LeftBox:AddSlider("WalkSpeed", {
    Text     = "Walk Speed",
    Min      = 16,
    Max      = 150,
    Default  = 16,
    Rounding = 1,
    Suffix   = " u/s",
})

WalkSpeed.Changed:Connect(function(value)
    print("WalkSpeed changed:", value)
end)

-- ── RangeSlider ───────────────────────────────────────────────────────────────
local FovRange = LeftBox:AddRangeSlider("FovRange", {
    Text        = "FOV Range",
    Min         = 30,
    Max         = 120,
    Default     = { min = 60, max = 90 },
    MinDistance = 5,
    Rounding    = 1,
    Suffix      = "°",
})

FovRange.Changed:Connect(function(value)
    print("FovRange changed:", value.min, "–", value.max)
end)

-- ── Dropdown (single) ─────────────────────────────────────────────────────────
local TeamFilter = LeftBox:AddDropdown("TeamFilter", {
    Text       = "Team Filter",
    Values     = { "All", "Enemies", "Allies", "Neutral" },
    Default    = "All",
    Searchable = false,
})

TeamFilter.Changed:Connect(function(value)
    print("TeamFilter changed:", value)
end)

-- ── Dropdown (multi) ──────────────────────────────────────────────────────────
local AimbotBones = LeftBox:AddDropdown("AimbotBones", {
    Text    = "Target Bones",
    Values  = { "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" },
    Default = { "Head" },
    Multi   = true,
})

AimbotBones.Changed:Connect(function(value)
    print("AimbotBones changed:", table.concat(value, ", "))
end)

-- ── Input ─────────────────────────────────────────────────────────────────────
local TargetName = LeftBox:AddInput("TargetName", {
    Text        = "Target Player",
    Placeholder = "Username…",
    Default     = "",
    MaxLength   = 20,
    Finished    = true,
})

TargetName.Changed:Connect(function(value)
    print("TargetName changed:", value)
end)

-- ── Buttons ───────────────────────────────────────────────────────────────────
LeftBox:AddButton({
    Text       = "Teleport to Spawn",
    ButtonText = "Teleport",
    Func       = function()
        print("Teleport to spawn fired")
    end,
})

LeftBox:AddButton({
    Text              = "Reset Character",
    ButtonText        = "Reset",
    Risky             = true,
    DoubleClick       = true,
    DoubleClickWindow = 0.4,
    Func              = function()
        print("Reset character fired")
    end,
})

-- ── Right column ─────────────────────────────────────────────────────────────
RightBox:AddLabel("ESP Settings")

-- ── Toggle with inline ColorPicker + KeyPicker ────────────────────────────────
local EspToggle = RightBox:AddToggle("EspEnabled", {
    Text    = "ESP",
    Default = false,
})

EspToggle.Changed:Connect(function(value)
    print("EspEnabled changed:", value)
end)

EspToggle:AddColorPicker("EspColor", {
    Default = Color3.fromHex("#5c79fa"),
})

Library.Options.EspColor.Changed:Connect(function(value)
    print("EspColor changed:", tostring(value))
end)

EspToggle:AddKeyPicker("EspKey", {
    Default = "RightShift",
    Mode    = "Toggle",
    Text    = "ESP Toggle Key",
})

Library.Options.EspKey.Changed:Connect(function(value)
    print("EspKey rebound:", tostring(value))
end)

Library.Options.EspKey.Clicked:Connect(function()
    print("EspKey activated")
end)

-- ── Standalone ColorPicker ────────────────────────────────────────────────────
local ChamsColor = RightBox:AddColorPicker("ChamsColor", {
    Title        = "Chams Color",
    Default      = Color3.fromRGB(255, 80, 80),
    Transparency = 0,
})

ChamsColor.Changed:Connect(function(value)
    print("ChamsColor changed:", tostring(value))
end)

RightBox:AddDivider()

-- ── Standalone KeyPicker ──────────────────────────────────────────────────────
local PanicKey = RightBox:AddKeyPicker("PanicKey", {
    Text    = "Panic Key",
    Default = "End",
    Mode    = "Always",
})

PanicKey.Changed:Connect(function(value)
    print("PanicKey rebound:", tostring(value))
end)

PanicKey.Clicked:Connect(function()
    print("Panic key pressed — unloading")
    Library:Destroy()
end)
