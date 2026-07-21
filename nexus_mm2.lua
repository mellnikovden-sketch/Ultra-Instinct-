-- 🔥 NEXUS HUB: DARK OVERDRIVE V5 (ULTRA DESIGN & MOBILE FLY FIXED) 🔥
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local States = {
    ESP = false,
    GunESP = false,
    AuraGrab = false,
    NoClip = false,
    InfJump = false,
    Fly = false,
    Fullbright = false,
    FloatButton = true,
    WalkSpeed = 16
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

local function GetGunDrop()
    return workspace:FindFirstChild("GunDrop")
end

local function Notify(text)
    print("[NEXUS HUB]: " .. text)
end

-- ====== ПРЕМИУМ ИНТЕРФЕЙС (DARK OVERDRIVE V5) ======
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusHub_V5"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui.Name == "NexusHub_V5" and gui ~= ScreenGui then gui:Destroy() end
end

-- Плавающая кнопка открытия меню (Киберпанк стиль)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 58, 0, 58)
ToggleBtn.Position = UDim2.new(0, 20, 0.35, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.Text = "NEXUS"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 180)
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 11
ToggleBtn.Parent = ScreenGui

local TB_Corner = Instance.new("UICorner")
TB_Corner.CornerRadius = UDim.new(1, 0)
TB_Corner.Parent = ToggleBtn

local TB_Stroke = Instance.new("UIStroke")
TB_Stroke.Color = Color3.fromRGB(0, 255, 180)
TB_Stroke.Thickness = 2
TB_Stroke.Transparency = 0.2
TB_Stroke.Parent = ToggleBtn

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 540, 0, 340)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Перетаскивание круглой кнопки
local draggingTB, dragStartTB, startPosTB
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingTB = true
        dragStartTB = input.Position
        startPosTB = ToggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingTB = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingTB and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartTB
        ToggleBtn.Position = UDim2.new(startPosTB.X.Scale, startPosTB.X.Offset + delta.X, startPosTB.Y.Scale, startPosTB.Y.Offset + delta.Y)
    end
end)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(30, 30, 45)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Шапка окна
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

-- Исправление чтобя углы вверху не были круглыми снизу
local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 10)
TopFix.Position = UDim2.new(0, 0, 1, -10)
TopFix.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
TopFix.BorderSizePixel = 0
TopFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ NEXUS HUB // MM2 OVERDRIVE"
Title.TextColor3 = Color3.fromRGB(0, 255, 180)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Контейнер контента (скролл)
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 52)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 180)
Content.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = Content

-- ====== UI ЭЛЕМЕНТЫ ДИЗАЙНА ======
local function CreateToggle(text, stateKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 42)
    Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    Frame.Parent = Content
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(30, 30, 45)
    Stroke.Thickness = 1
    Stroke.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -65, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 42, 0, 22)
    Btn.Position = UDim2.new(1, -52, 0.5, -11)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    Btn.Text = ""
    Btn.Parent = Frame
    
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(1, 0)
    BCorner.Parent = Btn
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = UDim2.new(0, 2, 0.5, -9)
    Circle.BackgroundColor3 = Color3.fromRGB(160, 160, 175)
    Circle.Parent = Btn
    
    local CCorn = Instance.new("UICorner")
    CCorn.CornerRadius = UDim.new(1, 0)
    CCorn.Parent = Circle
    
    local function Update()
        if States[stateKey] then
            Btn.BackgroundColor3 = Color3.fromRGB(0, 210, 150)
            Circle.Position = UDim2.new(1, -20, 0.5, -9)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
            Circle.Position = UDim2.new(0, 2, 0.5, -9)
            Circle.BackgroundColor3 = Color3.fromRGB(160, 160, 175)
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
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(0, 255, 180)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.Parent = Content
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Btn
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 255, 180)
    Stroke.Transparency = 0.5
    Stroke.Thickness = 1
    Stroke.Parent = Btn
    
    Btn.MouseButton1Click:Connect(callback)
end

local function CreateLabel(text)
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -10, 0, 24)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(90, 200, 255)
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Content
end

