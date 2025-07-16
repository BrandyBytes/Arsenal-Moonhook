local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
local hitboxEnabled = false
local hitboxSize = Vector3.new(5, 5, 5)

local aimSettings = {
    AimbotEnabled = false,
    AimPart = "Head",
    TeamCheck = true,
    WallCheck = true,
}

local visuals = {
    ESP = false,
    Tracers = false,
    Distance = false,
}

local drawings = {}

-- Hitbox Expander Function
local function ApplyHitbox()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local part = player.Character.HumanoidRootPart
            if hitboxEnabled then
                part.Size = hitboxSize
                part.Transparency = 0.7
                part.BrickColor = BrickColor.new("Bright red")
                part.Material = Enum.Material.ForceField
                part.CanCollide = false
            else
                part.Size = Vector3.new(2, 2, 1)
                part.Transparency = 1
                part.Material = Enum.Material.Plastic
                part.CanCollide = false
            end
        end
    end
end

-- Team check function
local function isEnemy(player)
    if not player.Team or not LocalPlayer.Team then
        return true
    end
    return player.Team ~= LocalPlayer.Team
end

-- Wall check function
local function canSeeTarget(targetPart)
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true

    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    if raycastResult then
        local hitPart = raycastResult.Instance
        if hitPart and hitPart:IsDescendantOf(targetPart.Parent) then
            return true -- hit target part or character
        else
            return false -- blocked by something else
        end
    else
        -- nothing hit, consider visible
        return true
    end
end

-- Get closest target with team and wall checks
local function getClosestTarget()
    local closestDistance = math.huge
    local closestPlayer = nil
    local origin = Camera.CFrame.Position

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(aimSettings.AimPart) then
            local targetPart = player.Character[aimSettings.AimPart]

            if aimSettings.TeamCheck and not isEnemy(player) then
                continue
            end

            if aimSettings.WallCheck and not canSeeTarget(targetPart) then
                continue
            end

            local distance = (targetPart.Position - origin).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

-- Visuals Update Loop
RunService.RenderStepped:Connect(function()
    -- Hide all drawings initially
    for _, drawing in pairs(drawings) do
        drawing.box.Visible = false
        drawing.line.Visible = false
        drawing.text.Visible = false
    end

    if visuals.ESP or visuals.Tracers or visuals.Distance then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
                local hrp = player.Character.HumanoidRootPart
                local head = player.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                if not drawings[player] then
                    drawings[player] = {
                        box = Drawing.new("Square"),
                        line = Drawing.new("Line"),
                        text = Drawing.new("Text")
                    }
                    drawings[player].box.Color = Color3.new(1, 0, 0)
                    drawings[player].box.Thickness = 1
                    drawings[player].box.Filled = false

                    drawings[player].line.Color = Color3.new(1, 1, 1)
                    drawings[player].line.Thickness = 1

                    drawings[player].text.Color = Color3.new(1, 1, 1)
                    drawings[player].text.Size = 14
                    drawings[player].text.Center = true
                end

                local drawing = drawings[player]

                if onScreen then
                    -- REGULAR fixed box size - no scaling with distance
                    local boxWidth = 50
                    local boxHeight = 80
                    local boxPos = Vector2.new(screenPos.X - boxWidth / 2, screenPos.Y - boxHeight / 2)

                    if visuals.ESP then
                        drawing.box.Position = boxPos
                        drawing.box.Size = Vector2.new(boxWidth, boxHeight)
                        drawing.box.Visible = true
                    end

                    if visuals.Tracers then
                        drawing.line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        drawing.line.To = Vector2.new(screenPos.X, screenPos.Y)
                        drawing.line.Visible = true
                    end

                    if visuals.Distance then
                        local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                        drawing.text.Position = Vector2.new(screenPos.X, screenPos.Y - boxHeight / 2 - 10)
                        drawing.text.Text = tostring(distance) .. "m"
                        drawing.text.Visible = true
                    end
                end
            end
        end
    end
end)

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    if aimSettings.AimbotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(aimSettings.AimPart) then
            local targetPart = target.Character[aimSettings.AimPart]
            -- Aim at the target part
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
        end
    end
