-- 🔥 NEXUS HUB: DARK OVERDRIVE V2.1 (FIXED & EXPANDED) 🔥
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local States = {
    ESP = false,
    AutoGun = false,
    AuraGrab = false,
    NoClip = false,
    InfJump = false,
    FloatButton = true,
    FloatButtonLocked = false
}

-- ====== УТИЛИТЫ И РОЛИ ММ2 ======
local function GetRole(player)
    if not player or not player.Character then return "Innocent" end
    local function checkItems(container)
        if not container then return false end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("knife") or name:find("blade") or name:find("dagger") or name:find("pitchfork") then
                    return "Murderer"
                elseif name:find("gun") or name:find("revolver") or name:find("laser") then
                    return "Sheriff"
                end
            end
        end
        return nil
    end
    return checkItems(player.Character) or checkItems(player:FindFirstChild("Backpack")) or "Innocent"
end

local function GetMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if GetRole(p) == "Murderer" then return p end
    end
    return nil
end

local function GetSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if GetRole(p) == "Sheriff" then return p end
    end
    return nil
end

-- Надежное получение координат упавшего пистолета (Исправление багов MM2)
local function GetGunDropCFrame()
    local drop = workspace:FindFirstChild("GunDrop")
    if not drop then return nil end
    
    if drop:IsA("BasePart") then
        return drop.CFrame
    elseif drop:IsA("Model") then
        local handle = drop:FindFirstChild("Handle") or drop:FindFirstChildWhichIsA("BasePart")
        if handle then return handle.CFrame end
        
        local success, pivot = pcall(function() return drop:GetPivot() end)
        if success and pivot then return pivot end
    end
    return nil
end

local function Notify(text)
    print("[NEXUS HUB]: " + text)
end

-- ====== ГЛАВНЫЙ ИНТЕРФЕЙС (DARK OVERDRIVE STYLE) ======
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ODH_Dark_V2_Fixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui.Name == "ODH_Dark_V2_Fixed" and gui ~= ScreenGui then gui:Destroy() end
end

-- Круглая неоновая полупрозрачная кнопка меню
local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Size = UDim2.new(0, 60, 0, 60)
ToggleMenuBtn.Position = UDim2.new(0, 20, 0.4, 0)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ToggleMenuBtn.BackgroundTransparency = 0.3
ToggleMenuBtn.BorderColor3 = Color3.fromRGB(0, 255, 200)
ToggleMenuBtn.BorderSizePixel = 2
ToggleMenuBtn.Text = "HUB"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
ToggleMenuBtn.Font = Enum.Font.GothamBlack
ToggleMenuBtn.TextSize = 14
ToggleMenuBtn.Parent = ScreenGui

local TMB_Corner = Instance.new("UICorner")
TMB_Corner.CornerRadius = UDim.new(1, 0)
TMB_Corner.Parent = ToggleMenuBtn

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 255, 200)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.3
UIStroke.Parent = ToggleMenuBtn

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 360)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

ToggleMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Перетаскивание круглой кнопки
local draggingMenuBtn = false
local dragStartMB, startPosMB
ToggleMenuBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMenuBtn = true
        dragStartMB = input.Position
        startPosMB = ToggleMenuBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingMenuBtn = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingMenuBtn and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartMB
        ToggleMenuBtn.Position = UDim2.new(startPosMB.X.Scale, startPosMB.X.Offset + delta.X, startPosMB.Y.Scale, startPosMB.Y.Offset + delta.Y)
    end
end)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Сайдбар
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SCorner = Instance.new("UICorner")
SCorner.CornerRadius = UDim.new(0, 10)
SCorner.Parent = Sidebar

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 50)
Logo.BackgroundTransparency = 1
Logo.Text = "OVERDRIVE V2"
Logo.TextColor3 = Color3.fromRGB(0, 255, 200)
Logo.Font = Enum.Font.GothamBlack
Logo.TextSize = 14
Logo.Parent = Sidebar

