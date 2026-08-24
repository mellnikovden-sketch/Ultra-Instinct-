-- MM2 Murderer Aim Lock V2.6 (ABSOLUTE HARD LOCK) + BIND BUTTON
-- STANDALONE VERSION (без odh_shared_plugins)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ==============================================
-- СОЗДАНИЕ ГЛАВНОГО GUI
-- ==============================================
local function CreateMainGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MM2_AimLock_GUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local parent = CoreGui
    pcall(function()
        parent = gethui and gethui() or CoreGui
    end)
    gui.Parent = parent
    return gui
end

local MainGUI = CreateMainGUI()

-- ==============================================
-- MAID (для очистки)
-- ==============================================
local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({_tasks = {}, _destroyed = false}, Maid)
end

function Maid:GiveTask(task)
    if self._destroyed then self:_cleanupTask(task) return end
    table.insert(self._tasks, task)
    return task
end

function Maid:GiveTasks(...)
    for _, t in ipairs({...}) do self:GiveTask(t) end
end

function Maid:_cleanupTask(task)
    local t = typeof(task)
    if t == "RBXScriptConnection" then task:Disconnect()
    elseif t == "Instance" then task:Destroy()
    elseif t == "function" then task()
    elseif t == "table" and type(task.Destroy) == "function" then task:Destroy()
    end
end

function Maid:DoCleaning()
    if self._destroyed then return end
    self._destroyed = true
    for _, task in ipairs(self._tasks) do self:_cleanupTask(task) end
    self._tasks = {}
end

function Maid:Destroy() self:DoCleaning() end

local RootMaid = Maid.new()

-- ==============================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ КНОПОК
-- ==============================================
local function getfserv(s)
    local ok, svc = pcall(function() return game:GetService(s) end)
    if ok and svc then return svc end
    ok, svc = pcall(function() return game:FindService(s) end)
    if ok and svc then return svc end
    return game[s]
end

local __RS   = getfserv("RunService")
local __UIS  = getfserv("UserInputService")
local __PLRS = getfserv("Players")
local __TS   = getfserv("TweenService")

local __UD2 = UDim2.new
local __UD  = UDim.new
local __V2  = Vector2.new
local __PCLR = Color3.new
local __RGB  = Color3.fromRGB

-- ==============================================
-- BINDABLE BUTTONS
-- ==============================================
local BindableButtons = {Buttons = {}, Maids = {}, Count = 0}

local __SHAPES = {
    [0] = "rbxassetid://86221076925479",
    [1] = "rbxassetid://96242665417546",
    [2] = "rbxassetid://97129189935336",
    [3] = "rbxassetid://76165862027868",
    [4] = "rbxassetid://125868092127496"
}

local __NORMAL_COLOR = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   __PCLR(0.133333, 0.827451, 0.494118)),
    ColorSequenceKeypoint.new(0.6, __PCLR(0.231373, 0.509804, 0.498039)),
    ColorSequenceKeypoint.new(1,   __PCLR(0.501961, 0.501961, 0.501961))
})

local __ACTIVE_COLOR = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   __PCLR(0.0, 0.8, 0.4)),
    ColorSequenceKeypoint.new(0.6, __PCLR(0.0, 0.5, 0.3)),
    ColorSequenceKeypoint.new(1,   __PCLR(0.2, 0.8, 0.6))
})

local muteButtonSounds = false

local function bind_safecallback(callback)
    if not callback then return end
    local ok, err = xpcall(callback, function(e) return debug.traceback(e) end)
    if not ok then warn("[BIND ERROR] " .. tostring(err)) end
end

local function Bind_GetStorage()
    local parent = gethui and gethui()
    if not parent or typeof(parent) ~= "Instance" then parent = CoreGui end
    if not parent or typeof(parent) ~= "Instance" then
        parent = __PLRS.LocalPlayer:WaitForChild("PlayerGui", 5)
    end
    if typeof(parent) ~= "Instance" then
        parent = __PLRS.LocalPlayer:WaitForChild("PlayerGui")
    end

    local sg = parent:FindFirstChild("@bindstorage")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "@bindstorage"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        pcall(function() sg.ScreenInsets = Enum.ScreenInsets.None end)
        sg.Parent = parent
    end
    return sg
end

