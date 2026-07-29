-- ================================================================================================
-- ⚡⚡⚡ ULTRA INSTINCT V24.3 ULTRA-LITE+ ⚡⚡⚡
-- 5 УЛЬТРА-РЕЖИМОВ: PRO | INSTINCT | SECRETIVE | ANNIHILATING | ADAPTIVE
-- В МЕНЮ: вкл/выкл, выбор режима, тогглы физики, статистика
-- ================================================================================================

local shared = odh_shared_plugins
local section = shared.AddSection("⚡ ULTRA INSTINCT ULTRA-LITE ⚡")

local internal_shared = odh_internal_shared
local gpl_preset = internal_shared.MM2_GPL

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local math_clamp = math.clamp
local math_abs = math.abs
local math_floor = math.floor
local os_clock = os.clock
local os_time = os.time
local collectgarbage = collectgarbage
local pairs = pairs
local ipairs = ipairs
local table_insert = table.insert
local table_remove = table.remove
local Vector3_new = Vector3.new

local VERSION = "24.3 ULTRA-LITE+"
local GRAVITY = 196.2
local BULLET_SPEED = 2500
local MAX_HISTORY = 50
local DEFAULT_REACTION = 0.15
local ADAPTIVE_GAIN = 0.05
local MAX_ADAPTIVE_OFFSET = 3.0
local MAX_THREAT_DISTANCE = 500

-- ====== 5 УЛЬТРА-РЕЖИМОВ ======
local MODES = {
    PRO = {
        name = "PRO",
        desc = "Сбалансированный для опытных",
        h_base = 125, h_ping = 0.22, h_speed = 1.5,
        v_base = 125, v_ping = 0.14, v_dist = 0.18,
        sim_base = 35, sim_speed = 0.4,
        int_base = 50, int_speed = -0.3,
        offX = -2, offY = 0, offZ = 0,
    },
    INSTINCT = {
        name = "INSTINCT",
        desc = "Максимальное упреждение для атаки",
        h_base = 145, h_ping = 0.30, h_speed = 1.8,
        v_base = 140, v_ping = 0.18, v_dist = 0.22,
        sim_base = 45, sim_speed = 0.5,
        int_base = 35, int_speed = -0.2,
        offX = -3, offY = 0, offZ = 2,
    },
    SECRETIVE = {
        name = "SECRETIVE",
        desc = "Минимальное смещение для скрытности",
        h_base = 105, h_ping = 0.15, h_speed = 1.0,
        v_base = 105, v_ping = 0.10, v_dist = 0.12,
        sim_base = 28, sim_speed = 0.2,
        int_base = 60, int_speed = -0.4,
        offX = 0, offY = 0, offZ = -1,
    },
    ANNIHILATING = {
        name = "ANNIHILATING",
        desc = "Экстремальное упреждение",
        h_base = 185, h_ping = 0.50, h_speed = 3.0,
        v_base = 175, v_ping = 0.30, v_dist = 0.35,
        sim_base = 65, sim_speed = 1.0,
        int_base = 20, int_speed = -0.05,
        offX = -5, offY = 0, offZ = 5,
    },
    ADAPTIVE = {
        name = "ADAPTIVE",
        desc = "Авто-переключение по дистанции",
        h_base = 125, h_ping = 0.22, h_speed = 1.5,
        v_base = 125, v_ping = 0.14, v_dist = 0.18,
        sim_base = 35, sim_speed = 0.4,
        int_base = 50, int_speed = -0.3,
        offX = -2, offY = 0, offZ = 0,
        auto_switch = true,
    },
}

local ADAPTIVE_SUBS = {
    CLOSE = { h_base = 135, h_ping = 0.28, h_speed = 1.8, v_base = 135, v_ping = 0.18, v_dist = 0.22, sim_base = 42, sim_speed = 0.5, int_base = 38, int_speed = -0.2, offX = -4, offY = 0, offZ = 3 },
    MID   = { h_base = 125, h_ping = 0.22, h_speed = 1.5, v_base = 125, v_ping = 0.14, v_dist = 0.18, sim_base = 35, sim_speed = 0.4, int_base = 50, int_speed = -0.3, offX = -2, offY = 0, offZ = 1 },
    SNIPER = { h_base = 95,  h_ping = 0.10, h_speed = 0.8, v_base = 95,  v_ping = 0.08, v_dist = 0.10, sim_base = 22, sim_speed = 0.15, int_base = 68, int_speed = -0.5, offX = 1, offY = 0, offZ = -2 },
    DEF   = { h_base = 105, h_ping = 0.15, h_speed = 1.0, v_base = 105, v_ping = 0.10, v_dist = 0.12, sim_base = 28, sim_speed = 0.2, int_base = 60, int_speed = -0.4, offX = 0, offY = 0, offZ = -1 },
}

