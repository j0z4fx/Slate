local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/j0z4fx/Slate/main/src/Library.luau"
))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Events = ReplicatedStorage:WaitForChild("Events")
local CheckCode        = Events.CheckCode
local CheckIfOwned     = Events.CheckIfOwned
local Checkout         = Events.Checkout
local EquipShovelEvt   = Events.EquipShovel
local EquipBackpackEvt = Events.EquipBackpack
local EquipPetEvt      = Events.EquipPet
local GetStats         = Events.GetStats
local AreaSell         = Events.AreaSell
local RebirthEvt       = Events.Rebirth

-- Items the game routes through gamepass purchase; not buyable with coins
local GAMEPASS_ITEMS = {
    ["Infinite"]       = true,
    ["Black Hole"]     = true,
    ["Dark Pegasus"]   = true,
    ["Scythe"]         = true,
    ["Lightning Bolt"] = true,
    ["Teleporter"]     = true,
}

-- Comparators mirror the decompiled `v_u_105`
local function CompareShovels(a, b)
    local ta, tb = a:FindFirstChildOfClass("Tool"), b:FindFirstChildOfClass("Tool")
    if not ta or not tb then return false end
    return ta.Configurations.BlockDamage.Value / ta.Configurations.AttackLength.Value
         < tb.Configurations.BlockDamage.Value / tb.Configurations.AttackLength.Value
end

local function CompareBackpacks(a, b)
    if a.Name == "Infinite" then return false end
    if b.Name == "Infinite" then return true end
    local sa, sb = a:FindFirstChild("Storage"), b:FindFirstChild("Storage")
    if not sa or not sb then return false end
    return sa.Value < sb.Value
end

local function ComparePets(a, b)
    local pa, pb = a:FindFirstChild("DigPowerBoost"), b:FindFirstChild("DigPowerBoost")
    if not pa or not pb then return false end
    return pa.Value < pb.Value
end

local function BuildList(folder, comparator)
    local list = {}
    for _, item in ipairs(folder:GetChildren()) do
        if not GAMEPASS_ITEMS[item.Name] and item:FindFirstChild("Price") then
            table.insert(list, item)
        end
    end
    table.sort(list, comparator)
    return list
end

local function Names(list)
    local n = {}
    for _, i in ipairs(list) do table.insert(n, i.Name) end
    return n
end

-- Owned cache: once confirmed, stays
local ownedCache = {}
local function IsOwned(name)
    if ownedCache[name] then return true end
    local owned = false
    pcall(function() owned = CheckIfOwned:InvokeServer(name) end)
    if owned then ownedCache[name] = true end
    return owned
end

-- Stats cache. GetStats: [1]=rebirths [2]=sand [3]=backpack [4]=shovel [5]=pet
local statsCache = { time = 0, data = nil }
local function GetStatsCached()
    if statsCache.data and tick() - statsCache.time < 1 then
        return statsCache.data
    end
    local ok, packed = pcall(function() return table.pack(GetStats:InvokeServer()) end)
    if ok and packed then
        statsCache.data = {
            rebirths = packed[1] or 0,
            sand     = packed[2] or 0,
            backpack = packed[3] or "",
            shovel   = packed[4] or "",
            pet      = packed[5] or "",
        }
        statsCache.time = tick()
    end
    return statsCache.data or { rebirths=0, sand=0, backpack="", shovel="", pet="" }
end

local function GetCoins()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls and ls:FindFirstChild("Coins") then return ls.Coins.Value end
    return 0
end

local function GetRebirthCost(rebirths)
    return math.floor((rebirths ^ 1.5 + 1) * 500000)
end

-- Nearest island by UpgradeCF distance
local function GetCurrentIsland()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, closestDist = nil, math.huge
    for _, island in ipairs(ReplicatedStorage.Islands:GetChildren()) do
        local ucf = island:FindFirstChild("UpgradeCF")
        if ucf then
            local d = (hrp.Position - ucf.Value.p).Magnitude
            if d < closestDist then
                closest, closestDist = island, d
            end
        end
    end
    return closest
end

local function IsIslandOk(item, currentIsland)
    local island = item:FindFirstChild("Island")
    if not island or island.Value == nil then return true end
    return island.Value == currentIsland
end

local function BuildSkipSet(val)
    local set = {}
    if type(val) == "table" then
        for k, v in pairs(val) do
            if type(k) == "string" then
                if v then set[k] = true end
            elseif type(v) == "string" then
                set[v] = true
            end
        end
    end
    return set
end

local function GetNearestSellCF()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local best, bestDist = nil, math.huge
    for _, island in ipairs(ReplicatedStorage.Islands:GetChildren()) do
        local scf = island:FindFirstChild("SellCF")
        if scf then
            local d = (hrp.Position - scf.Value.p).Magnitude
            if d < bestDist then
                best, bestDist = scf.Value, d
            end
        end
    end
    return best
