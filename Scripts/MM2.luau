local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/j0z4fx/Slate/main/src/Library.luau"
))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local SharedState = (getgenv and getgenv()) or _G

if type(SharedState.__SlateMM2RoleESP) == "table" and type(SharedState.__SlateMM2RoleESP.Cleanup) == "function" then
    pcall(SharedState.__SlateMM2RoleESP.Cleanup)
end

local SHERIFF_COLOR = Color3.fromRGB(52, 140, 235)
local MURDERER_COLOR = Color3.fromRGB(221, 90, 85)
local FILL_TRANSPARENCY = 0.8
local OUTLINE_TRANSPARENCY = 0
local SCAN_INTERVAL = 1
local FADE_TIME = 0.35

local Tab = Library:AddTab("Main")
local ESPBox = Tab:AddGroupBox("ESP", "Left")

local SheriffToggle = ESPBox:AddToggle("SheriffESP", {
    Text = "Sheriff ESP",
    Default = true,
})
local SheriffColor = SheriffToggle:AddColorPicker("SheriffESPColor", {
    Default = SHERIFF_COLOR,
})
local SheriffLabel = ESPBox:AddLabel("Current Sheriff: None")

ESPBox:AddDivider()

local MurdererToggle = ESPBox:AddToggle("MurdererESP", {
    Text = "Murderer ESP",
    Default = true,
})
local MurdererColor = MurdererToggle:AddColorPicker("MurdererESPColor", {
    Default = MURDERER_COLOR,
})
local MurdererLabel = ESPBox:AddLabel("Current Murderer: None")

local existing = CoreGui:FindFirstChild("RoleESP_Container")
if existing then
    existing:Destroy()
end

local container = Instance.new("Folder")
container.Name = "RoleESP_Container"
container.Parent = CoreGui

local running = true
local cleanedUp = false
local connections = {}

local function TrackConnection(connection)
    table.insert(connections, connection)
    return connection
end

local function DisconnectAll()
    for index, connection in ipairs(connections) do
        if connection and connection.Connected and connection.Disconnect then
            connection:Disconnect()
        end
        connections[index] = nil
    end
end

local function getPlayerData()
    return (getgenv and getgenv().playerData) or _G.playerData or {}
end

local active = {}

local function isRoleEnabled(role)
    if role == "Sheriff" then
        return SheriffToggle.Value
    end

    if role == "Murderer" then
        return MurdererToggle.Value
    end

    return false
end

local function getRoleColor(role)
    if role == "Sheriff" then
        return SheriffColor.Value
    end

    if role == "Murderer" then
        return MurdererColor.Value
    end

    return Color3.new(1, 1, 1)
end

local function findByTool(toolName, includeLocalPlayer)
    for _, plr in ipairs(Players:GetPlayers()) do
        if includeLocalPlayer or plr ~= LocalPlayer then
            local backpack = plr:FindFirstChildOfClass("Backpack")
            if backpack and backpack:FindFirstChild(toolName) then
                return plr
            end
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if includeLocalPlayer or plr ~= LocalPlayer then
            local char = plr.Character
            if char and char:FindFirstChild(toolName) then
                return plr
            end
        end
    end

    return nil
end

local function findByRole(role, includeLocalPlayer)
    local data = getPlayerData()
    for plr, info in pairs(data) do
        if typeof(plr) == "Instance" and plr:IsA("Player") and (includeLocalPlayer or plr ~= LocalPlayer) then
            if info and info.Role == role then
                return plr
            end
        end
    end
    return nil
end

local function getMurderer(includeLocalPlayer)
    return findByTool("Knife", includeLocalPlayer) or findByRole("Murderer", includeLocalPlayer)
end

local function getSheriff(includeLocalPlayer)
    return findByTool("Gun", includeLocalPlayer) or findByRole("Sheriff", includeLocalPlayer)
end

local function getPlayerName(player)
    if player and player.Parent == Players then
        return player.Name
    end

    return "None"
end

local function updateRoleLabels(murderer, sheriff, hasGun)
    SheriffLabel:SetText("Current Sheriff: " .. getPlayerName(hasGun and sheriff or nil))
    MurdererLabel:SetText("Current Murderer: " .. getPlayerName(murderer))
end

local function gunExistsInGame()
    for _, plr in ipairs(Players:GetPlayers()) do
        local backpack = plr:FindFirstChildOfClass("Backpack")
        if backpack and backpack:FindFirstChild("Gun") then
            return true
        end

        local char = plr.Character
        if char and char:FindFirstChild("Gun") then
            return true
        end
    end

    return false
