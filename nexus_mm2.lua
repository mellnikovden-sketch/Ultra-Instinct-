-- =======================================================
-- ЗАГРУЗЧИК С СИСТЕМНОЙ ПРОВЕРКОЙ (В стиле YARHM)
-- =======================================================
local src = ""
local StarterGui = game:GetService("StarterGui")

pcall(function() 
    src = game:HttpGet("https://yarhm.com", false)
end)

if src == "" then
  pcall(function()
      StarterGui:SetCore("SendNotification", {
          Title = "Nexus Hub // Connection";
          Text = "Основной сервер недоступен. Запуск автономного ядра Overdrive.";
          Duration = 4;
      })
  end)
end

-- =======================================================
-- ОСНОВНОЙ СКРИПТ: NEXUS OVERDRIVE (MM2 EDITION)
-- =======================================================
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
    FloatButton = true
}

local function Notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Nexus Overdrive";
            Text = tostring(msg);
            Duration = 3;
        })
    end)
    print("[NEXUS OVERDRIVE]: " .. tostring(msg))
end

-- ====== ЛОГИКА ОПРЕДЕЛЕНИЯ РОЛЕЙ MM2 ======
local function GetRole(player)
    if not player or not player.Character then return "Innocent" end
    local function checkContainer(container)
        if not container then return nil end
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
    return checkContainer(player.Character) or checkContainer(player:FindFirstChild("Backpack")) or "Innocent"
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

-- Исправленный поиск оружия (поддерживает Revolver, Gun, Laser)
local function GetPlayerGun()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local function check(c)
        if not c then return nil end
        for _, item in ipairs(c:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("gun") or name:find("revolver") or name:find("laser") then return item end
            end
        end
        return nil
    end
    return check(char) or check(backpack)
end

-- ====== ИНТЕРФЕЙС OVERDRIVE / YARHM STYLE ======
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusOverdrive_MM2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui.Name == "NexusOverdrive_MM2" and gui ~= ScreenGui then gui:Destroy() end
end

-- Кнопка сворачивания/разворачивания меню
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 56, 0, 56)
ToggleBtn.Position = UDim2.new(0, 15, 0.35, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
ToggleBtn.Text = "NEXUS"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 10
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local TBStroke = Instance.new("UIStroke", ToggleBtn)
TBStroke.Color = Color3.fromRGB(0, 255, 170)
TBStroke.Thickness = 2

-- Главное окно
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 320)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 255, 170)
MainStroke.Transparency = 0.5
MainStroke.Thickness = 1.5

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Шапка
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ NEXUS OVERDRIVE // MM2 EDITION"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Скролл контента
local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 45)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 170)
local UIList = Instance.new("UIListLayout", Content)
UIList.Padding = UDim.new(0, 6)

local function AddCategory(text)
    local lbl = Instance.new("TextLabel", Content)
    lbl.Size = UDim2.new(1, -10, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(80, 190, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function AddToggle(text, key, cb)
    local f = Instance.new("Frame", Content)
    f.Size = UDim2.new(1, -10, 0, 38)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 36, 0, 18)
    btn.Position = UDim2.new(1, -45, 0.5, -9)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local c = Instance.new("Frame", btn)
    c.Size = UDim2.new(0, 14, 0, 14)
    c.Position = UDim2.new(0, 2, 0.5, -7)
    c.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
    Instance.new("UICorner", c).CornerRadius = UDim.new(1, 0)
    
    btn.MouseButton1Click:Connect(function()
        States[key] = not States[key]
        btn.BackgroundColor3 = States[key] and Color3.fromRGB(0, 200, 140) or Color3.fromRGB(35, 35, 48)
        c.Position = States[key] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        c.BackgroundColor3 = States[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)
        if cb then cb(States[key]) end
    end)
end

local function AddButton(text, cb)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, -10, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(0, 255, 170)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(0, 255, 170)
    s.Transparency = 0.5
    btn.MouseButton1Click:Connect(cb)
end

-- ПЛАВАЮЩАЯ КНОПКА СТРЕЛЬБЫ В УБИЙЦУ
local ShootFloatBtn = Instance.new("TextButton", ScreenGui)
ShootFloatBtn.Size = UDim2.new(0, 150, 0, 40)
ShootFloatBtn.Position = UDim2.new(0.5, -75, 0.58, 0)
ShootFloatBtn.BackgroundColor3 = Color3.fromRGB(30, 15, 20)
ShootFloatBtn.Text = "🎯 СТРЕЛЯТЬ В УБИЙЦУ"
ShootFloatBtn.TextColor3 = Color3.fromRGB(255, 70, 90)
ShootFloatBtn.Font = Enum.Font.GothamBlack
ShootFloatBtn.TextSize = 10
ShootFloatBtn.Visible = true
Instance.new("UICorner", ShootFloatBtn).CornerRadius = UDim.new(0, 8)
local SFBStroke = Instance.new("UIStroke", ShootFloatBtn)
SFBStroke.Color = Color3.fromRGB(255, 50, 70)
SFBStroke.Thickness = 1.5

local function ExecuteShoot()
    local murderer = GetMurderer()
    if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("HumanoidRootPart") then
        return Notify("Убийца не найден на карте!")
    end

    local gun = GetPlayerGun()
    if not gun then
        return Notify("У тебя нет оружия в руках или инвентаре!")
    end

    if gun.Parent == LocalPlayer:FindFirstChild("Backpack") then
        LocalPlayer.Character.Humanoid:EquipTool(gun)
        task.wait(0.1)
    end

    local cam = workspace.CurrentCamera
    local targetPos = murderer.Character.HumanoidRootPart.Position
    local oldCFrame = cam.CFrame
    
    cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos)
    task.wait(0.08)
    pcall(function() gun:Activate() end)
    task.wait(0.1)
    cam.CFrame = oldCFrame
    Notify("Выстрел в убийцу выполнен!")