-- ====== СОСТОЯНИЕ ======
local State = {
    Enabled = false,
    Target = nil,
    TargetLockTime = 0,
    LastGC = 0,
    LastCheck = 0,
    LastApplied = {H=-999,V=-999,Sim=-999,Int=-999,X=-999,Y=-999,Z=-999},
    MyRoot = nil,
    MyChar = nil,
    TargetPosHistory = {},
    TargetVelHistory = {},
    SmoothPos = nil,
    SmoothVel = nil,
    PingHistory = {},
    PingSmooth = 60,
    CurrentMode = "ADAPTIVE",
    Settings = {
        leadMultiplier = 1.0,
        verticalCorrection = 1.0,
        reactionTime = DEFAULT_REACTION,
        minDistance = 3,
        maxDistance = 350,
        useGravity = true,
        useDrag = true,
        predictJump = true,
        targetLock = true,
        lockTime = 2.0,
        prioritySystem = true,
        adaptiveLead = true,
        adaptiveGain = ADAPTIVE_GAIN,
        maxAdaptiveOffset = MAX_ADAPTIVE_OFFSET,
    },
    Stats = {
        Shots = 0, Hits = 0, Misses = 0,
        TotalDamage = 0, Kills = 0, Deaths = 0,
        Accuracy = 0, StartTime = os_time(),
        BestStreak = 0, CurrentStreak = 0,
    },
    LastError = Vector3_new(0,0,0),
    ErrorHistory = {},
    AdaptiveOffset = {x=0, y=0, z=0},
    AdaptiveConfidence = 0.5,
    ThreatMap = {},
    WeaponType = "knife",
}

-- ====== ФУНКЦИИ ======
local function GetRoot(p)
    if not p then return nil end
    local c = p.Character
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

local function UpdateCache()
    local c = LocalPlayer.Character
    if c then
        State.MyChar = c
        State.MyRoot = c:FindFirstChild("HumanoidRootPart")
        for _, item in ipairs(c:GetChildren()) do
            if item:IsA("Tool") then
                local n = item.Name:lower()
                if n:find("knife") or n:find("blade") then State.WeaponType = "knife"
                elseif n:find("gun") or n:find("pistol") or n:find("revolver") then State.WeaponType = "gun"
                else State.WeaponType = "knife" end
                break
            end
        end
    else
        State.MyChar = nil
        State.MyRoot = nil
    end
end

local function HasWeapon(p, types)
    if not p or not p.Character then return false end
    types = types or {"knife","blade","dagger","sword","gun","pistol","revolver"}
    local function check(cont)
        if not cont then return false end
        for _, item in ipairs(cont:GetChildren()) do
            if item:IsA("Tool") then
                local n = item.Name:lower()
                for _, t in ipairs(types) do
                    if n:find(t) then return true end
                end
            end
        end
        return false
    end
    return check(p.Character) or check(p:FindFirstChild("Backpack"))
end

local function IsMurderer(p)
    if not p then return false end
    if p:GetAttribute("Murderer") == true or p:GetAttribute("isMurderer") == true then return true end
    if HasWeapon(p) then return true end
    local c = p.Character
    if c and (c:FindFirstChild("Knife") or c:FindFirstChild("Blade") or c:FindFirstChild("Gun")) then return true end
    return false
end

local function IsSheriff(p)
    if not p then return false end
    if p:GetAttribute("Sheriff") == true or p:GetAttribute("isSheriff") == true then return true end
    return HasWeapon(p, {"gun","pistol","revolver"}) and not IsMurderer(p)
end

local function SmoothPing(raw)
    local hist = State.PingHistory
    table_insert(hist, raw)
    if #hist > 15 then table_remove(hist, 1) end
    local sum = 0
    for _, v in ipairs(hist) do sum = sum + v end
    State.PingSmooth = sum / #hist
    return State.PingSmooth
end

local function AdaptiveCorrection(error)
    if not State.Settings.adaptiveLead then return end
    local hist = State.ErrorHistory
    table_insert(hist, error)
    if #hist > 30 then table_remove(hist, 1) end
    if #hist >= 10 then
        local avg = Vector3_new(0,0,0)
        for _, e in ipairs(hist) do avg = avg + e end
        avg = avg / #hist
        local gain = State.Settings.adaptiveGain * State.AdaptiveConfidence
        State.AdaptiveOffset.x = State.AdaptiveOffset.x + avg.X * gain
        State.AdaptiveOffset.y = State.AdaptiveOffset.y + avg.Y * gain
        State.AdaptiveOffset.z = State.AdaptiveOffset.z + avg.Z * gain
        local maxOff = State.Settings.maxAdaptiveOffset
        State.AdaptiveOffset.x = math_clamp(State.AdaptiveOffset.x, -maxOff, maxOff)
        State.AdaptiveOffset.y = math_clamp(State.AdaptiveOffset.y, -maxOff, maxOff)
        State.AdaptiveOffset.z = math_clamp(State.AdaptiveOffset.z, -maxOff, maxOff)
        State.ErrorHistory = {}
    end
