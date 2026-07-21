-- NEXUS HUB: DARK OVERDRIVE V5 (FULL VERSION)
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local S = {
    ESP = false, GunESP = false, AuraGrab = false,
    NoClip = false, InfJump = false, Fly = false,
    Fullbright = false, FloatButton = true
}

local function GetRole(p)
    if not p or not p.Character then return "Innocent" end
    local function chk(c)
        if not c then return false end
        for _, i in ipairs(c:GetChildren()) do
            if i:IsA("Tool") then
                local n = i.Name:lower()
                if n:find("knife") or n:find("blade") or n:find("dagger") then return "Murderer"
                elseif n:find("gun") or n:find("revolver") then return "Sheriff" end
            end
        end
    end
    return chk(p.Character) or chk(p:FindFirstChild("Backpack")) or "Innocent"
end

local function GetMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if GetRole(p) == "Murderer" then return p end
    end
end

local function GetSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if GetRole(p) == "Sheriff" then return p end
    end
end

local function GetGunDrop()
    return workspace:FindFirstChild("GunDrop")
end

local function Notify(t)
    print("[NEXUS HUB]: " .. t)
end

local SG = Instance.new("ScreenGui")
SG.Name = "NexusHub_V5"
SG.ResetOnSpawn = false
SG.Parent = CoreGui

for _, g in ipairs(CoreGui:GetChildren()) do
    if g.Name == "NexusHub_V5" and g ~= SG then g:Destroy() end
end

local ToggleBtn = Instance.new("TextButton", SG)
ToggleBtn.Size = UDim2.new(0, 58, 0, 58)
ToggleBtn.Position = UDim2.new(0, 20, 0.35, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
ToggleBtn.Text = "NEXUS"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 180)
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 11
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 540, 0, 340)
MF.Position = UDim2.new(0.5, -270, 0.5, -170)
MF.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
MF.Active = true
MF.Draggable = true
Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 12)

ToggleBtn.MouseButton1Click:Connect(function()
    MF.Visible = not MF.Visible
end)

local Content = Instance.new("ScrollingFrame", MF)
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 52)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 4
Instance.new("UIListLayout", Content).Padding = UDim.new(0, 10)

local function AddToggle(txt, key, cb)
    local f = Instance.new("Frame", Content)
    f.Size = UDim2.new(1, -10, 0, 42)
    f.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -65, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = txt
    lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 42, 0, 22)
    btn.Position = UDim2.new(1, -52, 0.5, -11)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame", btn)
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = UDim2.new(0, 2, 0.5, -9)
    circle.BackgroundColor3 = Color3.fromRGB(160, 160, 175)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    btn.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        circle.Position = S[key] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        btn.BackgroundColor3 = S[key] and Color3.fromRGB(0, 210, 150) or Color3.fromRGB(30, 30, 42)
        if cb then cb(S[key]) end
    end)
end

local function AddBtn(txt, cb)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    btn.Text = txt
    btn.TextColor3 = Color3.fromRGB(0, 255, 180)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(cb)
end

local function AddLbl(txt)
    local l = Instance.new("TextLabel", Content)
    l.Size = UDim2.new(1, -10, 0, 24)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(90, 200, 255)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
end

local ShootBtn = Instance.new("TextButton", SG)
ShootBtn.Size = UDim2.new(0, 160, 0, 44)
ShootBtn.Position = UDim2.new(0.5, -80, 0.58, 0)
ShootBtn.BackgroundColor3 = Color3.fromRGB(20, 15, 18)
ShootBtn.Text = "🎯 СТРЕЛЯТЬ В УБИЙЦУ"
ShootBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShootBtn.Font = Enum.Font.GothamBlack
ShootBtn.TextSize = 12
ShootBtn.Visible = true
Instance.new("UICorner", ShootBtn).CornerRadius = UDim.new(0, 10)

local function ShootAction()
    local m = GetMurderer()
    if not m or not m.Character then return Notify("Убийца не найден!") end
    local char = LP.Character
    local gun = char and char:FindFirstChild("Gun") or LP.Backpack:FindFirstChild("Gun")
    if not gun then return Notify("Нет пистолета!") end
    if gun.Parent == LP.Backpack then char.Humanoid:EquipTool(gun) task.wait(0.1) end
    local cam = workspace.CurrentCamera
    local old = cam.CFrame
    cam.CFrame = CFrame.new(cam.CFrame.Position, m.Character.HumanoidRootPart.Position)
    task.wait(0.05)
    pcall(function() gun:Activate() end)
    task.wait(0.05)
    cam.CFrame = old
    Notify("Выстрел выполнен!")