end

-- UI Setup
local Tab = Library:AddTab("Main")
local MiscBox    = Tab:AddGroupBox("Misc",         "Right")
local UpgradeBox = Tab:AddGroupBox("Auto Upgrade", "Right")
local FarmBox    = Tab:AddGroupBox("Autofarm",     "Left")
local DebugBox   = Tab:AddGroupBox("Debug",        "Left")

-- Misc
local Codes = {
    "moon", "martian", "launch", "400klikes", "200million",
    "finally", "intel", "jailcity", "heart", "freerubies",
    "v2update", "volcano", "medieval", "godly", "magma", "dino",
}

MiscBox:AddLabel("You must rejoin after claiming all codes.")
MiscBox:AddButton({
    Text = "Claim All Codes",
    ButtonText = "Claim",
    Func = function()
        for _, code in ipairs(Codes) do
            pcall(function() CheckCode:InvokeServer(code) end)
            task.wait(0.5)
        end
    end,
})

-- Auto Upgrade
UpgradeBox:AddLabel("Auto Buy")
UpgradeBox:AddToggle("AutoShovel",   { Text = "Shovel",   Default = false })
UpgradeBox:AddToggle("AutoBackpack", { Text = "Backpack", Default = false })
UpgradeBox:AddToggle("AutoPet",      { Text = "Pet",      Default = false })

UpgradeBox:AddDivider()
UpgradeBox:AddLabel("Auto Equip")
UpgradeBox:AddToggle("EquipShovel",   { Text = "Shovel",   Default = true })
UpgradeBox:AddToggle("EquipBackpack", { Text = "Backpack", Default = true })
UpgradeBox:AddToggle("EquipPet",      { Text = "Pet",      Default = true })

UpgradeBox:AddDivider()

local ShovelList   = BuildList(ReplicatedStorage.Shovels,   CompareShovels)
local BackpackList = BuildList(ReplicatedStorage.Backpacks, CompareBackpacks)
local PetList      = BuildList(ReplicatedStorage.Pets,      ComparePets)

local SkipShovels = UpgradeBox:AddDropdown("SkipShovels", {
    Text = "Skip Shovels", Values = Names(ShovelList), Default = {}, Multi = true,
})
local SkipBackpacks = UpgradeBox:AddDropdown("SkipBackpacks", {
    Text = "Skip Backpacks", Values = Names(BackpackList), Default = {}, Multi = true,
})
local SkipPets = UpgradeBox:AddDropdown("SkipPets", {
    Text = "Skip Pets", Values = Names(PetList), Default = {}, Multi = true,
})

-- Autofarm
FarmBox:AddToggle("AutoSell",    { Text = "Auto Sell",    Default = false,
    Tooltip = "Uses a visual clone decoy so you don't see the teleport" })
FarmBox:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false,
    Tooltip = "Rebirths the moment you can afford it" })

-- Core upgrade logic
local function RunCategory(list, skipSet, autoBuyOn, autoEquipOn, currentEquipped, equipEvent)
    if not autoBuyOn and not autoEquipOn then return end
    local coins = GetCoins()
    local island = GetCurrentIsland()

    for i = #list, 1, -1 do
        local item = list[i]

        if IsOwned(item.Name) then
            if autoEquipOn and currentEquipped ~= item.Name then
                equipEvent:FireServer(item.Name)
                statsCache.time = 0
            end
            return
        end

        if autoBuyOn
          and not skipSet[item.Name]
          and IsIslandOk(item, island)
          and coins >= item.Price.Value then
            Checkout:FireServer(item.Name)
            ownedCache[item.Name] = true
            statsCache.time = 0
            return
        end
    end
end

-- Upgrade loop — fast ticks so purchases happen the moment you can afford
task.spawn(function()
    while task.wait(0.25) do
        local opts = Library.Options
        local eq = GetStatsCached()

        RunCategory(ShovelList,   BuildSkipSet(opts.SkipShovels.Value),
            opts.AutoShovel.Value,   opts.EquipShovel.Value,   eq.shovel,   EquipShovelEvt)

        RunCategory(BackpackList, BuildSkipSet(opts.SkipBackpacks.Value),
            opts.AutoBackpack.Value, opts.EquipBackpack.Value, eq.backpack, EquipBackpackEvt)

        RunCategory(PetList,      BuildSkipSet(opts.SkipPets.Value),
            opts.AutoPet.Value,      opts.EquipPet.Value,      eq.pet,      EquipPetEvt)
    end
end)

