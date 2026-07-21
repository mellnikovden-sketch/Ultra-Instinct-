-- YARHM MM2 - Mobile Version (Для телефона)
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local YARHM = Instance.new("ScreenGui")
YARHM.Name = "YARHM_MM2"
YARHM.ResetOnSpawn = false
YARHM.IgnoreGuiInset = true
YARHM.DisplayOrder = 999
YARHM.Parent = game:GetService("CoreGui")

-- Большой удобный фрейм для телефона
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0.9, 0, 0.85, 0)  -- Почти на весь экран
Main.Position = UDim2.new(0.05, 0, 0.075, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
Main.Parent = YARHM

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 20)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 80)
Title.BackgroundTransparency = 1
Title.Text = "YARHM MM2"
Title.TextColor3 = Color3.fromRGB(100, 180, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = Main

-- Tabs (большие для пальцев)
local tabHolder = Instance.new("Frame")
tabHolder.Size = UDim2.new(1, -40, 0, 70)
tabHolder.Position = UDim2.new(0, 20, 0, 90)
tabHolder.BackgroundTransparency = 1
tabHolder.Parent = Main

local CombatTab = Instance.new("ScrollingFrame")
local VisualsTab = Instance.new("ScrollingFrame")
local MiscTab = Instance.new("ScrollingFrame")

for _, tab in pairs({CombatTab, VisualsTab, MiscTab}) do
    tab.Size = UDim2.new(1, -40, 1, -200)
    tab.Position = UDim2.new(0, 20, 0, 180)
    tab.BackgroundTransparency = 1
    tab.ScrollBarThickness = 8
    tab.Visible = false
    tab.Parent = Main
    Instance.new("UIListLayout", tab).Padding = UDim.new(0, 15)
end

CombatTab.Visible = true

local function CreateBigToggle(parent, text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 85)  -- Большая кнопка
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 18)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "  " .. text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.GothamSemibold
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.3, 0, 0.7, 0)
    toggle.Position = UDim2.new(0.67, 0, 0.15, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.TextScaled = true
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = frame
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 14)
    
    local enabled = false
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 90)
        toggle.Text = enabled and "ON" or "OFF"
    end)
end

-- Добавляем кнопки
CreateBigToggle(CombatTab, "Silent Aim")
CreateBigToggle(CombatTab, "Auto Knife")
CreateBigToggle(CombatTab, "Auto Shoot")
CreateBigToggle(VisualsTab, "ESP")
CreateBigToggle(VisualsTab, "Gun ESP")
CreateBigToggle(MiscTab, "Fly")
CreateBigToggle(MiscTab, "Godmode")
CreateBigToggle(MiscTab, "Auto Farm")

-- Переключение табов
local tabsList = {CombatTab, VisualsTab, MiscTab}
local current = 1

local function switchTab()
    for i, tab in ipairs(tabsList) do
        tab.Visible = (i == current)
    end
end

-- Простые кнопки табов
for i, name in ipairs({"Combat", "Visuals", "Misc"}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.3, 0, 1, 0)
    btn.Position = UDim2.new((i-1)*0.33, 5, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = tabHolder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    
    btn.MouseButton1Click:Connect(function()
        current = i
        switchTab()
    end)
end

print("✅ YARHM MM2 Mobile Version запущен!")
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "YARHM MM2",
    Text = "Мобильная версия загружена! Используй большие кнопки.",
    Duration = 8
})