-- ====== ПЛАВАЮЩАЯ КНОПКА СТРЕЛЬБЫ ДЛЯ ТЕЛЕФОНА ======
local ShootFloatBtn = Instance.new("TextButton")
ShootFloatBtn.Size = UDim2.new(0, 160, 0, 44)
ShootFloatBtn.Position = UDim2.new(0.5, -80, 0.58, 0)
ShootFloatBtn.BackgroundColor3 = Color3.fromRGB(20, 15, 18)
ShootFloatBtn.BorderColor3 = Color3.fromRGB(255, 50, 80)
ShootFloatBtn.BorderSizePixel = 2
ShootFloatBtn.Text = "🎯 СТРЕЛЯТЬ В УБИЙЦУ"
ShootFloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShootFloatBtn.Font = Enum.Font.GothamBlack
ShootFloatBtn.TextSize = 12
ShootFloatBtn.Visible = false
ShootFloatBtn.Parent = ScreenGui

local SFBCorner = Instance.new("UICorner")
SFBCorner.CornerRadius = UDim.new(0, 10)
SFBCorner.Parent = ShootFloatBtn

-- Перетаскивание кнопки стрельбы
local isDraggingSFB, dragStartSFB, startPosSFB
ShootFloatBtn.InputBegan:Connect(function(input)
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
    if isDraggingSFB and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartSFB
        ShootFloatBtn.Position = UDim2.new(startPosSFB.X.Scale, startPosSFB.X.Offset + delta.X, startPosSFB.Y.Scale, startPosSFB.Y.Offset + delta.Y)
    end
end)

-- ФУНКЦИЯ ВЫСТРЕЛА
local function ExecuteShoot()
    local murderer = GetMurderer()
    if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("HumanoidRootPart") then
        Notify("Убийца не найден на карте!")
        return
    end

    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local gun = char and char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun"))
    
    if not gun then
        Notify("У тебя нет пистолета в инвентаре!")
        return
    end

    if gun.Parent == backpack then
        char.Humanoid:EquipTool(gun)
        task.wait(0.1)
    end

    local cam = workspace.CurrentCamera
    local targetPos = murderer.Character.HumanoidRootPart.Position
    local oldCFrame = cam.CFrame
    
    cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos)
    task.wait(0.05)
    
    pcall(function()
        gun:Activate()
    end)
    
    task.wait(0.05)
    cam.CFrame = oldCFrame
    Notify("Выстрел произведен в убийцу!")
end

ShootFloatBtn.MouseButton1Click:Connect(ExecuteShoot)

-- ФУНКЦИЯ ПОДБОРА ПИСТОЛЕТА
local function GrabGunFunction()
    local drop = GetGunDrop()
    if drop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = LocalPlayer.Character.HumanoidRootPart
        local oldPos = rootPart.CFrame
        local targetPart = drop:IsA("Model") and (drop:FindFirstChild("Handle") or drop:FindFirstChildWhichIsA("BasePart")) or drop
        
        if targetPart then
            pcall(function()
                firetouchinterest(rootPart, targetPart, 0)
                firetouchinterest(rootPart, targetPart, 1)
            end)
            rootPart.CFrame = targetPart.CFrame + Vector3.new(0, 0.5, 0)
            task.wait(0.05)
            rootPart.CFrame = oldPos
            Notify("Пистолет успешно подобран!")
        end
    else
        Notify("Упавший пистолет не найден!")
    end
end

-- ====== СТРУКТУРА МЕНЮ ======
CreateLabel("⚔️ БОЕВЫЕ ФУНКЦИИ И ОРУЖИЕ")
CreateToggle("Показать кнопку стрельбы", "FloatButton", function(val) ShootFloatBtn.Visible = val end)
CreateButton("⚡ Выстрелить в убийцу сейчас", ExecuteShoot)

CreateLabel("🔫 УПРАВЛЕНИЕ ПИСТОЛЕТОМ")
CreateButton("🎯 Подобрать пистолет (Grab Gun)", GrabGunFunction)
CreateToggle("Авто-подбор пистолета (Aura Grab)", "AuraGrab", nil)
CreateToggle("Подсветка пистолета на карте (Gun ESP)", "GunESP", nil)