-- Auto Sell: clone-as-decoy while real character teleports
local selling = false
task.spawn(function()
    while task.wait(1) do
        if not Library.Options.AutoSell.Value then continue end
        if selling then continue end

        local stats = GetStatsCached()
        if stats.sand <= 0 then continue end

        local char = LocalPlayer.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then continue end

        local sellCF = GetNearestSellCF()
        if not sellCF then continue end

        selling = true
        local returnCF = hrp.CFrame
        local camera = Workspace.CurrentCamera
        local originalSubject = camera.CameraSubject
        local originalType = camera.CameraType

        local clone
        pcall(function()
            -- 1. Local clone, strip scripts so nothing tries to take control
            clone = char:Clone()
            for _, d in ipairs(clone:GetDescendants()) do
                if d:IsA("LocalScript") or d:IsA("Script") then
                    d:Destroy()
                end
            end
            clone.Parent = Workspace
            local cloneHum = clone:FindFirstChildOfClass("Humanoid")
            local cloneHRP = clone:FindFirstChild("HumanoidRootPart")
            if cloneHRP then
                cloneHRP.Anchored = true
                cloneHRP.CFrame = returnCF
            end

            -- 2. Hide real character locally + camera follows clone
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 1
                end
            end
            if cloneHum then
                camera.CameraSubject = cloneHum
            end

            -- 3. Real character: freeze humanoid, teleport, sell, teleport back
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            hrp.CFrame = sellCF * CFrame.new(-2, 0, 0)
            hrp.AssemblyLinearVelocity = Vector3.zero
            task.wait(0.15)
            AreaSell:FireServer()
            task.wait(0.15)

            hrp.CFrame = returnCF
            hrp.AssemblyLinearVelocity = Vector3.zero
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)

            -- 4. Restore camera, unhide, destroy clone
            camera.CameraSubject = originalSubject
            camera.CameraType = originalType
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 0
                end
            end
        end)

        if clone then clone:Destroy() end
        statsCache.time = 0
        selling = false
    end
end)

-- Auto Rebirth
task.spawn(function()
    while task.wait(0.5) do
        if not Library.Options.AutoRebirth.Value then continue end
        local stats = GetStatsCached()
        local cost = GetRebirthCost(stats.rebirths)
        if GetCoins() >= cost then
            RebirthEvt:FireServer()
            statsCache.time = 0
            task.wait(2)
        end
    end
end)

-- Refresh sorted lists periodically
task.spawn(function()
    while task.wait(30) do
        ShovelList   = BuildList(ReplicatedStorage.Shovels,   CompareShovels)
        BackpackList = BuildList(ReplicatedStorage.Backpacks, CompareBackpacks)
        PetList      = BuildList(ReplicatedStorage.Pets,      ComparePets)
        pcall(function() if SkipShovels.SetValues   then SkipShovels:SetValues(Names(ShovelList))     end end)
        pcall(function() if SkipBackpacks.SetValues then SkipBackpacks:SetValues(Names(BackpackList)) end end)
        pcall(function() if SkipPets.SetValues      then SkipPets:SetValues(Names(PetList))           end end)
    end
end)