end

ShootFloatBtn.MouseButton1Click:Connect(ExecuteShoot)

-- ИНТЕРФЕЙСНЫЕ ЭЛЕМЕНТЫ
AddCategory("⚔️ БОЙ И СТРЕЛЬБА")
AddToggle("Плавающая кнопка стрельбы", "FloatButton", function(v) ShootFloatBtn.Visible = v end)
AddButton("⚡ Выстрелить в убийцу", ExecuteShoot)

AddCategory("🔫 ОРУЖИЕ")
AddButton("🎯 Подобрать пистолет с земли", function()
    local drop = GetGunDrop()
    if drop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local r = LocalPlayer.Character.HumanoidRootPart
        local old = r.CFrame
        local part = drop:IsA("Model") and (drop:FindFirstChild("Handle") or drop:FindFirstChildWhichIsA("BasePart")) or drop
        if part then
            pcall(function() firetouchinterest(r, part, 0); firetouchinterest(r, part, 1) end)
            r.CFrame = part.CFrame + Vector3.new(0, 0.4, 0)
            task.wait(0.05); r.CFrame = old
            Notify("Пистолет подобран!")
        end
    else
        Notify("Выпавший пистолет не найден!")
    end
end)
AddToggle("Авто-подбор пистолета (Aura)", "AuraGrab", nil)
AddToggle("Подсветка выпавшего пистолета", "GunESP", nil)

AddCategory("👁️ ВИЗУАЛЫ И РОЛИ")
AddToggle("ESP Ролей (Murderer/Sheriff)", "ESP", function(v)
    if not v then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("NX_ESP") then p.Character.NX_ESP:Destroy() end
        end
    end
end)
AddToggle("Полное освещение (Fullbright)", "Fullbright", function(v)
    Lighting.Brightness = v and 2 or 1
    Lighting.ClockTime = v and 14 or 12
    Lighting.GlobalShadows = not v
end)

AddCategory("🏃 ПЕРЕДВИЖЕНИЕ")
AddToggle("Бесконечный прыжок (Inf Jump)", "InfJump", nil)
AddToggle("Ходить сквозь стены (NoClip)", "NoClip", nil)
AddToggle("Режим полета (Fly)", "Fly", function(v)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if v then
        local bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bv.Name = "NX_Fly"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 0, 0)
    else
        if char.HumanoidRootPart:FindFirstChild("NX_Fly") then char.HumanoidRootPart.NX_Fly:Destroy() end
    end
end)

-- ГЛОБАЛЬНЫЕ ЦИКЛЫ
RunService.RenderStepped:Connect(function()
    if States.ESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hl = p.Character:FindFirstChild("NX_ESP") or Instance.new("Highlight", p.Character)
                hl.Name = "NX_ESP"
                local r = GetRole(p)
                if r == "Murderer" then
                    hl.FillColor = Color3.fromRGB(255, 40, 40)
                    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                elseif r == "Sheriff" then
                    hl.FillColor = Color3.fromRGB(40, 120, 255)
                    hl.OutlineColor = Color3.fromRGB(0, 80, 255)
                else
                    hl.FillColor = Color3.fromRGB(40, 255, 40)
                    hl.OutlineColor = Color3.fromRGB(0, 255, 0)
                end
            end
        end
    end

    local drop = GetGunDrop()
    if States.GunESP and drop then
        local hl = drop:FindFirstChild("NX_GunHL") or Instance.new("Highlight", drop)
        hl.Name = "NX_GunHL"
        hl.FillColor = Color3.fromRGB(255, 220, 0)
    elseif not States.GunESP and drop and drop:FindFirstChild("NX_GunHL") then
        drop.NX_GunHL:Destroy()
    end

    if States.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local r = LocalPlayer.Character.HumanoidRootPart
        local cam = workspace.CurrentCamera
        local bv = r:FindFirstChild("NX_Fly")
        if bv then
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            bv.Velocity = dir * 60
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

task.spawn(function()
    while task.wait(0.3) do
        if States.AuraGrab and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local drop = GetGunDrop()
            if drop then
                local r = LocalPlayer.Character.HumanoidRootPart
                local old = r.CFrame
                local part = drop:IsA("Model") and (drop:FindFirstChild("Handle") or drop:FindFirstChildWhichIsA("BasePart")) or drop
                if part then
                    pcall(function() firetouchinterest(r, part, 0); firetouchinterest(r, part, 1) end)
                    r.CFrame = part.CFrame + Vector3.new(0, 0.4, 0)
                    task.wait(0.05); r.CFrame = old
                    task.wait(1.5)
                end
            end
        end
    end
end)

Notify("Nexus Overdrive MM2 успешно запущен!")