local function Bind_MakeDraggable(gui, maid, ripple, sound, clickFunc)
    local dragging, dragInput, dragStart, startPos
    local hasMoved = false
    
    maid:GiveTask(gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, gui.Position
            hasMoved = false
            sound:Play()
            local absPos = gui.AbsolutePosition
            ripple.Position = __UD2(0, input.Position.X - absPos.X, 0, input.Position.Y - absPos.Y)
            ripple.Size = __UD2(0, 0, 0, 0)
            ripple.BackgroundTransparency = 0.5
            ripple.Visible = true
            __TS:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Size = __UD2(0, 45, 0, 45),
                BackgroundTransparency = 1
            }):Play()

            local rel
            rel = __UIS.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == input.UserInputType then
                    dragging = false
                    if not hasMoved then
                        bind_safecallback(clickFunc)
                    end
                    rel:Disconnect()
                end
            end)
        end
    end))
    
    maid:GiveTask(gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))
    
    maid:GiveTask(__UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude > 7 then hasMoved = true end
            local screen = gui.Parent.AbsoluteSize
            gui.Position = __UD2(startPos.X.Scale + (delta.X / screen.X), 0, startPos.Y.Scale + (delta.Y / screen.Y), 0)
        end
    end))
end

function BindableButtons.AddBButton(id, text, clickFunc, isGold)
    if BindableButtons.Buttons[id] then return end
    
    local buttonMaid = Maid.new()
    local camera = workspace.CurrentCamera
    local screen = camera.ViewportSize
    local buttonSizeY = 0.11
    local widthScale = buttonSizeY * (screen.Y / screen.X)
    local xPos = 0.1 + ((BindableButtons.Count % 8) * (widthScale + 0.005))
    local yPos = 0.9 - (math.floor(BindableButtons.Count / 8) * (buttonSizeY + 0.015))

    local ImageButton = Instance.new("ImageButton")
    ImageButton.Name = id
    ImageButton.Size = __UD2(widthScale, 0, buttonSizeY, 0)
    ImageButton.Position = __UD2(xPos, 0, yPos, 0)
    ImageButton.AnchorPoint = __V2(0.5, 0.5)
    ImageButton.Image = __SHAPES[0]
    ImageButton.BackgroundTransparency = 1
    ImageButton.BorderSizePixel = 0
    ImageButton.ClipsDescendants = false
    ImageButton.AutoButtonColor = false
    ImageButton.Parent = Bind_GetStorage()
    buttonMaid:GiveTask(ImageButton)

    local TextLabel = Instance.new("TextLabel", ImageButton)
    TextLabel.Name = "@Text"
    TextLabel.Size = __UD2(0.8, 0, 0.8, 0)
    TextLabel.Position = __UD2(0.5, 0, 0.5, 0)
    TextLabel.AnchorPoint = __V2(0.5, 0.5)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font = Enum.Font.Jura
    TextLabel.Text = text
    TextLabel.TextColor3 = __PCLR(1, 1, 1)
    TextLabel.TextSize = 10
    TextLabel.TextWrapped = true
    TextLabel.ZIndex = 3

    local Aspect = Instance.new("UIAspectRatioConstraint", ImageButton)
    Aspect.AspectRatio = 1
    Aspect.AspectType = Enum.AspectType.ScaleWithParentSize

    local Stroke = Instance.new("UIGradient", ImageButton)
    Stroke.Name = "@Stroke"
    Stroke.Color = __NORMAL_COLOR

    local ripple = Instance.new("Frame")
    ripple.Name = "@ripple"
    ripple.BackgroundColor3 = __RGB(0, 155, 255)
    ripple.BackgroundTransparency = 0.5
    ripple.Size = __UD2(0, 0, 0, 0)
    ripple.AnchorPoint = __V2(0.5, 0.5)
    ripple.Visible = false
    ripple.ZIndex = 2
    ripple.Parent = ImageButton
    Instance.new("UICorner", ripple).CornerRadius = __UD(1, 0)

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://3868133279"
    sound.Volume = muteButtonSounds and 0 or 0.5
    sound.Parent = ImageButton

    Bind_MakeDraggable(ImageButton, buttonMaid, ripple, sound, clickFunc)
    buttonMaid:GiveTask(__RS.RenderStepped:Connect(function()
        Stroke.Rotation = (Stroke.Rotation + 1) % 360
    end))

    BindableButtons.Buttons[id] = ImageButton
    BindableButtons.Maids[id] = buttonMaid
    BindableButtons.Count = BindableButtons.Count + 1
    return ImageButton
end

function BindableButtons.DeleteBButton(id)
    if BindableButtons.Maids[id] then
        BindableButtons.Maids[id]:Destroy()
        BindableButtons.Maids[id] = nil
        BindableButtons.Buttons[id] = nil
    end
end

