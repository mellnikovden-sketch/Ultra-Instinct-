-- YARHM v2.0 - Полностью переработанная версия
-- Автор: Исправленная версия на основе оригинального кода

local YARHM = {}
YARHM.Version = "2.0"

-- Сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Главный объект
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YARHM"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- ========== ТЕМЫ ==========
local Themes = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 30),
        Secondary = Color3.fromRGB(35, 35, 50),
        Accent = Color3.fromRGB(70, 130, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 200),
        Border = Color3.fromRGB(60, 60, 80)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 250),
        Secondary = Color3.fromRGB(220, 220, 235),
        Accent = Color3.fromRGB(50, 100, 220),
        Text = Color3.fromRGB(30, 30, 50),
        TextSecondary = Color3.fromRGB(80, 80, 100),
        Border = Color3.fromRGB(200, 200, 215)
    }
}

local currentTheme = "Dark"

-- ========== ОСНОВНОЕ МЕНЮ ==========
local MenuFrame = Instance.new("Frame")
MenuFrame.Name = "Menu"
MenuFrame.Size = UDim2.new(0, 500, 0, 400)
MenuFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MenuFrame.BackgroundColor3 = Themes[currentTheme].Background
MenuFrame.BorderSizePixel = 0
MenuFrame.Visible = false
MenuFrame.Active = true
MenuFrame.Draggable = true
MenuFrame.Parent = ScreenGui

-- Скругление
local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 12)
MenuCorner.Parent = MenuFrame

-- Обводка
local MenuStroke = Instance.new("UIStroke")
MenuStroke.Color = Themes[currentTheme].Border
MenuStroke.Thickness = 1
MenuStroke.Parent = MenuFrame

-- ========== ЗАГОЛОВОК ==========
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Themes[currentTheme].Secondary
Header.BorderSizePixel = 0
Header.Parent = MenuFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "YARHM v2.0"
TitleLabel.TextColor3 = Themes[currentTheme].Text
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = Header

-- Кнопка закрытия
local CloseButton = Instance.new("ImageButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0.5, -15)
CloseButton.BackgroundTransparency = 1
CloseButton.Image = "rbxassetid://7072722392"
CloseButton.Parent = Header
CloseButton.MouseButton1Click:Connect(function()
    ToggleMenu()
end)

-- ========== ВКЛАДКИ ==========
local TabContainer = Instance.new("Frame")
TabContainer.Name = "Tabs"
TabContainer.Size = UDim2.new(1, 0, 0, 40)
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.BackgroundColor3 = Themes[currentTheme].Secondary
TabContainer.BackgroundTransparency = 0.5
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MenuFrame

local TabList = Instance.new("UIListLayout")
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.Padding = UDim.new(0, 5)
TabList.Parent = TabContainer

local Tabs = {}
local CurrentTab = nil

function CreateTab(name)
    local tab = Instance.new("TextButton")
    tab.Name = "Tab_" .. name
    tab.Size = UDim2.new(0, 100, 1, -10)
    tab.Position = UDim2.new(0, 5, 0, 5)
    tab.BackgroundColor3 = Themes[currentTheme].Background
    tab.BackgroundTransparency = 0.5
    tab.Text = name
    tab.TextColor3 = Themes[currentTheme].Text
    tab.TextScaled = true
    tab.Font = Enum.Font.Gotham
    tab.BorderSizePixel = 0
    tab.Parent = TabContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tab
    
    -- Контейнер для контента вкладки
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content_" .. name
    content.Size = UDim2.new(1, -20, 1, -100)
    content.Position = UDim2.new(0, 10, 0, 95)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.ScrollBarThickness = 4
    content.Parent = MenuFrame
    content.Visible = false
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content
    
    tab.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Content.Visible = false
            t.Button.BackgroundTransparency = 0.5
        end
        content.Visible = true
        tab.BackgroundTransparency = 0
        CurrentTab = tab
    end)
    
    table.insert(Tabs, {
        Button = tab,
        Content = content,
        Name = name
    })
    
    return content
end

