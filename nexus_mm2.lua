-- 🔥 NEXUS HUB: DARK OVERDRIVE EDITION 🔥
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- ====== ПЕРЕМЕННЫЕ СОСТОЯНИЙ ======
local States = {
    ESP = false,
    AutoGun = false,
    NoClip = false,
    SpeedMode = false,
    FloatButton = false,
    FloatButtonLocked = false
}

-- ====== ЛОГИКА ИГРЫ (ММ2) ======
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

-- ====== СИСТЕМА УВЕДОМЛЕНИЙ ======
local function Notify(text)
    -- Простая защита от спама в консоль, можно расширить до UI-уведомлений
    print("[NEXUS HUB]: " .. text)
end

-- ====== СТРОИМ CUSTOM DARK OVERDRIVE UI ======
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ODH_Dark_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Очистка старой версии, если скрипт перезапускается
for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui.Name == "ODH_Dark_UI" and gui ~= ScreenGui then gui:Destroy() end
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 320)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22) -- Тёмный фон
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Позволяет таскать окно
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Боковая панель (Sidebar)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 8)
SidebarCorner.Parent = Sidebar

local SidebarCover = Instance.new("Frame") -- Убираем скругление справа у сайдбара
SidebarCover.Size = UDim2.new(0, 10, 1, 0)
SidebarCover.Position = UDim2.new(1, -10, 0, 0)
SidebarCover.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
SidebarCover.BorderSizePixel = 0
SidebarCover.Parent = Sidebar

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 50)
Logo.BackgroundTransparency = 1
Logo.Text = "NEXUS HUB"
Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
Logo.Font = Enum.Font.GothamBlack
Logo.TextSize = 20
Logo.Parent = Sidebar

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0.8, 0, 0, 1)
Divider.Position = UDim2.new(0.1, 0, 0, 50)
Divider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Divider.BorderSizePixel = 0
Divider.Parent = Sidebar

-- Контейнер для контента
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -170, 1, -20)
Content.Position = UDim2.new(0, 165, 0, 10)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
Content.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = Content

-- ====== ФУНКЦИЯ СОЗДАНИЯ TOGGLE (КАК В OVERDRIVE) ======
local function CreateToggle(text, stateKey, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    ToggleFrame.Parent = Content
    
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 6)
    TCorner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local SwitchBtn = Instance.new("TextButton")
    SwitchBtn.Size = UDim2.new(0, 40, 0, 20)
    SwitchBtn.Position = UDim2.new(1, -50, 0.5, -10)
    SwitchBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    SwitchBtn.Text = ""
    SwitchBtn.Parent = ToggleFrame
    
    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(1, 0)
    SCorner.Parent = SwitchBtn
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 16, 0, 16)
    Indicator.Position = UDim2.new(0, 2, 0.5, -8)
    Indicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Indicator.Parent = SwitchBtn
    
    local ICorner = Instance.new("UICorner")
    ICorner.CornerRadius = UDim.new(1, 0)
    ICorner.Parent = Indicator
    
    local function UpdateVisuals()
        if States[stateKey] then
            SwitchBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 255) -- Фиолетовый активный цвет
            Indicator.Position = UDim2.new(1, -18, 0.5, -8)
        else
            SwitchBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            Indicator.Position = UDim2.new(0, 2, 0.5, -8)
        end
    end
    
    SwitchBtn.MouseButton1Click:Connect(function()
        States[stateKey] = not States[stateKey]
        UpdateVisuals()
        if callback then callback(States[stateKey]) end
    end)
end

local function CreateButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.Parent = Content
    
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 6)
    BCorner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(callback)
end

local function CreateLabel(text)
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -10, 0, 30)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(150, 150, 160)
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Content
end