end

ShootBtn.MouseButton1Click:Connect(ShootAction)

AddLbl("⚔️ БОЕВЫЕ ФУНКЦИИ")
AddToggle("Показать кнопку стрельбы", "FloatButton", function(v) ShootBtn.Visible = v end)
AddBtn("⚡ Выстрелить в убийцу", ShootAction)

AddLbl("🔫 УПРАВЛЕНИЕ ПИСТОЛЕТОМ")
AddToggle("Авто-подбор (Aura Grab)", "AuraGrab", nil)
AddToggle("Подсветка пистолета (Gun ESP)", "GunESP", nil)

AddLbl("👁️ ВИЗУАЛЫ")
AddToggle("Подсветка игроков (ESP)", "ESP", nil)
AddToggle("Яркое освещение (Fullbright)", "Fullbright", function(v)
    Lighting.Brightness = v and 2 or 1
    Lighting.ClockTime = v and 14 or 12
end)

AddLbl("🏃 ПЕРЕДВИЖЕНИЕ И ПОЛЕТ")
AddToggle("Бесконечный прыжок", "InfJump", nil)
AddToggle("Хождение сквозь стены (NoClip)", "NoClip", nil)
AddToggle("Режим полета (Fly)", "Fly", function(v)
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if v then
        local bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bv.Name = "NexusFly"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 0, 0)
    else
        if char.HumanoidRootPart:FindFirstChild("NexusFly") then
            char.HumanoidRootPart.NexusFly:Destroy()
        end
    end
end)

AddLbl("🎯 ТЕЛЕПОРТЫ")
AddBtn("🌀 ТП к Шерифу", function()
    local s = GetSheriff()
    if s and s.Character then LP.Character.HumanoidRootPart.CFrame = s.Character.HumanoidRootPart.CFrame end
end)
AddBtn("🌀 ТП к Убийце", function()
    local m = GetMurderer()
    if m and m.Character then LP.Character.HumanoidRootPart.CFrame = m.Character.HumanoidRootPart.CFrame end
end)

RunService.RenderStepped:Connect(function()
    if S.ESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local hl = p.Character:FindFirstChild("NexusESP") or Instance.new("Highlight", p.Character)
                hl.Name = "NexusESP"
                local r = GetRole(p)
                hl.FillColor = r == "Murderer" and Color3.fromRGB(255,40,40) or (r == "Sheriff" and Color3.fromRGB(40,120,255) or Color3.fromRGB(40,255,40))
            end
        end
    end
    
    local drop = GetGunDrop()
    if S.GunESP and drop then
        local hl = drop:FindFirstChild("GunHL") or Instance.new("Highlight", drop)
        hl.Name = "GunHL"
        hl.FillColor = Color3.fromRGB(255,220,0)
    elseif drop and drop:FindFirstChild("GunHL") then
        drop.GunHL:Destroy()
    end

    if S.Fly and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local root = LP.Character.HumanoidRootPart
        local cam = workspace.CurrentCamera
        local bv = root:FindFirstChild("NexusFly")
        if bv then
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            bv.Velocity = dir * 55
        end
    end
end)

RunService.Stepped:Connect(function()
    if S.NoClip and LP.Character then
        for _, part in ipairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if S.InfJump and LP.Character then
        LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if S.AuraGrab and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local drop = GetGunDrop()
            if drop then
                local root = LP.Character.HumanoidRootPart
                local old = root.CFrame
                local part = drop:IsA("Model") and (drop:FindFirstChild("Handle") or drop:FindFirstChildWhichIsA("BasePart")) or drop
                if part then
                    pcall(function() firetouchinterest(root, part, 0) firetouchinterest(root, part, 1) end)
                    root.CFrame = part.CFrame + Vector3.new(0, 0.5, 0)
                    task.wait(0.05)
                    root.CFrame = old
                    task.wait(1.5)
                end
            end
        end
    end
end)

Notify("Nexus Hub V5 успешно загружен!")