end

local function BuildThreatMap()
    local myRoot = State.MyRoot
    if not myRoot then return end
    local myPos = myRoot.Position
    State.ThreatMap = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            local root = GetRoot(pl)
            if root then
                local pos = root.Position
                local dist = (pos - myPos).Magnitude
                if dist > MAX_THREAT_DISTANCE then dist = MAX_THREAT_DISTANCE end
                local vel = root.AssemblyLinearVelocity
                local speed = vel.Magnitude
                local threat = 0
                if IsMurderer(pl) then threat = threat + 100
                elseif IsSheriff(pl) then threat = threat + 30 end
                threat = threat + (1 / (dist + 1)) * 50
                threat = threat + speed * 2
                local look = root.CFrame.LookVector
                local dirToUs = (myPos - pos).Unit
                local facing = look:Dot(dirToUs)
                if facing > 0.5 then threat = threat + 20 end
                local hum = pl.Character and pl.Character:FindFirstChild("Humanoid")
                if hum and hum.Health < 30 then threat = threat * 1.3 end
                State.ThreatMap[pl] = threat
            end
        end
    end
end

local function FindBestTarget()
    local now = os_clock()
    if State.Settings.targetLock and State.Target and State.Target.Parent == Players then
        local c = State.Target.Character
        if c and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0 and (now - State.TargetLockTime < State.Settings.lockTime) then
            if IsMurderer(State.Target) then return State.Target end
        end
    end
    if now - State.LastCheck < 0.5 then return State.Target end
    State.LastCheck = now

    BuildThreatMap()
    local myRoot = State.MyRoot
    if not myRoot then return nil end

    local best = nil
    local bestScore = -math.huge
    for pl, threat in pairs(State.ThreatMap) do
        if pl ~= LocalPlayer then
            if IsMurderer(pl) then threat = threat * 1.5 end
            if threat > bestScore then
                bestScore = threat
                best = pl
            end
        end
    end

    State.Target = best
    if best then State.TargetLockTime = now end
    return best
end

local function SmoothData(root)
    if not root then return nil, nil end
    local pos = root.Position
    local vel = root.AssemblyLinearVelocity

    local ph = State.TargetPosHistory
    local vh = State.TargetVelHistory
    table_insert(ph, pos)
    table_insert(vh, vel)
    if #ph > MAX_HISTORY then table_remove(ph, 1) end
    if #vh > MAX_HISTORY then table_remove(vh, 1) end

    local avgP = Vector3_new(0,0,0)
    local avgV = Vector3_new(0,0,0)
    for i = 1, #ph do
        avgP = avgP + ph[i]
        avgV = avgV + vh[i]
    end
    avgP = avgP / #ph
    avgV = avgV / #vh
    State.SmoothPos = avgP
    State.SmoothVel = avgV
    return avgP, avgV
end

local function CalculateLead(smoothPos, smoothVel, myPos, ping, dist)
    local bulletTime = dist / BULLET_SPEED
    if State.WeaponType == "gun" then bulletTime = dist / 3000 end
    local totalTime = bulletTime + ping / 1000 + State.Settings.reactionTime
    local vel = smoothVel
    if State.Settings.useDrag then
        local drag = 0.98 ^ (totalTime * 10)
        vel = vel * drag
    end
    local predictedPos = smoothPos + vel * totalTime
    if State.Settings.useGravity then
        predictedPos = predictedPos + Vector3_new(0, -0.5 * GRAVITY * totalTime * totalTime, 0)
    end
    return predictedPos - smoothPos
end

local function ApplyGPL(sim, interval, x, y, z, h, v)
    local last = State.LastApplied
    if math_abs(last.H-h) < 2 and math_abs(last.V-v) < 2 and
       math_abs(last.Sim-sim) < 2 and math_abs(last.Int-interval) < 2 and
       last.X == x and last.Y == y and last.Z == z then return end
    last.H,last.V,last.Sim,last.Int,last.X,last.Y,last.Z = h,v,sim,interval,x,y,z

    if gpl_preset[4] then gpl_preset[4](sim) end
    if gpl_preset[5] then gpl_preset[5](interval) end
    if gpl_preset[6] then gpl_preset[6](x) end
    if gpl_preset[7] then gpl_preset[7](y) end
    if gpl_preset[8] then gpl_preset[8](z) end
    if gpl_preset[9] then gpl_preset[9](h) end
    if gpl_preset[10] then gpl_preset[10](v) end