-- Debug scan
DebugBox:AddLabel("Sends scan results to clipboard.")
DebugBox:AddButton({
    Text = "Scan Game Info",
    ButtonText = "Scan",
    Func = function()
        local lines = {}
        local function w(s) table.insert(lines, s) end

        w("=== GAME SCAN ===")
        w("PlaceId: " .. tostring(game.PlaceId))
        w("GameId: " .. tostring(game.GameId))
        w("Time: " .. os.date("%Y-%m-%d %H:%M:%S"))
        w("")

        w("=== LOCAL PLAYER ===")
        w("Name: " .. LocalPlayer.Name)
        w("UserId: " .. tostring(LocalPlayer.UserId))
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            w("-- leaderstats --")
            for _, stat in ipairs(ls:GetChildren()) do
                w(("  %s (%s) = %s"):format(stat.Name, stat.ClassName, tostring(stat.Value)))
            end
        end
        w("-- Backpack --")
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            for _, item in ipairs(bp:GetChildren()) do
                w(("  %s (%s)"):format(item.Name, item.ClassName))
            end
        end
        w("-- Character (equipped) --")
        local char = LocalPlayer.Character
        if char then
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    w(("  %s (Tool)"):format(item.Name))
                end
            end
        end
        w("")

        w("=== ReplicatedStorage.Events ===")
        local evts = ReplicatedStorage:FindFirstChild("Events")
        if evts then
            local eventList = {}
            for _, e in ipairs(evts:GetChildren()) do
                table.insert(eventList, ("  %s (%s)"):format(e.Name, e.ClassName))
            end
            table.sort(eventList)
            for _, l in ipairs(eventList) do w(l) end
        end
        w("")

        w("=== ReplicatedStorage.Shovels ===")
        for _, s in ipairs(ReplicatedStorage.Shovels:GetChildren()) do
            local line = "  " .. s.Name
            local price = s:FindFirstChild("Price")
            if price then line = line .. " | Price=" .. tostring(price.Value) end
            local tool = s:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Configurations") then
                local cfg = tool.Configurations
                local dmg = cfg:FindFirstChild("BlockDamage")
                local spd = cfg:FindFirstChild("AttackLength")
                if dmg then line = line .. " | Damage=" .. tostring(dmg.Value) end
                if spd then line = line .. " | AttackLength=" .. tostring(spd.Value) end
            end
            local island = s:FindFirstChild("Island")
            if island and island.Value then
                line = line .. " | Island=" .. tostring(island.Value.Name)
            end
            w(line)
        end
        w("")

        w("=== ReplicatedStorage.Backpacks ===")
        for _, b in ipairs(ReplicatedStorage.Backpacks:GetChildren()) do
            local line = "  " .. b.Name
            local price = b:FindFirstChild("Price")
            local storage = b:FindFirstChild("Storage")
            if price then line = line .. " | Price=" .. tostring(price.Value) end
            if storage then line = line .. " | Storage=" .. tostring(storage.Value) end
            w(line)
        end
        w("")

        w("=== ReplicatedStorage.Pets ===")
        for _, p in ipairs(ReplicatedStorage.Pets:GetChildren()) do
            local line = "  " .. p.Name
            local price = p:FindFirstChild("Price")
            local boost = p:FindFirstChild("DigPowerBoost")
            if price then line = line .. " | Price=" .. tostring(price.Value) end
            if boost then line = line .. " | DigPowerBoost=" .. tostring(boost.Value) end
            w(line)
        end
        w("")

        w("=== ReplicatedStorage.Gamepasses ===")
        for _, g in ipairs(ReplicatedStorage.Gamepasses:GetChildren()) do
            local line = "  " .. g.Name
            local id = g:FindFirstChild("ID")
            local price = g:FindFirstChild("Price")
            if id then line = line .. " | ID=" .. tostring(id.Value) end
            if price then line = line .. " | Price=" .. tostring(price.Value) end
            w(line)
        end
        w("")

        w("=== ReplicatedStorage.Islands ===")
        for _, isl in ipairs(ReplicatedStorage.Islands:GetChildren()) do
            local line = "  " .. isl.Name
            local reqs = isl:FindFirstChild("Requirements")
            if reqs then
                local parts = {}
                for _, r in ipairs(reqs:GetChildren()) do
                    if r:IsA("ValueBase") then
                        table.insert(parts, ("%s=%s"):format(r.Name, tostring(r.Value)))
                    end
                end
                if #parts > 0 then line = line .. " | Req: " .. table.concat(parts, ", ") end
            end
            w(line)
        end
        w("")

        w("=== ReplicatedStorage.Crates ===")
        for _, c in ipairs(ReplicatedStorage.Crates:GetChildren()) do
            local line = "  " .. c.Name
            local caseName = c:FindFirstChild("CaseName")
            local coinsCost = c:FindFirstChild("CoinsCost")
            local rubyCost = c:FindFirstChild("RubyCost")
            local candyCost = c:FindFirstChild("CandyCost")
            if caseName then line = line .. " | CaseName=" .. tostring(caseName.Value) end
            if coinsCost then line = line .. " | CoinsCost=" .. tostring(coinsCost.Value) end
            if rubyCost then line = line .. " | RubyCost=" .. tostring(rubyCost.Value) end
            if candyCost then line = line .. " | CandyCost=" .. tostring(candyCost.Value) end
            w(line)
        end
        w("")

        w("=== ReplicatedStorage top-level ===")
        for _, child in ipairs(ReplicatedStorage:GetChildren()) do
            local count = #child:GetChildren()
            w(("  %s (%s)%s"):format(child.Name, child.ClassName,
                count > 0 and (" [" .. count .. " children]") or ""))
        end
        w("")

        w("=== workspace top-level ===")
        for _, child in ipairs(workspace:GetChildren()) do
            w(("  %s (%s)"):format(child.Name, child.ClassName))
        end
        w("")

        w("=== PlayerGui top-level ===")
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _, child in ipairs(pg:GetChildren()) do
                w(("  %s (%s)"):format(child.Name, child.ClassName))
            end
        end

        local output = table.concat(lines, "\n")
        local ok, err = pcall(function() setclipboard(output) end)
        if ok then
            print("[Scan] Copied " .. #output .. " chars to clipboard.")
        else
            warn("[Scan] Clipboard failed: " .. tostring(err))
            print(output)
        end
    end,
})
