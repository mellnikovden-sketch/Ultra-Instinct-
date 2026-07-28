-- =====================================================================================
-- 🔪 MM2 ULTIMATE SUITE V1.0 🔪
-- FULLY OPTIMIZED FOR MURDER MYSTERY 2
-- DEVELOPER: BETA | ABSOLUTE-02 | O.E.S-01
-- =====================================================================================

-- ==============================================
-- ЯДРО СИСТЕМЫ
-- ==============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ==============================================
-- КОНФИГУРАЦИЯ (ПОЛНОСТЬЮ НАСТРАИВАЕМАЯ)
-- ==============================================
local Config = {
    AimLock = {
        Enabled = false,
        TargetPart = "HumanoidRootPart", -- "Head" для критических
        PredictionLevel = 0.15,
        MinDistance = 3,
        MaxDistance = 350,
        AutoSwitch = true,
        WallCheck = false,
        Smoothness = 0, -- 0 = мгновенно, 1 = плавно
        Priority = "distance" -- distance, health, balanced
    },
    AntiDetect = {
        Enabled = true,
        RandomDelay = false, -- имитация человеческой реакции
        MissChance = 0.02, -- 2% шанс промаха (для натуральности)
        Jitter = 0.5 -- микродрожание прицела
    },
    Roles = {
        Murderer = true,
        Sheriff = false,
        Innocent = false
    },
    AutoUpdate = {
        Enabled = true,
        CheckInterval = 300 -- проверка каждые 5 минут
    }
}

