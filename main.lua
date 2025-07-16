--[[ Moonhook 🌙 Arsenal GUI
Made by sin5kk + eszkeredzon
Discord: https://discord.gg/k4n6bqbd
Key System: Moonhook2025
]]

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

-- Key System
local CorrectKey = "Moonhook2025"

local Window
local function CreateMainGUI()
    Window = Rayfield:CreateWindow({
        Name = "Moonhook 🌙 - Arsenal",
        LoadingTitle = "Moonhook 🌙",
        LoadingSubtitle = "by sin5kk + eszkeredzon",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "MoonhookArsenal",
            FileName = "ArsenalConfig"
        },
        Discord = {
            Enabled = true,
            Invite = "k4n6bqbd",
            RememberJoins = true
        },
        KeySystem = false,
    })

    local MainTab = Window:CreateTab("Main", 4483362458)

    -- Hitbox Expander
    local hitboxEnabled = false
    local originalSizes = {}

    MainTab:CreateToggle({
        Name = "Hitbox Expander (Head)",
        CurrentValue = false,
        Callback = function(Value)
            hitboxEnabled = Value
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                    local head = v.Character.Head
                    if Value then
                        originalSizes[v.Name] = head.Size
                        head.Size = Vector3.new(10, 10, 10)
                        head.Transparency = 0.7
                        head.Material = Enum.Material.Neon
                    else
                        if originalSizes[v.Name] then
                            head.Size = originalSizes[v.Name]
                            head.Transparency = 0
                            head.Material = Enum.Material.Plastic
                        end
                    end
                end
            end
        end,
    })

    -- Silent Aim Placeholder (logic handled externally)
    MainTab:CreateParagraph({
        Title = "Silent Aim",
        Content = "Silent Aim is auto-enabled when target is within line of sight (WIP)"
    })

    -- Infinite Ammo
    MainTab:CreateButton({
        Name = "Infinite Ammo",
        Callback = function()
            local lp = game.Players.LocalPlayer
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" and rawget(v, "Ammo") then
                    v.Ammo = math.huge
                end
            end
        end
    })

    -- Kill All
    MainTab:CreateButton({
        Name = "Kill All (Enemies Only)",
        Callback = function()
            local Players = game:GetService("Players")
            local lp = Players.LocalPlayer
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= lp and v.Team ~= lp.Team and v.Character and v.Character:FindFirstChild("Head") then
                    game:GetService("ReplicatedStorage").Events.HitPart:FireServer(
                        v.Character.Head,
                        v.Character.Head.Position,
                        999,
                        "Head",
                        v
                    )
                end
            end
        end
    })

    -- Walkspeed & JumpPower
    MainTab:CreateSlider({
        Name = "WalkSpeed",
        Range = {16, 100},
        Increment = 1,
        CurrentValue = 16,
        Callback = function(Value)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end,
    })

    MainTab:CreateSlider({
        Name = "JumpPower",
        Range = {50, 150},
        Increment = 1,
        CurrentValue = 50,
        Callback = function(Value)
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end,
    })

    -- Fly/Noclip
    local flying = false
    MainTab:CreateToggle({
        Name = "Toggle Fly (F Key)",
        CurrentValue = false,
        Callback = function(Value)
            flying = Value
        end,
    })

    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.F and flying then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.PlatformStand = not humanoid.PlatformStand
            end
        end
    end)

    -- Credit
    MainTab:CreateParagraph({
        Title = "Credits",
        Content = "Made by sin5kk + eszkeredzon\nDiscord: discord.gg/k4n6bqbd"
    })
end

-- Key UI
local InputUI = Rayfield:CreateWindow({
    Name = "Moonhook 🌙 Unlock",
    LoadingTitle = "Moonhook 🌙 Key System",
    LoadingSubtitle = "Enter Key to Unlock",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

local Unlocked = false
InputUI:CreateInput({
    Name = "Enter Unlock Key",
    PlaceholderText = "Type here...",
    RemoveTextAfterFocusLost = false,
    Callback = function(input)
        if input == CorrectKey then
            Unlocked = true
            Rayfield:Notify({
                Title = "Key Accepted!",
                Content = "Welcome to Moonhook 🌙 Arsenal GUI.",
                Duration = 4
            })
            wait(1)
            InputUI:Destroy()
            CreateMainGUI()
        else
            Rayfield:Notify({
                Title = "Invalid Key",
                Content = "Try again. Key is case-sensitive.",
                Duration = 3
            })
        end
    end
})