function BindableButtons.UpdateBButtonText(id, text, isWaiting, isGold)
    local btn = BindableButtons.Buttons[id]
    if not btn then return end
    
    local textLabel = btn:FindFirstChild("@Text")
    if textLabel then
        textLabel.Text = text
    end
    
    local stroke = btn:FindFirstChild("@Stroke")
    if stroke then
        if isWaiting then
            stroke.Color = __WAIT_COLOR
        else
            stroke.Color = __ACTIVE_COLOR
        end
    end
end

-- ==============================================
-- НАСТРОЙКИ AIMLOCK
-- ==============================================
local AimLockEnabled = false
local TargetPart = "HumanoidRootPart"
local TargetPlayer = nil
local WallCheckEnabled = false
local ShowBindableButton = true
local bindButtonSize = 0.11
local PredictionLevel = 0.2

local LastSearchTime = 0
local LastWallCheckTime = 0
local IsTargetVisibleCache = false
local WALL_CHECK_INTERVAL = 0.15 

local InvisibleTimer = 0
local MAX_INVISIBLE_TIME = 0.5

local MurdererWeapons = {
    "knife", "blade", "dagger", "saw", "slasher", "axe", 
    "scythe", "peppermint", "cookie", "edge", "batwing", 
    "icewing", "bone", "hallow", "vampire", "cutter"
}

-- ==============================================
-- ФУНКЦИИ ПОИСКА И ВИДИМОСТИ
-- ==============================================
function IsVisible(target)
    if not target or not target.Character then return false end
    local p = target.Character:FindFirstChild(TargetPart)
    if not p then return false end
    
    local CurrentCamera = workspace.CurrentCamera
    if not CurrentCamera then return false end
    
    local raycastParams = RaycastParams.new()
    local filterList = {}
    if LocalPlayer.Character then 
        table.insert(filterList, LocalPlayer.Character) 
    end
    
    raycastParams.FilterDescendantsInstances = filterList
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local direction = p.Position - CurrentCamera.CFrame.Position
    local result = workspace:Raycast(
        CurrentCamera.CFrame.Position, direction, raycastParams
    )
    
    if not result then return true end
    return result.Instance:IsDescendantOf(target.Character)
end

function CheckForKnife(container)
    if not container then return false end
    for _, item in ipairs(container:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            local isServer = item:FindFirstChild("KnifeServer")
            local isClient = item:FindFirstChild("KnifeClient")
            
            if name == "knife" or isServer or isClient then
                return true
            end
            
            for _, weaponName in ipairs(MurdererWeapons) do
                if name:find(weaponName) then
                    return true
                end
            end
        end
    end
    return false
end

function FindMurderer(preferTarget)
    if preferTarget and preferTarget.Character then
        local hum = preferTarget.Character:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then
            return preferTarget
        end
    end

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local hum = pl.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local inChar = CheckForKnife(pl.Character)
                local inPack = CheckForKnife(pl:FindFirstChild("Backpack"))
                
                if inChar or inPack then
                    if not WallCheckEnabled or IsVisible(pl) then
                        return pl
                    end
                end
            end
        end
    end
    return nil
end

-- ==============================================
-- ОСНОВНОЙ ЦИКЛ AIMLOCK
-- ==============================================
local function AimLockLoop(deltaTime)
    if not AimLockEnabled then return end
    
    local CurrentCamera = workspace.CurrentCamera 
    if not CurrentCamera then return end

    local valid = false
    if TargetPlayer and TargetPlayer.Character then
        local hum = TargetPlayer.Character:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then
            valid = true
        end
    end
    
    if WallCheckEnabled and valid then
        local currentTime = os.clock()
        if currentTime - LastWallCheckTime > WALL_CHECK_INTERVAL then
            IsTargetVisibleCache = IsVisible(TargetPlayer)
            LastWallCheckTime = currentTime
        end
        if not IsTargetVisibleCache then
            InvisibleTimer = InvisibleTimer + deltaTime
            if InvisibleTimer > MAX_INVISIBLE_TIME then
                valid = false
            end
        else
            InvisibleTimer = 0
        end
    else
        InvisibleTimer = 0
    end
    
    if not valid then 
        local currentTime = os.clock()
        if currentTime - LastSearchTime > 0.1 then
            TargetPlayer = FindMurderer(TargetPlayer)
            LastSearchTime = currentTime
        end
    end
    
    if TargetPlayer and TargetPlayer.Character then
        local targetNode = TargetPlayer.Character:FindFirstChild(TargetPart)
        
        if targetNode then
            local vel = targetNode.AssemblyLinearVelocity or Vector3.new()
            local predVector = Vector3.new(vel.X, vel.Y * 0.3, vel.Z)
            local predictedPos = targetNode.Position + (predVector * PredictionLevel)
            
            CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position, predictedPos)
        end
    end