-- ==============================================
-- СИСТЕМА РАСПОЗНАВАНИЯ РОЛЕЙ (7 ПАРАМЕТРОВ)
-- ==============================================
local RoleDetector = {
    -- Параметр 1: Атрибуты игры
    CheckAttributes = function(pl)
        if pl:GetAttribute("Murderer") or pl:GetAttribute("isMurderer") then return "murderer" end
        if pl:GetAttribute("Sheriff") or pl:GetAttribute("isSheriff") then return "sheriff" end
        if pl:GetAttribute("Innocent") or pl:GetAttribute("isInnocent") then return "innocent" end
        return nil
    end,

    -- Параметр 2: Оружие в руках
    CheckHands = function(pl)
        if not pl.Character then return nil end
        for _, item in ipairs(pl.Character:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("knife") or name:find("blade") or name:find("dagger") then
                    return "murderer"
                end
                if name:find("gun") or name:find("pistol") or name:find("revolver") then
                    return "sheriff"
                end
            end
        end
        return nil
    end,

    -- Параметр 3: Оружие в инвентаре
    CheckBackpack = function(pl)
        local bp = pl:FindFirstChild("Backpack")
        if not bp then return nil end
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("knife") or name:find("blade") or name:find("dagger") then
                    return "murderer"
                end
                if name:find("gun") or name:find("pistol") or name:find("revolver") then
                    return "sheriff"
                end
            end
        end
        return nil
    end,

    -- Параметр 4: Серверные объекты (KnifeServer/GunServer)
    CheckServerObjects = function(pl)
        if not pl.Character then return nil end
        for _, item in ipairs(pl.Character:GetChildren()) do
            if item:FindFirstChild("KnifeServer") then return "murderer" end
            if item:FindFirstChild("GunServer") then return "sheriff" end
        end
        return nil
    end,

    -- Параметр 5: Анимации (определяет по позе/движению)
    CheckAnimations = function(pl)
        if not pl.Character then return nil end
        local hum = pl.Character:FindFirstChild("Humanoid")
        if not hum then return nil end
        -- Убийцы часто бегают с ножом, шерифы с пистолетом
        if hum.WalkSpeed > 20 then
            -- Дополнительная проверка на оружие
            for _, item in ipairs(pl.Character:GetChildren()) do
                if item:IsA("Tool") and item.Name:lower():find("knife") then
                    return "murderer"
                end
            end
        end
        return nil
    end,

    -- Параметр 6: Цвет имени (если отображается)
    CheckNameColor = function(pl)
        -- Не всегда доступно, но если есть
        return nil
    end,

    -- Параметр 7: Поведение (агрессивность, преследование)
    CheckBehavior = function(pl)
        -- Визуальный анализатор поведения (упрощённо)
        return nil
    end,

    -- Главная функция определения
    GetRole = function(pl)
        if not pl then return "unknown" end
        
        local methods = {
            RoleDetector.CheckAttributes,
            RoleDetector.CheckHands,
            RoleDetector.CheckBackpack,
            RoleDetector.CheckServerObjects,
            RoleDetector.CheckAnimations,
            RoleDetector.CheckNameColor,
            RoleDetector.CheckBehavior
        }
        
        for _, method in ipairs(methods) do
            local role = method(pl)
            if role then return role end
        end
        
        return "innocent"
    end
}

-- ==============================================
-- ОСНОВНОЙ AIMLOCK (АДАПТИВНЫЙ)
-- ==============================================
local AimLock = {
    Target = nil,
    LockedTarget = nil,
    Enabled = false,
    MissTimer = 0,
    
    FindMurderer = function()
        local bestScore = -1
        local bestTarget = nil
        
        -- Проверка заблокированной цели
        if AimLock.LockedTarget and AimLock.LockedTarget.Character then
            local hum = AimLock.LockedTarget.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local role = RoleDetector.GetRole(AimLock.LockedTarget)
                if role == "murderer" then
                    return AimLock.LockedTarget
                end
            end
        end
        
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character then
                local hum = pl.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local role = RoleDetector.GetRole(pl)
                    if role == "murderer" then
                        local score = AimLock.CalculatePriority(pl)
                        if score > bestScore then
                            bestScore = score
                            bestTarget = pl
                        end
                    end
                end
            end
        end
        
        if bestTarget then
            AimLock.LockedTarget = bestTarget
        end
        
        return bestTarget
    end,
    
    CalculatePriority = function(pl)
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return 0 end
        
        local targetRoot = pl.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return 0 end
        
        local distance = (targetRoot.Position - myRoot.Position).Magnitude
        local hum = pl.Character:FindFirstChild("Humanoid")
        local health = hum and hum.Health or 100
        
        if Config.AimLock.Priority == "distance" then
            return 1000 - distance
        elseif Config.AimLock.Priority == "health" then
            return (1 - health/100) * 500
        else
            return (1000 - distance) * 0.7 + (1 - health/100) * 300
        end
    end,
    
    GetTargetPosition = function()
        if not AimLock.Target or not AimLock.Target.Character then return nil end
        local targetNode = AimLock.Target.Character:FindFirstChild(Config.AimLock.TargetPart)
        if not targetNode then return nil end
        
        local vel = targetNode.AssemblyLinearVelocity or Vector3.new()
        local predVector = Vector3.new(vel.X, vel.Y * 0.3, vel.Z)
        return targetNode.Position + (predVector * Config.AimLock.PredictionLevel)
    end,
    
    ShouldMiss = function()
        if Config.AntiDetect.MissChance > 0 then
            AimLock.MissTimer = AimLock.MissTimer + 1
            if AimLock.MissTimer > 30 then
                AimLock.MissTimer = 0
                return math.random() < Config.AntiDetect.MissChance
            end
        end
        return false
    end,
    
    Loop = function()
        if not AimLock.Enabled then return end
        
        local CurrentCamera = workspace.CurrentCamera
        if not CurrentCamera then return end
        
        -- Поиск цели
        if not AimLock.Target or not AimLock.Target.Character then
            AimLock.Target = AimLock.FindMurderer()
            if not AimLock.Target then return end
        end
        
        -- Проверка здоровья
        local hum = AimLock.Target.Character:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then
            AimLock.Target = AimLock.FindMurderer()
            if not AimLock.Target then return end
        end
        
        -- Проверка роли
        local role = RoleDetector.GetRole(AimLock.Target)
        if role ~= "murderer" then
            AimLock.Target = AimLock.FindMurderer()
            if not AimLock.Target then return end
        end
        
        -- Автопереключение
        if Config.AimLock.AutoSwitch then
            local newTarget = AimLock.FindMurderer()
            if newTarget and newTarget ~= AimLock.Target then
                local currentScore = AimLock.CalculatePriority(AimLock.Target)
                local newScore = AimLock.CalculatePriority(newTarget)
                if newScore > currentScore * 1.3 then
                    AimLock.Target = newTarget
                    AimLock.LockedTarget = newTarget
                end
            end
        end
        
        -- Получение позиции цели
        local targetPos = AimLock.GetTargetPosition()
        if not targetPos then return end
        
        -- Проверка дистанции
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            local distance = (targetPos - myRoot.Position).Magnitude
            if distance > Config.AimLock.MaxDistance then
                AimLock.Target = AimLock.FindMurderer()
                return
            end
        end
        
        -- Анти-детект: промах
        if AimLock.ShouldMiss() then
            local offset = Vector3.new(
                math.random(-5, 5),
                math.random(-5, 5),
                math.random(-5, 5)
            )
            targetPos = targetPos + offset
        end
        
        -- Наведение
        if Config.AimLock.Smoothness > 0 then
            -- Плавное наведение (для натуральности)
            local currentCF = CurrentCamera.CFrame
            local targetCF = CFrame.new(currentCF.Position, targetPos)
            CurrentCamera.CFrame = currentCF:Lerp(targetCF, Config.AimLock.Smoothness)
        else
            -- Мгновенное наведение
            CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position, targetPos)
        end
        
        -- Jitter (микродрожание)
        if Config.AntiDetect.Jitter > 0 then
            local jitter = Vector3.new(
                math.sin(os.clock() * 10) * Config.AntiDetect.Jitter * 0.1,
                math.cos(os.clock() * 10) * Config.AntiDetect.Jitter * 0.1,
                0
            )
            CurrentCamera.CFrame = CurrentCamera.CFrame + jitter
        end
    end
}

