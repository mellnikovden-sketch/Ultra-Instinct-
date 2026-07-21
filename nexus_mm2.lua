-- Подключаем премиальную библиотеку интерфейса Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🔥 Nexus Hub | Murder Mystery 2",
   LoadingTitle = "Nexus Hub v1.0",
   LoadingSubtitle = "Premium MM2 Experience",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false -- Без ключей
})

-- Сервисы
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Переменные состояний
local espEnabled = false
local autoGrabGun = false
local silentAimMode = false

-- ====== ЛОГИКА РОЛЕЙ ======
local function GetRole(player)
    if not player or not player.Character then return "Innocent" end
    
    -- Проверка инвентаря и персонажа
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

    local role = checkItems(player.Character) or checkItems(player:FindFirstChild("Backpack"))
    return role or "Innocent"
end

local function GetMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if GetRole(player) == "Murderer" then return player end
    end
    return nil
end

-- ====== ВКЛАДКИ МЕНЮ ======
local MainTab = Window:CreateTab("🏠 Main", 4483362458)
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
local VisualsTab = Window:CreateTab("👁️ Visuals", 4483362458)

-- ИНФОРМАЦИОННАЯ ПАНЕЛЬ
local RoleLabel = MainTab:CreateLabel("Current Murderer: None")
local SheriffLabel = MainTab:CreateLabel("Current Sheriff: None")

task.spawn(function()
    while task.wait(1) do
        local murdName = "None"
        local sherName = "None"
        for _, p in ipairs(Players:GetPlayers()) do
            local role = GetRole(p)
            if role == "Murderer" then murdName = p.Name
            elseif role == "Sheriff" then sherName = p.Name end
        end
        RoleLabel:Set("Current Murderer: " .. murdName)
        SheriffLabel:Set("Current Sheriff: " .. sherName)
    end
end)

-- ====== ВХ (ESP) ======
VisualsTab:CreateToggle({
   Name = "Enable Player ESP",
   CurrentValue = false,
   Flag = "ESP_Toggle",
   Callback = function(Value)
       espEnabled = Value
       if not Value then
           -- Очистка ESP при выключении
           for _, p in ipairs(Players:GetPlayers()) do
               if p.Character and p.Character:FindFirstChild("NexusESP") then
                   p.Character.NexusESP:Destroy()
               end
           end
       end
   end,
})

RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
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
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.OutlineColor = Color3.fromRGB(255, 50, 50)
            elseif role == "Sheriff" then
                hl.FillColor = Color3.fromRGB(0, 100, 255)
                hl.OutlineColor = Color3.fromRGB(50, 150, 255)
            else
                hl.FillColor = Color3.fromRGB(0, 255, 0)
                hl.OutlineColor = Color3.fromRGB(50, 255, 50)
            end
        end
    end
end)

-- ====== COMBAT (Скрытый выстрел и Кнопка) ======
local shootButton
CombatTab:CreateToggle({
   Name = "Show Floating 'Shoot Murderer' Button",
   CurrentValue = false,
   Flag = "FloatingBtn",
   Callback = function(Value)
       if shootButton then shootButton.Visible = Value end
   end,
})

CombatTab:CreateToggle({
   Name = "Enable Silent Aim (No Camera Move)",
   CurrentValue = true,
   Flag = "SilentAim",
   Callback = function(Value)
       silentAimMode = Value
   end,
})

-- Создание плавающей кнопки
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Nexus_ShootMurdererGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

shootButton = Instance.new("TextButton")
shootButton.Name = "ShootButton"
shootButton.Size = UDim2.new(0, 180, 0, 45)
shootButton.Position = UDim2.new(0.5, -90, 0.4, 0)
shootButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
shootButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
shootButton.BorderSizePixel = 2
shootButton.Text = "SHOOT MURDERER"
shootButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shootButton.TextSize = 16
shootButton.Font = Enum.Font.GothamBold
shootButton.Visible = false
shootButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = shootButton

-- Перетаскивание кнопки
local isDragging = false
local dragStart, startPos
shootButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = shootButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then isDragging = false end
        end)
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        shootButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Логика выстрела
shootButton.MouseButton1Click:Connect(function()
    local murderer = GetMurderer()
    if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("HumanoidRootPart") then
        Rayfield:Notify({Title = "Ошибка", Content = "Убийца не найден!", Duration = 2})
        return
    end

    local char = LocalPlayer.Character
    local gun = char and char:FindFirstChild("Gun") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Gun"))
    
    if not gun then
        Rayfield:Notify({Title = "Ошибка", Content = "У тебя нет пистолета!", Duration = 2})
        return
    end

    if gun.Parent ~= char then
        char.Humanoid:EquipTool(gun)
        task.wait(0.05)
    end

    local targetPos = murderer.Character.HumanoidRootPart.Position

    if silentAimMode then
        -- Выстрел без движения камеры (Silent Aim)
        for _, v in ipairs(gun:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                if v.Name:lower():find("shoot") or v.Name:lower():find("fire") or v.Name:lower():find("gun") then
                    v:FireServer(targetPos)
                end
            end
        end
        gun:Activate()
        Rayfield:Notify({Title = "Выстрел", Content = "Silent Aim применен к " .. murderer.Name, Duration = 2})
    else
        -- Обычный аимлок (поворот камеры)
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetPos)
        gun:Activate()
    end
end)

-- ====== АВТО-ПОДБОР ОРУЖИЯ ======
MainTab:CreateToggle({
   Name = "Auto Teleport to Dropped Gun",
   CurrentValue = false,
   Flag = "AutoGun",
   Callback = function(Value)
       autoGrabGun = Value
   end,
})

task.spawn(function()
    while task.wait(0.5) do
        if autoGrabGun and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local gunDrop = workspace:FindFirstChild("GunDrop")
            if gunDrop then
                LocalPlayer.Character.HumanoidRootPart.CFrame = gunDrop.CFrame
                Rayfield:Notify({Title = "Gun Grabbed", Content = "Телепортировано к брошенному пистолету!", Duration = 2})
                task.wait(2) -- Пауза, чтобы не спамить телепортом
            end
        end
    end
end)

Rayfield:Notify({Title = "Nexus Hub Загружен", Content = "Меню активировано. Приятной игры!", Duration = 5})
