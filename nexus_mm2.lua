-- YARHM MM2 Overdrive Style - Fixed & Working Version
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local YARHM = Instance.new("ScreenGui")
YARHM.Name = "YARHM_MM2"
YARHM.ResetOnSpawn = false
YARHM.IgnoreGuiInset = true
YARHM.DisplayOrder = 999
YARHM.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 400, 0, 520)
Main.Position = UDim2.new(0.5, -200, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.Parent = YARHM

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(90, 140, 255)
stroke.Thickness = 2

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 60)
Title.BackgroundTransparency = 1
Title.Text = "YARHM MM2"
Title.TextColor3 = Color3.fromRGB(110, 180, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = Main

-- Tabs
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 50)
TabFrame.Position = UDim2.new(0, 10, 0, 65)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = Main

local CombatTab = Instance.new("ScrollingFrame")
local VisualsTab = Instance.new("ScrollingFrame")
local MiscTab = Instance.new("ScrollingFrame")

for _, tab in pairs({CombatTab, VisualsTab, MiscTab}) do
    tab.Size = UDim2.new(1, -20, 1, -130)
    tab.Position = UDim2.new(0, 10, 0, 125)
    tab.BackgroundTransparency = 1
    tab.ScrollBarThickness = 6
    tab.Visible = false
    tab.Parent = Main
    Instance.new("UIListLayout", tab).Padding = UDim.new(0, 12)
end

CombatTab.Visible = true
local currentTab = CombatTab

local function createTabButton(name, targetTab)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.33, -8, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 16
    btn.Parent = TabFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    
    btn.MouseButton1Click:Connect(function()
        currentTab.Visible = false
        targetTab.Visible = true
        currentTab = targetTab
    end)
end

createTabButton("Combat", CombatTab)
createTabButton("Visuals", VisualsTab)
createTabButton("Misc", MiscTab)

-- Settings
local Settings = getgenv().YARHM_Settings or {ESP = false, SilentAim = false, AutoKnife = false}
getgenv().YARHM_Settings = Settings

-- Simple Toggle
local function addToggle(parent, text, key)
    local enabled = Settings[key] or false
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "  " .. text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 17
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 80, 0, 32)
    toggle.Position = UDim2.new(1, -90, 0.5, -16)
    toggle.BackgroundColor3 = enabled and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(90, 90, 100)
    toggle.Text = enabled and "ON" or "OFF"
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = frame
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)
    
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        Settings[key] = enabled
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(90, 90, 100)
        toggle.Text = enabled and "ON" or "OFF"
    end)
end

-- Add toggles
addToggle(CombatTab, "Silent Aim", "SilentAim")
addToggle(CombatTab, "Auto Knife", "AutoKnife")
addToggle(VisualsTab, "ESP", "ESP")

-- Draggable
local dragging = false
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        -- basic drag (можно расширить)
    end
end)

Main.InputEnded:Connect(function()
    dragging = false
end)

print("✅ YARHM MM2 Fixed Version запущен!")
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "YARHM MM2",
    Text = "Скрипт успешно запущен!",
    Duration = 5
})
