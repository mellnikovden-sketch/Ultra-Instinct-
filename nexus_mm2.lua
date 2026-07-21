-- NEXUS HUB: MM2 OVERDRIVE MOBILE
local P = game:GetService("Players")
local LP = P.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CG = game:GetService("CoreGui")
local L = game:GetService("Lighting")

local S = {ESP=false,GunESP=false,Aura=false,NoClip=false,Jump=false,Fly=false,Btn=true}

local function GetRole(p)
    if not p or not p.Character then return "Innocent" end
    local function chk(c)
        if not c then return end
        for _, i in ipairs(c:GetChildren()) do
            if i:IsA("Tool") then
                local n = i.Name:lower()
                if n:find("knife") or n:find("blade") then return "Murderer"
                elseif n:find("gun") or n:find("revolver") then return "Sheriff" end
            end
        end
    end
    return chk(p.Character) or chk(p:FindFirstChild("Backpack")) or "Innocent"
end

local function GetMurd()
    for _, p in ipairs(P:GetPlayers()) do
        if GetRole(p) == "Murderer" then return p end
    end
end

local function Notify(t) print("[NEXUS]: " .. t) end

local SG = Instance.new("ScreenGui", CG)
SG.Name = "Nexus_V5"

local Btn = Instance.new("TextButton", SG)
Btn.Size = UDim2.new(0, 55, 0, 55)
Btn.Position = UDim2.new(0, 20, 0.35, 0)
Btn.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
Btn.Text = "HUB"
Btn.TextColor3 = Color3.fromRGB(0, 255, 180)
Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 500, 0, 320)
MF.Position = UDim2.new(0.5, -250, 0.5, -160)
MF.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
MF.Active = true
MF.Draggable = true
Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 10)

Btn.MouseButton1Click:Connect(function() MF.Visible = not MF.Visible end)

local CF = Instance.new("ScrollingFrame", MF)
CF.Size = UDim2.new(1, -20, 1, -20)
CF.Position = UDim2.new(0, 10, 0, 10)
CF.BackgroundTransparency = 1
CF.ScrollBarThickness = 4
Instance.new("UIListLayout", CF).Padding = UDim.new(0, 8)

local function AddBtn(txt, cb)
    local b = Instance.new("TextButton", CF)
    b.Size = UDim2.new(1, -10, 0, 38)
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(0, 255, 180)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb)
end

local function Shoot()
    local m = GetMurd()
    if not m or not m.Character then return Notify("Убийца не найден") end
    local char = LP.Character
    local gun = char and char:FindFirstChild("Gun") or LP.Backpack:FindFirstChild("Gun")
    if not gun then return Notify("Нет пистолета") end
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

AddBtn("⚡ Выстрелить в убийцу", Shoot)
AddBtn("🌀 Телепорт к Убийце", function()
    local m = GetMurd()
    if m and m.Character then LP.Character.HumanoidRootPart.CFrame = m.Character.HumanoidRootPart.CFrame end
end)

RS.RenderStepped:Connect(function()
    if S.ESP then
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP and p.Character then
                local hl = p.Character:FindFirstChild("NX_ESP") or Instance.new("Highlight", p.Character)
                hl.Name = "NX_ESP"
                local r = GetRole(p)
                hl.FillColor = r == "Murderer" and Color3.fromRGB(255,0,0) or (r == "Sheriff" and Color3.fromRGB(0,0,255) or Color3.fromRGB(0,255,0))
            end
        end
    end
end)

Notify("Nexus Hub загружен!")