-- ====== ПЛАВАЮЩАЯ КНОПКА SHOOT MURDERER ======
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 160, 0, 45)
FloatBtn.Position = UDim2.new(0.5, -80, 0.7, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
FloatBtn.BorderColor3 = Color3.fromRGB(150, 50, 255)
FloatBtn.BorderSizePixel = 2
FloatBtn.Text = "SHOOT MURDERER"
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.TextSize = 14
FloatBtn.Visible = false
FloatBtn.Parent = ScreenGui

local FCorner = Instance.new("UICorner")
FCorner.CornerRadius = UDim.new(0, 6)
FCorner.Parent = FloatBtn

-- Логика перетаскивания плавающей кнопки
local isDraggingBtn = false
local dragStartBtn, startPosBtn
FloatBtn.InputBegan:Connect(function(input)
    if States.FloatButtonLocked then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingBtn = true
        dragStartBtn = input.Position
        startPosBtn = FloatBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then isDraggingBtn = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isDraggingBtn and not States.FloatButtonLocked then
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStartBtn
            FloatBtn.Position = UDim2.new(startPosBtn.X.Scale, startPosBtn.X.Offset + delta.X, startPosBtn.Y.Scale, startPosBtn.Y.Offset + delta.Y)
        end
    end
end)

-- ИСПРАВЛЕННАЯ ЛОГИКА ВЫСТРЕЛА (1-Frame Snap)
local function ExecuteShoot()
    local murderer = GetMurderer()
    if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("HumanoidRootPart") then
        Notify("Murderer not found or dead.")
        return
    end

    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local gun = char and char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun"))
    
    if not gun then
        Notify("You don't have the Gun!")
        return
    end

    -- Экипируем пистолет с гарантией
    if gun.Parent == backpack then
        char.Humanoid:EquipTool(gun)
        task.wait(0.1) -- Обязательная задержка для сервера
    end

    local targetPos = murderer.Character.HumanoidRootPart.Position
    local cam = workspace.CurrentCamera
    
    -- Silent Aim (1-Frame Snap): Моментально наводим, стреляем и возвращаем камеру
    local oldCFrame = cam.CFrame
    cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos)
    
    gun:Activate() -- Активируем выстрел точно в цель
    
    RunService.RenderStepped:Wait() -- Ждем 1 кадр отрисовки
    cam.CFrame = oldCFrame -- Возвращаем камеру обратно (никто ничего не заметит)
    
    Notify("Shot fired at " .. murderer.Name)
end

FloatBtn.MouseButton1Click:Connect(ExecuteShoot)

-- ====== НАПОЛНЕНИЕ МЕНЮ ФУНКЦИЯМИ ======
CreateLabel("🗡️ COMBAT")
CreateToggle("Show Shoot Button", "FloatButton", function(val) FloatBtn.Visible = val end)
CreateToggle("Lock Shoot Button", "FloatButtonLocked", nil)
CreateButton("Force Shoot Murderer Now", ExecuteShoot)

CreateLabel("👁️ VISUALS")
CreateToggle("Player ESP (Wallhack)", "ESP", function(val)
    if not val then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("NexusESP") then p.Character.NexusESP:Destroy() end
        end
    end
end)

CreateLabel("🏃 MOVEMENT & MISC")
CreateToggle("WalkSpeed Boost (x2)", "SpeedMode", function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val and 32 or 16
    end
end)
CreateToggle("NoClip (Walk through walls)", "NoClip", nil)
CreateToggle("Auto-Teleport to Dropped Gun", "AutoGun", nil)

-- ====== ФОНОВЫЕ ЦИКЛЫ ======
RunService.RenderStepped:Connect(function()
    -- ESP Logic
    if States.ESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local hl = p.Character:FindFirstChild("NexusESP")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "NexusESP"
                    hl.FillTransparency = 0.6
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
    -- NoClip Logic
    if States.NoClip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

task.spawn(function()
    -- Auto Gun Logic
    while task.wait(0.5) do
        if States.AutoGun and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local gunDrop = workspace:FindFirstChild("GunDrop")
            if gunDrop then
                LocalPlayer.Character.HumanoidRootPart.CFrame = gunDrop.CFrame
                Notify("Teleported to dropped gun!")
                task.wait(2)
            end
        end
    end
end)

-- Toggle Menu Keybind (Right Shift)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

Notify("Loaded successfully! Press Right Shift to toggle menu.")