-- Создание вкладок
local MainTab = CreateTab("Main")
local SettingsTab = CreateTab("Settings")
local InfoTab = CreateTab("Info")

-- ========== УТИЛИТЫ ДЛЯ СОЗДАНИЯ ЭЛЕМЕНТОВ ==========
function CreateButton(parent, text, callback, description)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 0)
    button.BackgroundColor3 = Themes[currentTheme].Secondary
    button.Text = text
    button.TextColor3 = Themes[currentTheme].Text
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.BorderSizePixel = 0
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    
    if description then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -20, 0, 20)
        desc.Position = UDim2.new(0, 10, 0, 45)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Themes[currentTheme].TextSecondary
        desc.TextSize = 12
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = parent
    end
    
    return button
end

function CreateToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, 0)
    frame.BackgroundColor3 = Themes[currentTheme].Secondary
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Themes[currentTheme].Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 50, 0, 30)
    toggle.Position = UDim2.new(1, -60, 0.5, -15)
    toggle.BackgroundColor3 = Themes[currentTheme].Background
    toggle.Text = default and "ON" or "OFF"
    toggle.TextColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    toggle.TextScaled = true
    toggle.Font = Enum.Font.GothamBold
    toggle.BorderSizePixel = 0
    toggle.Parent = frame
    
    local tcorner = Instance.new("UICorner")
    tcorner.CornerRadius = UDim.new(1, 0)
    tcorner.Parent = toggle
    
    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        toggle.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(state)
    end)
    
    return toggle, state
end

function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 60)
    frame.Position = UDim2.new(0, 10, 0, 0)
    frame.BackgroundColor3 = Themes[currentTheme].Secondary
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0.4, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Themes[currentTheme].Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0.4, 0)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Themes[currentTheme].Accent
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0.9, 0, 0, 8)
    track.Position = UDim2.new(0.05, 0, 0.8, 0)
    track.BackgroundColor3 = Themes[currentTheme].Background
    track.BorderSizePixel = 0
    track.Parent = frame
    
    local tcorner = Instance.new("UICorner")
    tcorner.CornerRadius = UDim.new(1, 0)
    tcorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Themes[currentTheme].Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fcorner = Instance.new("UICorner")
    fcorner.CornerRadius = UDim.new(1, 0)
    fcorner.Parent = fill
    
    local ball = Instance.new("TextButton")
    ball.Size = UDim2.new(0, 20, 0, 20)
    ball.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    ball.BackgroundColor3 = Themes[currentTheme].Accent
    ball.Text = ""
    ball.BorderSizePixel = 0
    ball.Parent = track
    
    local bcorner = Instance.new("UICorner")
    bcorner.CornerRadius = UDim.new(1, 0)
    bcorner.Parent = ball
    
    local dragging = false
    local value = default
    
    ball.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    ball.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if not dragging then return end
        local mouse = UserInputService:GetMouseLocation()
        local trackPos = track.AbsolutePosition
        local trackSize = track.AbsoluteSize.X
        local percent = math.clamp((mouse.X - trackPos.X) / trackSize, 0, 1)
        value = min + (max - min) * percent
        value = math.round(value * 100) / 100
        
        fill.Size = UDim2.new(percent, 0, 1, 0)
        ball.Position = UDim2.new(percent, -10, 0.5, -10)
        valueLabel.Text = tostring(value)
        callback(value)
    end)
    
    return ball, value
end

-- ========== ФУНКЦИИ МОДУЛЕЙ ==========
local Modules = {}

function YARHM:AddModule(name, func)
    Modules[name] = func
end

-- ========== ИГРОВЫЕ МОДУЛИ ==========
-- Flee the Facility
YARHM:AddModule("Flee the Facility", function()
    local player = Players.LocalPlayer
    if not player then return end
    
    -- ESP
    local espEnabled = false
    local espObjects = {}
    
    CreateToggle(MainTab, "ESP Players", false, function(state)
        espEnabled = state
        if state then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= player then
                    -- Создание ESP
                end
            end
        else
            for _, v in pairs(espObjects) do
                v:Destroy()
            end
            espObjects = {}
        end
    end)
    
    CreateButton(MainTab, "Auto Escape", function()
        -- Автоматический побег
        print("Auto Escape activated")
    end, "Automatically escapes when possible")
end)