end

local function InitBase()
    if not internal_shared["RevertSettings_PrioritizeYourPing"] and gpl_preset[1] then gpl_preset[1]() end
    if not internal_shared["RevertSettings_PredictJump"] and gpl_preset[2] then gpl_preset[2]() end
    if not internal_shared["RevertSettings_PredictLag"] and gpl_preset[3] then gpl_preset[3]() end
end

local function Optimize()
    local now = os_clock()
    if now - State.LastGC > 30 then
        State.LastGC = now
        collectgarbage("collect")
    end
end

-- ====== ИНТЕРФЕЙС ======
section:AddLabel("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
section:AddLabel(string.format("⚡⚡⚡ ULTRA INSTINCT %s ⚡⚡⚡", VERSION))
section:AddLabel("🏆 5 УЛЬТРА-РЕЖИМОВ: PRO | INSTINCT | SECRETIVE | ANNIHILATING | ADAPTIVE")
section:AddLabel("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local toggle = section:AddToggle("⚡ АКТИВИРОВАТЬ", function(state)
    State.Enabled = state
    if state then
        InitBase()
        UpdateCache()
        State.Target = nil
        print("[Ultra Instinct] Включён")
    else
        State.Target = nil
        collectgarbage("collect")
        print("[Ultra Instinct] Выключен")
    end
end)

local modeNames = {"PRO", "INSTINCT", "SECRETIVE", "ANNIHILATING", "ADAPTIVE"}
local modeKeys = {"PRO", "INSTINCT", "SECRETIVE", "ANNIHILATING", "ADAPTIVE"}
section:AddLabel("Выберите ультра-режим:")
local modeDropdown = section:AddDropdown("Режим", modeNames, function(selected)
    for i, name in ipairs(modeNames) do
        if name == selected then
            State.CurrentMode = modeKeys[i]
            print("[Ultra Instinct] Режим: " .. name)
            break
        end
    end
end)

section:AddLabel("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
section:AddLabel("🧪 ФИЗИКА И ПРЕДСКАЗАНИЕ")
local gravToggle = section:AddToggle("Учёт гравитации", function(state)
    State.Settings.useGravity = state
end)
gravToggle(true)

local dragToggle = section:AddToggle("Учёт сопротивления", function(state)
    State.Settings.useDrag = state
end)
dragToggle(true)

local jumpToggle = section:AddToggle("Предсказание прыжков", function(state)
    State.Settings.predictJump = state
end)
jumpToggle(true)

section:AddLabel("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
section:AddLabel("📊 СТАТИСТИКА (в консоли F9)")

section:AddButton("Показать статистику", function()
    local s = State.Stats
    local acc = s.Shots > 0 and string.format("%.1f%%", (s.Hits/s.Shots)*100) or "0%"
    local time = os_clock() - s.StartTime
    print("═══════════════════════════════════════════════════════════")
    print("  📊 СТАТИСТИКА ULTRA INSTINCT")
    print("  Выстрелов: " .. s.Shots)
    print("  Попаданий: " .. s.Hits)
    print("  Промахов: " .. s.Misses)
    print("  Точность: " .. acc)
    print("  Урон: " .. s.TotalDamage)
    print("  Убийств: " .. s.Kills)
    print("  Смертей: " .. s.Deaths)
    print("  Серия: " .. s.CurrentStreak .. " (рекорд: " .. s.BestStreak .. ")")
    print("  Время работы: " .. string.format("%.1f сек", time))
    print("  Текущий режим: " .. State.CurrentMode)
    print("═══════════════════════════════════════════════════════════")
end)

section:AddButton("Сбросить статистику", function()
    State.Stats.Shots = 0
    State.Stats.Hits = 0
    State.Stats.Misses = 0
    State.Stats.TotalDamage = 0
    State.Stats.Kills = 0
    State.Stats.Deaths = 0
    State.Stats.Accuracy = 0
    State.Stats.BestStreak = 0
    State.Stats.CurrentStreak = 0
    State.Stats.StartTime = os_time()
    print("[Ultra Instinct] Статистика сброшена")
end)

section:AddLabel("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
section:AddLabel("СТАТУС: информация в консоли (F9)")
section:AddLabel("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- ====== ОСНОВНОЙ ЦИКЛ ======
RunService.Heartbeat:Connect(function()
    if not State.Enabled then return end
    Optimize()

    if not State.MyRoot or not State.MyRoot.Parent then
        UpdateCache()
        if not State.MyRoot then return end
    end

    local target = FindBestTarget()
    if not target then
        State.Target = nil
        return end

    local mRoot = GetRoot(target)
    if not mRoot then return end

    local myRoot = State.MyRoot
    local myPos = myRoot.Position
    local mPos = mRoot.Position
    local dist = (mPos - myPos).Magnitude

    if dist < State.Settings.minDistance or dist > State.Settings.maxDistance then
        State.Target = nil
        return end

    local smoothPos, smoothVel = SmoothData(mRoot)
    if not smoothPos then return end

    local rawPing = LocalPlayer:GetNetworkPing() * 1000
    if rawPing <= 0 then rawPing = State.PingSmooth or 60 end
    local ping = SmoothPing(rawPing)

    local delta = CalculateLead(smoothPos, smoothVel, myPos, ping, dist)
    local leadX = math_clamp(delta.X * 0.02, -6, 6)
    local leadY = math_clamp(delta.Y * 0.02, -6, 6)
    local leadZ = math_clamp(delta.Z * 0.02, -6, 6)

    if State.Settings.adaptiveLead then
        State.LastError = delta - State.LastError
        AdaptiveCorrection(State.LastError)
    end
    local adapt = State.AdaptiveOffset

    local modeKey = State.CurrentMode
    local mode = MODES[modeKey]
    if not mode then mode = MODES.ADAPTIVE end

    if modeKey == "ADAPTIVE" and mode.auto_switch then
        if dist < 30 then mode = ADAPTIVE_SUBS.CLOSE
        elseif dist < 80 then mode = ADAPTIVE_SUBS.MID
        elseif dist < 150 then mode = ADAPTIVE_SUBS.SNIPER
        else mode = ADAPTIVE_SUBS.DEF end
    end

    local mult = State.Settings.leadMultiplier
    local vertCorr = State.Settings.verticalCorrection
    local speed = smoothVel.Magnitude

    local hLead = (mode.h_base + ping * mode.h_ping + speed * mode.h_speed + leadX * 2) * mult + adapt.x * 3
    hLead = math_clamp(hLead, 80, 500)

    local vLead = (mode.v_base + ping * mode.v_ping + dist * mode.v_dist + leadY * 2) * vertCorr + adapt.y * 3
    vLead = math_clamp(vLead, 80, 450)

    local yOff = 0
    local vertSpeed = smoothVel.Y
    if State.Settings.predictJump then
        if vertSpeed > 3 then
            vLead = vLead + 35
            yOff = yOff + 3
        elseif vertSpeed < -8 then
            vLead = vLead - 25
            yOff = yOff - 4
        end
    end

    local sim = mode.sim_base + speed * mode.sim_speed + math_abs(leadX) * 0.5 + math_abs(adapt.x) * 0.2
    sim = math_clamp(sim, 15, 130)

    local interval = mode.int_base + speed * mode.int_speed - math_abs(leadX) * 0.3 - math_abs(adapt.x) * 0.1
    interval = math_clamp(interval, 5, 120)

    local offX = mode.offX + leadX * 0.5 + adapt.x
    local offY = mode.offY + leadY * 0.5 + yOff + adapt.y
    local offZ = mode.offZ + leadZ * 0.5 + adapt.z

    ApplyGPL(
        math_floor(sim), math_floor(interval),
        math_floor(offX), math_floor(offY), math_floor(offZ),
        math_floor(hLead), math_floor(vLead)
    )
end)

Players.PlayerRemoving:Connect(function(player)
    if State.Target == player then
        State.Target = nil
        State.TargetLockTime = 0
    end
    State.ThreatMap[player] = nil
end)

LocalPlayer.CharacterAdded:Connect(function()
    UpdateCache()
    State.Target = nil
    State.TargetLockTime = 0
    State.LastCheck = 0
    State.TargetPosHistory = {}
    State.TargetVelHistory = {}
    State.SmoothPos = nil
    State.SmoothVel = nil
end)

UpdateCache()
print("═══════════════════════════════════════════════════════════════════════════════════════")
print("  ⚡⚡⚡ ULTRA INSTINCT " .. VERSION .. " ⚡⚡⚡")
print("  🚀 5 УЛЬТРА-РЕЖИМОВ: PRO | INSTINCT | SECRETIVE | ANNIHILATING | ADAPTIVE")
print("  📌 Статус и статистика в консоли (F9)")
print("═══════════════════════════════════════════════════════════════════════════════════════")