end)

-- GUI Setup
local Window = Rayfield:CreateWindow({
   Name = "Moonhook🌙arsenal",
   LoadingTitle = "Moonhook Loading",
   LoadingSubtitle = "by Rayfield",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "MoonhookConfigs",
      FileName = "MainUI"
   },
   Discord = {
      Enabled = true,
      Invite = "sEzR2fhP",
      RememberJoins = true,
   },
   KeySystem = false
})

-- Main Tab
local MainTab = Window:CreateTab("Main", 4483362458)
MainTab:CreateSection("Credits")
MainTab:CreateLabel("sin5kk + eszkeredzon")
MainTab:CreateSection("Main Controls")
MainTab:CreateButton({
   Name = "Activate Something",
   Callback = function()
      print("Button Pressed in Main")
   end,
})
MainTab:CreateInput({
    Name = "Discord Invite",
    PlaceholderText = "https://discord.gg/sEzR2fhP",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        print("Discord Invite:", text)
    end,
})

-- Aim Tab
local AimTab = Window:CreateTab("Aim", 4483362458)
AimTab:CreateSection("Aimbot Settings")
AimTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(value)
        aimSettings.AimbotEnabled = value
    end,
})
AimTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "HumanoidRootPart", "UpperTorso"},
    CurrentOption = "Head",
    Callback = function(option)
        aimSettings.AimPart = option
    end,
})
AimTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(value)
        aimSettings.TeamCheck = value
    end,
})
AimTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = true,
    Callback = function(value)
        aimSettings.WallCheck = value
    end,
})

-- Combat Tab
local CombatTab = Window:CreateTab("Combat", 4483362458)
CombatTab:CreateSection("Combat Tools")
CombatTab:CreateButton({
   Name = "Kill All",
   Callback = function()
      print("Kill All Executed")
   end,
})
CombatTab:CreateToggle({
   Name = "Hitbox Expander",
   CurrentValue = false,
   Callback = function(Value)
      hitboxEnabled = Value
      ApplyHitbox()
   end,
})
CombatTab:CreateSlider({
   Name = "Hitbox Size",
   Range = {2, 25},
   Increment = 1,
   Suffix = "Size",
   CurrentValue = 5,
   Callback = function(Value)
      hitboxSize = Vector3.new(Value, Value, Value)
      if hitboxEnabled then
         ApplyHitbox()
      end
   end,
})

-- Movement Tab
local MovementTab = Window:CreateTab("Movement", 4483362458)
MovementTab:CreateSection("Speed & Jump")
MovementTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 100},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Callback = function(Value)
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})
MovementTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 150},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Callback = function(Value)
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.JumpPower = Value
      end
   end,
})

-- Visuals Tab
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
VisualsTab:CreateSection("ESP & Tracers")
VisualsTab:CreateToggle({
   Name = "ESP Boxes",
   CurrentValue = false,
   Callback = function(Value)
      visuals.ESP = Value
   end,
})
VisualsTab:CreateToggle({
   Name = "Tracers",
   CurrentValue = false,
   Callback = function(Value)
      visuals.Tracers = Value
   end,
})
VisualsTab:CreateToggle({
   Name = "Distance Labels",
   CurrentValue = false,
   Callback = function(Value)
      visuals.Distance = Value
   end,
})

-- Settings Tab
local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateSection("Configuration")
SettingsTab:CreateKeybind({
   Name = "Toggle UI",
   CurrentKeybind = "RightControl",
   HoldToInteract = false,
   Callback = function()
      Rayfield:Toggle()
   end,
})
SettingsTab:CreateInput({
   Name = "Config Name",
   PlaceholderText = "Enter config name...",
   RemoveTextAfterFocusLost = true,
   Callback = function(text)
      print("Saved as:", text)
   end,
})