CreateLabel("👁️ ВИЗУАЛЫ И ПОДСВЕТКА РОЛЕЙ")
CreateToggle("Подсветка игроков (ESP Roles)", "ESP", function(val)
    if not val then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("NexusESP") then p.Character.NexusESP:Destroy() end
        end
    end
end)
CreateToggle("Яркое освещение (Fullbright)", "Fullbright", function(val)
    Lighting.Brightness = val and 2 or 1
    Lighting.ClockTime = val and 14 or 12
    Lighting.GlobalShadows = not val
end)

CreateLabel("🏃 ПЕРЕДВИЖЕНИЕ И ПОЛЕТ")
CreateToggle("Ускорение бега (Speed x2)", "WalkSpeedToggle", function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val and 32 or 16
    end
end)
CreateToggle("Бесконечный прыжок (Infinite Jump)", "InfJump", nil)
CreateToggle("Хождение сквозь стены (NoClip)", "NoClip", nil)
CreateToggle("Режим полета (Fly - Исправленный)", "Fly", function(val)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if val then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "NexusFlyVelocity"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = char.HumanoidRootPart
    else
        if char.HumanoidRootPart:FindFirstChild("NexusFlyVelocity") then
            char.HumanoidRootPart.NexusFlyVelocity:Destroy()
        end
    end
end)

CreateLabel("🎯 БЫСТРЫЙ ТЕЛЕПОРТ")
CreateButton("🌀 Телепорт к Шерифу", function()
    local sher = GetSheriff()
    if sher and sher.Character and sher.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = sher.Character.HumanoidRootPart.CFrame
    else
        Notify("Шериф не найден!")
    end
end)
CreateButton("🌀 Телепорт к Убийце", function()
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
                    hl.FillColor = Color3.fromRGB(255, 40, 40)
                    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                elseif role == "Sheriff" then
                    hl.FillColor = Color3.fromRGB(40, 120, 255)
                    hl.OutlineColor = Color3.fromRGB(0, 80, 255)
                else
                    hl.FillColor = Color3.fromRGB(40, 255, 40)
                    hl.OutlineColor = Color3.fromRGB(0, 255, 0)
                end
            end
        end
    end

    -- Gun ESP Loop
    local drop = GetGunDrop()
    if States.GunESP then
        if drop then
            local hl = drop:FindFirstChild("GunHighlight")
            if not hl then
                hl = Instance.new("Highlight")
                hl.Name = "GunHighlight"
                hl.FillColor = Color3.fromRGB(255, 220, 0)
                hl.OutlineColor = Color3.fromRGB(255, 160, 0)
                hl.FillTransparency = 0.3
                hl.Parent = drop
            end
        end
    else
        if drop and drop:FindFirstChild("GunHighlight") then
            drop.GunHighlight:Destroy()
        end
    end

    -- ИСПРАВЛЕННЫЙ ПОЛЕТ (Плавное движение по направлению взгляда камеры)
    if States.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        local cam = workspace.CurrentCamera
        local bv = root:FindFirstChild("NexusFlyVelocity")
        if bv then
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            
            -- Для мобилок поднимаем скорость через виртуальный контроль если нажата кнопка прыжка/вниз
            bv.Velocity = moveDir * 55
        end
    end
end)

RunService.Stepped:Connect(function()
    if States.NoClip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if States.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Aura Grab Gun Loop
task.spawn(function()
    while task.wait(0.15) do
        if States.AuraGrab and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local drop = GetGunDrop()
            if drop then
                local rootPart = LocalPlayer.Character.HumanoidRootPart
                local oldPos = rootPart.CFrame
                local targetPart = drop:IsA("Model") and (drop:FindFirstChild("Handle") or drop:FindFirstChildWhichIsA("BasePart")) or drop
                
                if targetPart then
                    pcall(function()
                        firetouchinterest(rootPart, targetPart, 0)
                        firetouchinterest(rootPart, targetPart, 1)
                    end)
                    rootPart.CFrame = targetPart.CFrame + Vector3.new(0, 0.5, 0)
                    task.wait(0.05)
                    rootPart.CFrame = oldPos
                    task.wait(1.5)
                end
            end
        end
    end
end)

Notify("Nexus Hub V5 успешно загружен!")