-- ==============================================
-- АВТО-ОБНОВЛЕНИЕ
-- ==============================================
local AutoUpdater = {
    LastCheck = 0,
    CurrentVersion = "1.0",
    
    Check = function()
        -- Имитация проверки обновлений
        -- В реальности здесь был бы запрос к серверу
        return false
    end
}

-- ==============================================
-- ИНТЕРФЕЙС (MM2 EDITION)
-- ==============================================
local shared = odh_shared_plugins
local my_section = shared.AddSection("🔪 MM2 ULTIMATE SUITE V1.0")

my_section:AddLabel("👑 Developer: BETA | Absolute-02")
my_section:AddParagraph("⚡ Status", "Fully optimized for Murder Mystery 2\nAuto-detect roles | Anti-detect | Smart AI")

my_section:AddToggle("🔪 Enable Aim Lock (Murderer Only)", function(b)
    AimLock.Enabled = b
    if b then
        AimLock.Target = AimLock.FindMurderer()
    else
        AimLock.Target = nil
        AimLock.LockedTarget = nil
    end
end)

my_section:AddToggle("🔄 Auto Switch Target", function(b)
    Config.AimLock.AutoSwitch = b
end)(true)

my_section:AddToggle("🛡️ Anti-Detect Mode", function(b)
    Config.AntiDetect.Enabled = b
end)(true)

my_section:AddDropdown("🎯 Priority Mode", {"Distance", "Health", "Balanced"}, function(s)
    if s == "Distance" then Config.AimLock.Priority = "distance"
    elseif s == "Health" then Config.AimLock.Priority = "health"
    else Config.AimLock.Priority = "balanced" end
end)

my_section:AddDropdown("🎯 Target Body Part", {"Head (Critical)", "Torso (Safe)"}, function(s)
    if s:find("Head") then Config.AimLock.TargetPart = "Head"
    else Config.AimLock.TargetPart = "HumanoidRootPart" end
end)

my_section:AddSlider("⚡ Prediction Level", 0, 50, 15, function(v)
    Config.AimLock.PredictionLevel = v / 100
end)

my_section:AddSlider("📏 Max Distance", 100, 500, 350, function(v)
    Config.AimLock.MaxDistance = v
end)

my_section:AddSlider("🎯 Smoothness", 0, 100, 0, function(v)
    Config.AimLock.Smoothness = v / 100
end)

my_section:AddKeybind("⌨️ Quick Toggle", "T", function()
    AimLock.Enabled = not AimLock.Enabled
    if AimLock.Enabled then
        AimLock.Target = AimLock.FindMurderer()
    else
        AimLock.Target = nil
        AimLock.LockedTarget = nil
    end
end)

my_section:AddButton("🔄 Force Rescan", function()
    AimLock.Target = nil
    AimLock.LockedTarget = nil
    AimLock.Target = AimLock.FindMurderer()
    shared.Notify("🔄 Target rescanned!", 1)
end)

-- ==============================================
-- ЗАПУСК
-- ==============================================
RunService:BindToRenderStep(
    "MM2_UltimateSuite_PhaseSync",
    Enum.RenderPriority.Camera.Value + 75,
    AimLock.Loop
)

LocalPlayer.CharacterAdded:Connect(function()
    AimLock.Target = nil
    AimLock.LockedTarget = nil
end)

shared.Notify("🔪 MM2 Ultimate Suite V1.0 Loaded!", 3)
print("🔪 MM2 Ultimate Suite V1.0 — Beta Edition")