end

-- ==============================================
-- GUI МЕНЮ (КОНСОЛЬНОЕ)
-- ==============================================
local function CreateConsoleMenu()
    print("=" .. string.rep("=", 40))
    print("  🎯 MM2 AIMLOCK V2.6 | STANDALONE")
    print("=" .. string.rep("=", 40))
    print("  [1] Toggle Aim Lock  [Currently: " .. (AimLockEnabled and "ON" or "OFF") .. "]")
    print("  [2] Toggle Wall Check [Currently: " .. (WallCheckEnabled and "ON" or "OFF") .. "]")
    print("  [3] Toggle Button     [Currently: " .. (ShowBindableButton and "Visible" or "Hidden") .. "]")
    print("  [4] Target Part       [Currently: " .. TargetPart .. "]")
    print("  [5] Prediction Level  [Currently: " .. PredictionLevel .. "]")
    print("  [6] Button Size       [Currently: " .. math.floor(bindButtonSize * 100) .. "%]")
    print("  [7] Print Status")
    print("  [8] Exit Menu")
    print("=" .. string.rep("=", 40))
    print("💡 Quick Toggle: Press 'T'")
end

-- ==============================================
-- СОЗДАНИЕ КНОПКИ (BIND)
-- ==============================================
local function UpdateAimButtonState()
    local btn = BindableButtons.Buttons["aim_toggle"]
    if not btn then return end
    local textLabel = btn:FindFirstChild("@Text")
    if textLabel then
        textLabel.Text = AimLockEnabled and "ON" or "OFF"
    end
    local stroke = btn:FindFirstChild("@Stroke")
    if stroke then
        if AimLockEnabled then
            stroke.Color = __ACTIVE_COLOR
        else
            stroke.Color = __NORMAL_COLOR
        end
    end
end

local function ToggleAimLock()
    AimLockEnabled = not AimLockEnabled
    if AimLockEnabled then 
        TargetPlayer = FindMurderer(nil) 
    else 
        TargetPlayer = nil 
    end
    UpdateAimButtonState()
    print("⚡ Aim Lock: " .. (AimLockEnabled and "ENABLED" or "DISABLED"))
end

local function CreateBindButton()
    if BindableButtons.Buttons["aim_toggle"] then return end
    
    BindableButtons.AddBButton("aim_toggle", "Aim", function()
        ToggleAimLock()
    end, false)
    
    local btn = BindableButtons.Buttons["aim_toggle"]
    if btn then
        local screen = Workspace.CurrentCamera.ViewportSize
        btn.Size = __UD2(bindButtonSize * (screen.Y / screen.X), 0, bindButtonSize, 0)
    end
    
    UpdateAimButtonState()
end

local function DeleteBindButton()
    BindableButtons.DeleteBButton("aim_toggle")
end

local function ToggleBindableVisibility()
    local btn = BindableButtons.Buttons["aim_toggle"]
    if btn then
        btn.Visible = ShowBindableButton
    end
end

-- ==============================================
-- УПРАВЛЕНИЕ ГОРЯЧИМИ КЛАВИШАМИ
-- ==============================================
local function SetupKeybinds()
    local inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.T then
            ToggleAimLock()
        end
    end)
    
    RootMaid:GiveTask(inputBeganConnection)
end

-- ==============================================
-- ЗАПУСК
-- ==============================================
CreateBindButton()
ToggleBindableVisibility()
SetupKeybinds()

-- ==============================================
-- ПРИВЯЗКА AIMLOCK К RENDERSTEP
-- ==============================================
RunService:BindToRenderStep(
    "MM2_AimLock_PhaseSync", 
    Enum.RenderPriority.Camera.Value + 1, 
    AimLockLoop
)

-- Очистка при смене персонажа
LocalPlayer.CharacterAdded:Connect(function()
    TargetPlayer = nil
end)

-- Очистка при выгрузке
RootMaid:GiveTask(function()
    DeleteBindButton()
    RunService:UnbindFromRenderStep("MM2_AimLock_PhaseSync")
    if MainGUI then MainGUI:Destroy() end
end)

-- ==============================================
-- ВЫВОД МЕНЮ В КОНСОЛЬ
-- ==============================================
print("✅ MM2 Aim Lock V2.6 (Standalone) Loaded!")
CreateConsoleMenu()

-- Функция для вызова меню из консоли
_G.MM2AimMenu = CreateConsoleMenu
_G.MM2Toggle = ToggleAimLock

print("🔧 Type 'MM2AimMenu()' to show menu, 'MM2Toggle()' to toggle aim")