-- Контейнер контента
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -165, 1, -20)
Content.Position = UDim2.new(0, 160, 0, 10)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
Content.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Content

-- ====== UI ВСПОМОГАТЕЛЬНЫЕ КОМПОНЕНТЫ ======
local function CreateToggle(text, stateKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 38)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Frame.Parent = Content
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 210)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 38, 0, 20)
    Btn.Position = UDim2.new(1, -48, 0.5, -10)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Btn.Text = ""
    Btn.Parent = Frame
    
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(1, 0)
    BCorner.Parent = Btn
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = UDim2.new(0, 2, 0.5, -8)
    Circle.BackgroundColor3 = Color3.fromRGB(180, 180, 190)
    Circle.Parent = Btn
    
    local CCorn = Instance.new("UICorner")
    CCorn.CornerRadius = UDim.new(1, 0)
    CCorn.Parent = Circle
    
    local function Update()
        if States[stateKey] then
            Btn.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
            Circle.Position = UDim2.new(1, -18, 0.5, -8)
        else
            Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            Circle.Position = UDim2.new(0, 2, 0.5, -8)
        end
    end
    
    Btn.MouseButton1Click:Connect(function()
        States[stateKey] = not States[stateKey]
        Update()
        if callback then callback(States[stateKey]) end
    end)
end

local function CreateButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(0, 255, 200)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.Parent = Content
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(callback)
end

local function CreateLabel(text)
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -10, 0, 25)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(0, 255, 200)
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Content
end

-- ====== ПЛАВАЮЩАЯ КНОПКА СТРЕЛЬБЫ ======
local ShootFloatBtn = Instance.new("TextButton")
ShootFloatBtn.Size = UDim2.new(0, 170, 0, 45)
ShootFloatBtn.Position = UDim2.new(0.5, -85, 0.65, 0)
ShootFloatBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ShootFloatBtn.BorderColor3 = Color3.fromRGB(255, 50, 50)
ShootFloatBtn.BorderSizePixel = 2
ShootFloatBtn.Text = "SHOOT MURDERER"
ShootFloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShootFloatBtn.Font = Enum.Font.GothamBlack
ShootFloatBtn.TextSize = 13
ShootFloatBtn.Visible = false
ShootFloatBtn.Parent = ScreenGui

local SFBCorner = Instance.new("UICorner")
SFBCorner.CornerRadius = UDim.new(0, 8)
SFBCorner.Parent = ShootFloatBtn

local isDraggingSFB = false
local dragStartSFB, startPosSFB
ShootFloatBtn.InputBegan:Connect(function(input)
    if States.FloatButtonLocked then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSFB = true
        dragStartSFB = input.Position
        startPosSFB = ShootFloatBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then isDraggingSFB = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isDraggingSFB and not States.FloatButtonLocked then
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStartSFB
            ShootFloatBtn.Position = UDim2.new(startPosSFB.X.Scale, startPosSFB.X.Offset + delta.X, startPosSFB.Y.Scale, startPosSFB.Y.Offset + delta.Y)
        end
    end
end)

-- МЕХАНИЗМ ВЫСТРЕЛА
local function ExecuteShoot()
    local murderer = GetMurderer()
    if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("HumanoidRootPart") then
        Notify("Убийца не найден!")
        return
    end

    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local gun = char and char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun"))
    
    if not gun then
        Notify("У тебя нет пистолета!")
        return
    end

    if gun.Parent == backpack then
        char.Humanoid:EquipTool(gun)
        task.wait(0.12)
    end

    local targetPos = murderer.Character.HumanoidRootPart.Position
    local cam = workspace.CurrentCamera
    local oldCFrame = cam.CFrame
    
    cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos)
    gun:Activate()
    RunService.RenderStepped:Wait()
    cam.CFrame = oldCFrame
    
    Notify("Выстрел по: " + murderer.Name)
end

ShootFloatBtn.MouseButton1Click:Connect(ExecuteShoot)