end

local function buildHighlight(player, role)
    local char = player.Character
    if not char then
        return nil
    end

    local color = getRoleColor(role)

    local highlight = Instance.new("Highlight")
    highlight.Name = "RoleESP_" .. player.Name
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = char
    highlight.Parent = container

    TweenService:Create(
        highlight,
        TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            FillTransparency = FILL_TRANSPARENCY,
            OutlineTransparency = OUTLINE_TRANSPARENCY,
        }
    ):Play()

    return highlight
end

local function fadeAndDestroy(highlight)
    if not highlight then
        return
    end

    if not highlight.Parent then
        highlight:Destroy()
        return
    end

    local tween = TweenService:Create(
        highlight,
        TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            FillTransparency = 1,
            OutlineTransparency = 1,
        }
    )

    tween.Completed:Connect(function()
        if highlight then
            highlight:Destroy()
        end
    end)
    tween:Play()
end

local function removeFor(player)
    local entry = active[player]
    if not entry then
        return
    end

    active[player] = nil
    fadeAndDestroy(entry.highlight)
end

local function removeRole(role)
    for player, entry in pairs(active) do
        if entry.role == role then
            removeFor(player)
        end
    end
end

local function clearAll()
    for player in pairs(active) do
        removeFor(player)
    end
end

local function refreshRoleVisuals(role)
    for player, entry in pairs(active) do
        if entry.role == role then
            if not isRoleEnabled(role) then
                removeFor(player)
            elseif entry.highlight and entry.highlight.Parent then
                local char = player.Character
                if char and entry.highlight.Adornee ~= char then
                    entry.highlight.Adornee = char
                end

                local color = getRoleColor(role)
                entry.highlight.FillColor = color
                entry.highlight.OutlineColor = color
            end
        end
    end
end

local function applyFor(player, role)
    if not isRoleEnabled(role) then
        removeFor(player)
        return
    end

    local entry = active[player]

    if entry and entry.role == role and entry.highlight and entry.highlight.Parent then
        local char = player.Character
        if char and entry.highlight.Adornee ~= char then
            entry.highlight.Adornee = char
        end

        local color = getRoleColor(role)
        entry.highlight.FillColor = color
        entry.highlight.OutlineColor = color
        return
    end

    if entry then
        fadeAndDestroy(entry.highlight)
        active[player] = nil
    end

    local highlight = buildHighlight(player, role)
    if highlight then
        active[player] = {
            highlight = highlight,
            role = role,
        }
    end
end

local function scan()
    local hasGun = gunExistsInGame()
    local murderer = getMurderer(true)
    local sheriff = getSheriff(true)

    updateRoleLabels(murderer, sheriff, hasGun)

    if not hasGun then
        clearAll()
        return
    end

    local keep = {}

    if murderer and murderer ~= LocalPlayer and MurdererToggle.Value then
        keep[murderer] = true
        applyFor(murderer, "Murderer")
    end

    if sheriff and sheriff ~= LocalPlayer and SheriffToggle.Value then
        keep[sheriff] = true
        applyFor(sheriff, "Sheriff")
    end

    for player, entry in pairs(active) do
        if not player.Parent or not keep[player] or not isRoleEnabled(entry.role) then
            removeFor(player)
        end
    end
end

local function Cleanup()
    if cleanedUp then
        return
    end

    cleanedUp = true
    running = false
    DisconnectAll()

    for player, entry in pairs(active) do
        active[player] = nil
        if entry.highlight then
            entry.highlight:Destroy()
        end
    end

    if container then
        container:Destroy()
    end
end

SharedState.__SlateMM2RoleESP = {
    Cleanup = Cleanup,
}

TrackConnection(SheriffToggle.Changed:Connect(function(enabled)
    if enabled then
        pcall(scan)
    else
        removeRole("Sheriff")
    end
end))

TrackConnection(MurdererToggle.Changed:Connect(function(enabled)
    if enabled then
        pcall(scan)
    else
        removeRole("Murderer")
    end
end))

TrackConnection(SheriffColor.Changed:Connect(function()
    refreshRoleVisuals("Sheriff")
end))

TrackConnection(MurdererColor.Changed:Connect(function()
    refreshRoleVisuals("Murderer")
end))

TrackConnection(Players.PlayerRemoving:Connect(function(player)
    removeFor(player)
end))

task.spawn(function()
    pcall(scan)

    while running do
        task.wait(SCAN_INTERVAL)
        if not running then
            break
        end

        pcall(scan)
    end
end)
