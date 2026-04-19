-- Slate UI Library — Example
-- Run inside an executor. Fetches the library from GitHub via loadstring.

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/j0z4fx/Slate/main/src/Library.luau"
))()

-- Create the main tab. The library ships with no tabs by default — you create
-- them with Library:AddTab(name). The first tab becomes active automatically.
-- A built-in Settings tab is always added to the bottom of the sidebar.
local Tab = Library:AddTab("Main")

local LeftBox  = Tab:AddGroupBox("Player",   "Left")
local RightBox = Tab:AddGroupBox("Visuals",  "Right")

-- ── Label ─────────────────────────────────────────────────────────────────────
LeftBox:AddLabel("Movement Settings")

-- ── Toggle ────────────────────────────────────────────────────────────────────
local SpeedToggle = LeftBox:AddToggle("SpeedEnabled", {
    Text    = "Speed Boost",
    Default = false,
    Tooltip = "Doubles your walk speed while active",
})
SpeedToggle.Changed:Connect(function(value)
    print("SpeedEnabled:", value)
end)

-- ── Checkbox ──────────────────────────────────────────────────────────────────
local InfiniteJump = LeftBox:AddCheckbox("InfiniteJump", {
    Text    = "Infinite Jump",
    Default = false,
})
InfiniteJump.Changed:Connect(function(value)
    print("InfiniteJump:", value)
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
    print("WalkSpeed:", value)
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
    print("FovRange:", value.min, "–", value.max)
end)

-- ── Dropdown (single) ─────────────────────────────────────────────────────────
local TeamFilter = LeftBox:AddDropdown("TeamFilter", {
    Text       = "Team Filter",
    Values     = { "All", "Enemies", "Allies", "Neutral" },
    Default    = "All",
    Searchable = false,
})
TeamFilter.Changed:Connect(function(value)
    print("TeamFilter:", value)
end)

-- ── Dropdown (multi) ──────────────────────────────────────────────────────────
local AimbotBones = LeftBox:AddDropdown("AimbotBones", {
    Text    = "Target Bones",
    Values  = { "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" },
    Default = { "Head" },
    Multi   = true,
})
AimbotBones.Changed:Connect(function(value)
    print("AimbotBones:", table.concat(value, ", "))
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
    print("TargetName:", value)
end)

-- ── Buttons ───────────────────────────────────────────────────────────────────
LeftBox:AddButton({
    Text       = "Teleport to Spawn",
    ButtonText = "Teleport",
    Func = function()
        print("Teleport fired")
    end,
})

LeftBox:AddButton({
    Text              = "Reset Character",
    ButtonText        = "Reset",
    Risky             = true,
    DoubleClick       = true,
    DoubleClickWindow = 0.4,
    Func = function()
        print("Reset fired")
    end,
})

-- ── Right column ─────────────────────────────────────────────────────────────
RightBox:AddLabel("ESP Settings")

-- Toggle with inline ColorPicker + KeyPicker
local EspToggle = RightBox:AddToggle("EspEnabled", {
    Text    = "ESP",
    Default = false,
})
EspToggle.Changed:Connect(function(value)
    print("EspEnabled:", value)
end)

EspToggle:AddColorPicker("EspColor", {
    Default = Color3.fromHex("#5c79fa"),
})
Library.Options.EspColor.Changed:Connect(function(value)
    print("EspColor:", tostring(value))
end)

EspToggle:AddKeyPicker("EspKey", {
    Default = "RightShift",
    Mode    = "Toggle",
    Text    = "ESP Toggle Key",
})
Library.Options.EspKey.Clicked:Connect(function()
    print("EspKey activated")
end)

-- Standalone ColorPicker
local ChamsColor = RightBox:AddColorPicker("ChamsColor", {
    Title   = "Chams Color",
    Default = Color3.fromRGB(255, 80, 80),
})
ChamsColor.Changed:Connect(function(value)
    print("ChamsColor:", tostring(value))
end)

RightBox:AddDivider()

-- Standalone KeyPicker — right-click the button to pick Always / Toggle / Hold
-- Pressing End destroys the UI
local PanicKey = RightBox:AddKeyPicker("PanicKey", {
    Text    = "Panic Key",
    Default = "End",
    Mode    = "Toggle",
})
PanicKey.Clicked:Connect(function()
    print("Panic — unloading")
    Library:Destroy()
end)

-- ── Second tab with ViewportBox and BodyPartBox ───────────────────────────────
local Tab2 = Library:AddTab("Preview")

-- ViewportBox — proper R6 rig with Motor6D joints, slowly rotating.
-- Coloured with the accent colour. No children, purely visual.
local CharacterBox = Tab2:AddViewportBox("Character", "Left")

-- BodyPartBox — clickable 2D body-part silhouette.
-- .Value holds the currently selected part name.
-- .Changed fires when the selection changes.
local PartPicker = Tab2:AddBodyPartBox("Target Part", "Right")
PartPicker.Changed:Connect(function(part)
    print("Selected part:", part)
end)