-- ФУНКЦИЯ ПОДБОРА ПИСТОЛЕТА (GRAB GUN)
local function GrabGunFunction()
    local gunCF = GetGunDropCFrame()
    if gunCF and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local oldPos = LocalPlayer.Character.HumanoidRootPart.CFrame
        LocalPlayer.Character.HumanoidRootPart.CFrame = gunCF + Vector3.new(0, 2, 0)
        task.wait(0.1)
        LocalPlayer.Character.HumanoidRootPart.CFrame = oldPos
        Notify("Пистолет успешно подобран!")
    else
        Notify("Пистолет на карте не найден!")
    end
end

-- ====== НАПОЛНЕНИЕ МЕНЮ ФУНКЦИЯМИ ======
CreateLabel("⚔️ COMBAT & WEAPON")
CreateToggle("Show Shoot Button", "FloatButton", function(val) ShootFloatBtn.Visible = val end)
CreateButton("⚡ Instant Shoot Murderer", ExecuteShoot)

CreateLabel("🔫 GUN UTILITIES")
CreateButton("🎯 Grab Gun (Teleport to Drop)", GrabGunFunction)
CreateToggle("Aura Grab Gun (Auto-Grab Drop)", "AuraGrab", nil)

CreateLabel("👁️ VISUALS & ESP")
CreateToggle("Player ESP (Roles Highlight)", "ESP", function(val)
    if not val then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("NexusESP") then p.Character.NexusESP:Destroy() end
        end
    end
end)

CreateLabel("🏃 MOVEMENT & MISC")
CreateToggle("WalkSpeed Boost (2x)", "WalkSpeedToggle", function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val and 32 or 16
    end
end)
CreateToggle("Infinite Jump", "InfJump", nil)
CreateToggle("NoClip (Walk through walls)", "NoClip", nil)

CreateLabel("🎯 TELEPORTS")
CreateButton("Teleport to Sheriff", function()
    local sher = GetSheriff()
    if sher and sher.Character and sher.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = sher.Character.HumanoidRootPart.CFrame
    else
        Notify("Шериф не найден!")
    end
end)
CreateButton("Teleport to Murderer", function()
    local murd = GetMurderer()
    if murd and murd.Character and murd.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = murd.Character.HumanoidRootPart.CFrame
    else
        Notify("Убийца не найден!")
    end
end)

-- ====== ИГРОВЫЕ ЦИКЛЫ ======
RunService.RenderStepped:Connect(function()
    -- ESP Loop
    if States.ESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local hl = p.Character:FindFirstChild("NexusESP")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "NexusESP"
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    hl.Parent = p.Character
                end
                
                local role = GetRole(p)
                if role == "Murderer" then
                    hl.FillColor = Color3.fromRGB(255, 30, 30)
                    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                elseif role == "Sheriff" then
                    hl.FillColor = Color3.fromRGB(30, 100, 255)
                    hl.OutlineColor = Color3.fromRGB(0, 50, 255)
                else
                    hl.FillColor = Color3.fromRGB(30, 255, 30)
                    hl.OutlineColor = Color3.fromRGB(0, 255, 0)
                end
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    -- NoClip Loop
    if States.NoClip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    -- Infinite Jump Loop
    if States.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Aura Grab & Auto Grab Gun Loop (Мгновенный перехват пистолета)
task.spawn(function()
    while task.wait(0.15) do
        if States.AuraGrab and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local gunCF = GetGunDropCFrame()
            if gunCF then
                local rootPart = LocalPlayer.Character.HumanoidRootPart
                local oldPos = rootPart.CFrame
                rootPart.CFrame = gunCF + Vector3.new(0, 1, 0)
                task.wait(0.05)
                rootPart.CFrame = oldPos
                task.wait(1) -- Задержка, чтобы не спамить телепорт после подбора
            end
        end
    end
end)

Notify("Overdrive V2.1 Ultimate успешно загружен!")