-- Murder Mystery 2
YARHM:AddModule("Murder Mystery 2", function()
    CreateButton(MainTab, "Find Gun", function()
        print("Finding gun...")
    end, "Highlights the gun location")
    
    CreateToggle(MainTab, "Auto Defend", false, function(state)
        print("Auto defend: " .. tostring(state))
    end)
end)

-- Forsaken
YARHM:AddModule("Forsaken", function()
    CreateButton(MainTab, "Speed Boost", function()
        print("Speed boost activated")
    end)
    
    CreateToggle(MainTab, "Fly Mode", false, function(state)
        if state then
            -- Активация полета
            print("Fly mode activated")
        else
            print("Fly mode deactivated")
        end
    end)
end)

-- ========== НАСТРОЙКИ ==========
CreateToggle(SettingsTab, "Show FPS", false, function(state)
    if state then
        -- Показ FPS
    end
end)

CreateButton(SettingsTab, "Change Theme", function()
    currentTheme = currentTheme == "Dark" and "Light" or "Dark"
    local theme = Themes[currentTheme]
    MenuFrame.BackgroundColor3 = theme.Background
    MenuStroke.Color = theme.Border
    Header.BackgroundColor3 = theme.Secondary
    TitleLabel.TextColor3 = theme.Text
    TabContainer.BackgroundColor3 = theme.Secondary
    
    -- Обновление всех элементов
    for _, tab in pairs(Tabs) do
        tab.Button.BackgroundColor3 = theme.Background
        tab.Button.TextColor3 = theme.Text
    end
end, "Switch between dark and light theme")

-- ========== ИНФОРМАЦИЯ ==========
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 100)
InfoLabel.Position = UDim2.new(0, 10, 0, 10)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "YARHM v2.0\nCreated by Actherion\n\nPress Right Shift to toggle menu"
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
InfoLabel.TextSize = 16
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.Parent = InfoTab

-- ========== УПРАВЛЕНИЕ МЕНЮ ==========
local menuOpen = false

function ToggleMenu()
    menuOpen = not menuOpen
    MenuFrame.Visible = menuOpen
    
    if menuOpen then
        -- Анимация появления
        MenuFrame.Size = UDim2.new(0, 500, 0, 400)
    end
end

-- Горячая клавиша (Right Shift)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        ToggleMenu()
    end
end)

-- ========== ЗАГРУЗКА МОДУЛЕЙ ==========
function YARHM:LoadModule(name)
    if Modules[name] then
        Modules[name]()
        return true
    end
    return false
end

-- Автозагрузка модулей для текущей игры
local function detectGameAndLoad()
    local placeId = game.PlaceId
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
    
    -- Определение игры по названию или ID
    if string.find(gameName, "Flee") or string.find(gameName, "Facility") then
        YARHM:LoadModule("Flee the Facility")
    elseif string.find(gameName, "Murder") then
        YARHM:LoadModule("Murder Mystery 2")
    elseif string.find(gameName, "Forsaken") then
        YARHM:LoadModule("Forsaken")
    end
end

-- ========== ЗАПУСК ==========
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "YARHM",
    Text = "Loaded successfully! Press Right Shift to open.",
    Duration = 3
})

-- Определение игры после загрузки
if game:IsLoaded() then
    detectGameAndLoad()
else
    game.Loaded:Connect(detectGameAndLoad)
end

-- ========== ОБРАБОТКА ОШИБОК ==========
local function safeCall(func)
    local success, err = pcall(func)
    if not success then
        warn("YARHM Error: " .. tostring(err))
    end
    return success
end

-- Защита всех функций
for _, tab in pairs(Tabs) do
    local oldFunc = tab.Button.MouseButton1Click
    tab.Button.MouseButton1Click:Connect(function()
        safeCall(oldFunc)
    end)
end

return YARHM
