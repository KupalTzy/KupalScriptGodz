-- Ultimate 99 Nights in the Forest Script
-- Designed for efficiency and speed
-- Load required libraries
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua'))()
local ESP = loadstring(game:HttpGet('https://raw.githubusercontent.com/Roblox-Scripters/ESP-Library/main/ESP.lua'))()

-- Initialize GUI
local Window = Rayfield:CreateWindow({
    Name = "🔥 Ultimate 99 Nights Script",
    LoadingTitle = "Loading Efficient Automation...",
    LoadingSubtitle = "by AI Assistant",
    ConfigurationSaving = { Enabled = true, FolderName = "99Nights", FileName = "Config" },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
end)

-- Global Settings
getgenv().Settings = {
    AutoFarm = false,
    AutoBuildFire = false,
    AutoCollectChildren = false,
    WalkSpeed = 16,
    JumpPower = 50,
    NoClip = false,
    ESPEnabled = false,
    AutoStunOwl = false
}

-- Optimized Resource Detection
local function findClosestResource(resourceName)
    local closestDistance = math.huge
    local closestResource = nil
    local humanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end

    for _, item in pairs(Workspace:GetChildren()) do
        if item.Name:find(resourceName) and item:FindFirstChild("Main") then
            local distance = (humanoidRootPart.Position - item.Main.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestResource = item
            end
        end
    end
    return closestResource
end

-- Efficient Auto-Farm Loop
local function autoFarmRoutine()
    spawn(function()
        while Settings.AutoFarm and task.wait(0.5) do
            pcall(function()
                -- Priority 1: Maintain fire if enabled
                if Settings.AutoBuildFire then
                    local fireRemote = ReplicatedStorage:FindFirstChild("AddToFire")
                    if fireRemote then
                        fireRemote:FireServer()
                    end
                end

                -- Priority 2: Collect wood
                local tree = findClosestResource("Tree")
                if tree then
                    local woodRemote = ReplicatedStorage:FindFirstChild("ChopWood")
                    if woodRemote then
                        woodRemote:FireServer(tree)
                    end
                end
            end)
        end
    end)
end

-- Player Modifications
RunService.Heartbeat:Connect(function()
    pcall(function()
        local humanoid = Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Settings.WalkSpeed
            humanoid.JumpPower = Settings.JumpPower
        end
    end)
end)

-- No-Clip Toggle
RunService.Stepped:Connect(function()
    if Settings.NoClip and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- ESP for Enemies and Resources
local function updateESP()
    if not Settings.ESPEnabled then return end

    -- ESP for The Deer
    local deer = Workspace:FindFirstChild("TheDeer") or Workspace:FindFirstChild("Deer")
    if deer then
        ESP:Add(deer, { Name = "THE DEER", Color = Color3.new(1, 0, 0) })
    end

    -- ESP for The Owl
    local owl = Workspace:FindFirstChild("TheOwl") or Workspace:FindFirstChild("Owl")
    if owl then
        ESP:Add(owl, { Name = "THE OWL", Color = Color3.new(0, 0, 1) })
    end

    -- ESP for Cultists
    for _, npc in pairs(Workspace:GetChildren()) do
        if npc.Name:find("Cultist") and npc:FindFirstChild("HumanoidRootPart") then
            ESP:Add(npc, { Name = "Cultist", Color = Color3.new(1, 0.5, 0) })
        end
    end

    -- ESP for Resources
    for _, resource in pairs(Workspace:GetChildren()) do
        if resource.Name:find("Tree") or resource.Name:find("Stone") then
            ESP:Add(resource, { Name = resource.Name, Color = Color3.new(0, 1, 0) })
        end
    end
end

-- Auto-Stun for The Owl
local function autoStunRoutine()
    spawn(function()
        while Settings.AutoStunOwl and task.wait(1) do
            pcall(function()
                local owl = Workspace:FindFirstChild("TheOwl") or Workspace:FindFirstChild("Owl")
                if owl and (Character.HumanoidRootPart.Position - owl.Position).Magnitude < 50 then
                    local stunRemote = ReplicatedStorage:FindFirstChild("StunOwl")
                    if stunRemote then
                        stunRemote:FireServer()
                    end
                end
            end)
        end
    end)
end

-- GUI Setup
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local FarmSection = FarmTab:CreateSection("Resource Automation")
FarmSection:CreateToggle({
    Name = "⚡ Auto Farm Resources",
    CurrentValue = false,
    Callback = function(Value)
        Settings.AutoFarm = Value
        if Value then autoFarmRoutine() end
    end
})

FarmSection:CreateToggle({
    Name = "🔥 Auto Maintain Fire",
    CurrentValue = false,
    Callback = function(Value)
        Settings.AutoBuildFire = Value
    end
})

local PlayerTab = Window:CreateTab("Player", 4483362458)
local PlayerSection = PlayerTab:CreateSection("Movement")
PlayerSection:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 120},
    Increment = 2,
    Suffix = "studs",
    CurrentValue = 16,
    Callback = function(Value)
        Settings.WalkSpeed = Value
    end
})

PlayerSection:CreateSlider({
    Name = "Jump Power",
    Range = {50, 120},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 50,
    Callback = function(Value)
        Settings.JumpPower = Value
    end
})

PlayerSection:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Callback = function(Value)
        Settings.NoClip = Value
    end
})

local VisualTab = Window:CreateTab("Visuals", 4483362458)
local VisualSection = VisualTab:CreateSection("ESP")
VisualSection:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(Value)
        Settings.ESPEnabled = Value
        if Value then
            updateESP()
        else
            ESP:Clear()
        end
    end
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local CombatSection = CombatTab:CreateSection("Auto Defense")
CombatSection:CreateToggle({
    Name = "Auto Stun The Owl",
    CurrentValue = false,
    Callback = function(Value)
        Settings.AutoStunOwl = Value
        if Value then autoStunRoutine() end
    end
})

-- Initialize
Rayfield:Notify({
    Title = "Script Loaded",
    Content = "Ultimate 99 Nights script activated!",
    Duration = 5,
    Image = 4483362458
})

-- Continuous ESP Updates
spawn(function()
    while task.wait(2) do
        if Settings.ESPEnabled then
            updateESP()
        end
    end
end)