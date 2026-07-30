-- =============================================================================
-- ⚡ ULTRA INSTINCT V24.8 PERF  (fps fix: no RenderStepped, no forced GC,
--    cached murderer, key-gated HUD text. Aim core untouched.)
-- =============================================================================
local shared = odh_shared_plugins
local internal_shared = odh_internal_shared
local gpl_preset = internal_shared and internal_shared.MM2_GPL or nil

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui      = game:GetService("CoreGui")
local LocalPlayer  = Players.LocalPlayer

local clamp,abs,floor,exp = math.clamp,math.abs,math.floor,math.exp
local clock,time = os.clock,os.time
local tinsert = table.insert
local V3 = Vector3.new

local VERSION = "24.8 PERF"
local GRAVITY, BULLET_SPEED = 196.2, 2500
local DEFAULT_REACTION, ADAPTIVE_GAIN, MAX_ADAPT = 0.15, 0.05, 3.0
local MAX_THREAT, HYSTERESIS, HIT_WINDOW, DEAD_ZONE = 500, 15, 0.6, 0.2
local MURDERER_SCAN = 0.5   -- раз в 0.5с один проход ролей (вместо 8/сек в HUD + 2/сек в tick)

if type(_G.__UI_CLEANUP) == "function" then pcall(_G.__UI_CLEANUP) end
local _conns = {}
local function track(c) _conns[#_conns+1] = c; return c end
if not gpl_preset then warn("[UltraInstinct] MM2_GPL not found - aim core disabled, HUD/menu still run.") end

local MODES = {
 PRO          = {h_base=125,h_ping=.22,h_speed=1.5,v_base=125,v_ping=.14,v_dist=.18,sim_base=35,sim_speed=.4,int_base=50,int_speed=-.3,offX=-2,offY=0,offZ=0},
 INSTINCT     = {h_base=145,h_ping=.30,h_speed=1.8,v_base=140,v_ping=.18,v_dist=.22,sim_base=45,sim_speed=.5,int_base=35,int_speed=-.2,offX=-3,offY=0,offZ=2},
 SECRETIVE    = {h_base=105,h_ping=.15,h_speed=1.0,v_base=105,v_ping=.10,v_dist=.12,sim_base=28,sim_speed=.2,int_base=60,int_speed=-.4,offX=0,offY=0,offZ=-1},
 ANNIHILATING = {h_base=185,h_ping=.50,h_speed=3.0,v_base=175,v_ping=.30,v_dist=.35,sim_base=65,sim_speed=1.,int_base=20,int_speed=-.05,offX=-5,offY=0,offZ=5},
 ADAPTIVE     = {h_base=125,h_ping=.22,h_speed=1.5,v_base=125,v_ping=.14,v_dist=.18,sim_base=35,sim_speed=.4,int_base=50,int_speed=-.3,offX=-2,offY=0,offZ=0,auto_switch=true},
}
local ASUB = {
 CLOSE={h_base=135,h_ping=.28,h_speed=1.8,v_base=135,v_ping=.18,v_dist=.22,sim_base=42,sim_speed=.5,int_base=38,int_speed=-.2,offX=-4,offY=0,offZ=3},
 MID  ={h_base=125,h_ping=.22,h_speed=1.5,v_base=125,v_ping=.14,v_dist=.18,sim_base=35,sim_speed=.4,int_base=50,int_speed=-.3,offX=-2,offY=0,offZ=1},
 SNIP ={h_base=95, h_ping=.10,h_speed=.8, v_base=95, v_ping=.08,v_dist=.10,sim_base=22,sim_speed=.15,int_base=68,int_speed=-.5,offX=1,offY=0,offZ=-2},
 DEF  ={h_base=105,h_ping=.15,h_speed=1.0,v_base=105,v_ping=.10,v_dist=.12,sim_base=28,sim_speed=.2,int_base=60,int_speed=-.4,offX=0,offY=0,offZ=-1},
}

local State = {
 Enabled=false, Target=nil, TargetScore=-1e9, TargetLockTime=0, LastCheck=0,
 LastApplied={H=-999,V=-999,Sim=-999,Int=-999,X=-999,Y=-999,Z=-999},
 MyRoot=nil, MyChar=nil, SmoothPos=nil, SmoothVel=nil,
 PingHistory={}, PingSmooth=60, CurrentMode="ADAPTIVE",
 MurdererPlayer=nil,                 -- кэш: обновляется раз в MURDERER_SCAN
 Settings={leadMultiplier=1,verticalCorrection=1,reactionTime=DEFAULT_REACTION,minDistance=3,maxDistance=350,
   useGravity=true,useDrag=true,predictJump=true,targetLock=true,lockTime=2,prioritySystem=true,
   adaptiveLead=true,adaptiveGain=ADAPTIVE_GAIN,maxAdaptiveOffset=MAX_ADAPT},
 Stats={Shots=0,Hits=0,Kills=0,Deaths=0,StartTime=time(),BestStreak=0,CurrentStreak=0},
 ErrorHistory={}, AdaptiveOffset={x=0,y=0,z=0}, AdaptiveConfidence=.5,
 ThreatMap={}, WeaponType="knife", LastShotTime=0, LastShotTarget=nil, ShotArmed=false,
}
local HitMarker = {}

local function GetRoot(p) local c=p and p.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function UpdateCache()
 local c=LocalPlayer.Character
 if c then
  State.MyChar=c; State.MyRoot=c:FindFirstChild("HumanoidRootPart"); State.WeaponType="knife"
  for _,it in ipairs(c:GetChildren()) do if it:IsA("Tool") then
   local n=it.Name:lower()
   if n:find("gun") or n:find("pistol") or n:find("revolver") then State.WeaponType="gun"
   elseif n:find("knife") or n:find("blade") then State.WeaponType="knife" end
   break
  end end
 else State.MyChar,State.MyRoot=nil,nil end
end
local function HasWeapon(p,types)
 if not p or not p.Character then return false end
 types=types or {"knife","blade","dagger","sword","gun","pistol","revolver"}
 local function ck(c) if not c then return false end
  for _,it in ipairs(c:GetChildren()) do if it:IsA("Tool") then local n=it.Name:lower()
   for _,t in ipairs(types) do if n:find(t) then return true end end end end return false end
 return ck(p.Character) or ck(p:FindFirstChild("Backpack"))
end
local function IsMurderer(p)
 if not p then return false end
 if p:GetAttribute("Murderer")==true or p:GetAttribute("isMurderer")==true then return true end
 if HasWeapon(p,{"knife","blade","dagger","sword"}) then return true end
 local c=p.Character; return c and (c:FindFirstChild("Knife") or c:FindFirstChild("Blade")) or false
end
local function IsSheriff(p)
 if not p then return false end
 if p:GetAttribute("Sheriff")==true or p:GetAttribute("isSheriff")==true then return true end
 return HasWeapon(p,{"gun","pistol","revolver"}) and not IsMurderer(p)
end
local function SmoothPing(r) local h=State.PingHistory; tinsert(h,r); if #h>15 then table.remove(h,1) end
 local s=0; for _,v in ipairs(h) do s=s+v end; State.PingSmooth=s/#h; return State.PingSmooth end

-- единственный проход ролей (кэш) — HUD и прицел больше не сканируют сами
local function UpdateMurdererCache()
 local found=nil
 for _,pl in ipairs(Players:GetPlayers()) do
  if pl~=LocalPlayer and IsMurderer(pl) then found=pl; break end
 end
 State.MurdererPlayer=found
end

local function AdaptiveCorrection(err)
 if not State.Settings.adaptiveLead then return end
 local e=V3(abs(err.X)<DEAD_ZONE and 0 or err.X, abs(err.Y)<DEAD_ZONE and 0 or err.Y, abs(err.Z)<DEAD_ZONE and 0 or err.Z)
 local h=State.ErrorHistory; tinsert(h,e); if #h>30 then table.remove(h,1) end
 if #h>=10 then
  local avg=V3(0,0,0); for _,x in ipairs(h) do avg=avg+x end; avg=avg/#h
  local var=0; for _,x in ipairs(h) do var=var+(x-avg).Magnitude end; var=var/#h
  State.AdaptiveConfidence=State.AdaptiveConfidence*.8+clamp(1-var*.12,.2,1)*.2
  local g=State.Settings.adaptiveGain*State.AdaptiveConfidence; local m=State.Settings.maxAdaptiveOffset
  State.AdaptiveOffset.x=clamp(State.AdaptiveOffset.x+avg.X*g,-m,m)
  State.AdaptiveOffset.y=clamp(State.AdaptiveOffset.y+avg.Y*g,-m,m)
  State.AdaptiveOffset.z=clamp(State.AdaptiveOffset.z+avg.Z*g,-m,m)
  State.ErrorHistory={}
 end
end
local function DecayAdaptive()
 local o=State.AdaptiveOffset; o.x,o.y,o.z=o.x*.9,o.y*.9,o.z*.9
 if abs(o.x)<.01 then o.x=0 end; if abs(o.y)<.01 then o.y=0 end; if abs(o.z)<.01 then o.z=0 end
end

local function BuildThreatMap()
 local my=State.MyRoot; if not my then return end; local mp=my.Position; State.ThreatMap={}
 for _,pl in ipairs(Players:GetPlayers()) do if pl~=LocalPlayer then local r=GetRoot(pl)
  if r then local pos=r.Position; local d=(pos-mp).Magnitude; if d>MAX_THREAT then d=MAX_THREAT end
   local sp=r.AssemblyLinearVelocity.Magnitude; local t=0
   if IsMurderer(pl) then t=t+100 elseif IsSheriff(pl) then t=t+30 end
   t=t+(1/(d+1))*50+sp*2
   if r.CFrame.LookVector:Dot((mp-pos).Unit)>.5 then t=t+20 end
   local hum=pl.Character and pl.Character:FindFirstChild("Humanoid")
   if hum and hum.Health<30 then t=t*1.3 end
   State.ThreatMap[pl]=t
  end end end
end
local function resetSmooth() State.SmoothPos,State.SmoothVel=nil,nil end
local function FindBestTarget()
 local now=clock()
 if State.Settings.targetLock and State.Target and State.Target.Parent==Players then
  local c=State.Target.Character
  if c and c:FindFirstChild("Humanoid") and c.Humanoid.Health>0 and (now-State.TargetLockTime<State.Settings.lockTime) then
   if IsMurderer(State.Target) then return State.Target end end end
 if now-State.LastCheck<0.5 then return State.Target end; State.LastCheck=now; BuildThreatMap()
 if not State.MyRoot then return nil end
 local cur=State.ThreatMap[State.Target] or -1e9; if State.Target and IsMurderer(State.Target) then cur=cur*1.5 end
 local best,bs=nil,-1e9
 for pl,th in pairs(State.ThreatMap) do if pl~=LocalPlayer then local s=IsMurderer(pl) and th*1.5 or th
  if s>bs then bs=s; best=pl end end end
 if State.Target and best and best~=State.Target and bs<cur+HYSTERESIS then return State.Target end
 if best~=State.Target then resetSmooth() end
 State.Target=best; State.TargetScore=bs; if best then State.TargetLockTime=now end; return best
end
local function SmoothData(root,dt)
 local p,vel=root.Position,root.AssemblyLinearVelocity
 if not State.SmoothPos then State.SmoothPos,State.SmoothVel=p,vel
 else State.SmoothPos=State.SmoothPos:Lerp(p,1-exp(-dt/0.06)); State.SmoothVel=State.SmoothVel:Lerp(vel,1-exp(-dt/0.10)) end
 return State.SmoothPos,State.SmoothVel
end
local function CalculateLead(sp,sv,mp,ping,dist)
 local bt=dist/(State.WeaponType=="gun" and 3000 or BULLET_SPEED); local tt=bt+ping/1000+State.Settings.reactionTime
 local v=sv; if State.Settings.useDrag then v=v*(0.98^(tt*10)) end
 local pp=sp+v*tt; if State.Settings.useGravity then pp=pp+V3(0,-0.5*GRAVITY*tt*tt,0) end; return pp-sp
end
local function ApplyGPL(sim,interval,x,y,z,h,v)
 if not gpl_preset then return end; local L=State.LastApplied
 if abs(L.H-h)<2 and abs(L.V-v)<2 and abs(L.Sim-sim)<2 and abs(L.Int-interval)<2 and L.X==x and L.Y==y and L.Z==z then return end
 L.H,L.V,L.Sim,L.Int,L.X,L.Y,L.Z=h,v,sim,interval,x,y,z
 pcall(function() if gpl_preset[4]  then gpl_preset[4](sim)      end end)
 pcall(function() if gpl_preset[5]  then gpl_preset[5](interval) end end)
 pcall(function() if gpl_preset[6]  then gpl_preset[6](x)        end end)
 pcall(function() if gpl_preset[7]  then gpl_preset[7](y)        end end)
 pcall(function() if gpl_preset[8]  then gpl_preset[8](z)        end end)
 pcall(function() if gpl_preset[9]  then gpl_preset[9](h)        end end)
 pcall(function() if gpl_preset[10] then gpl_preset[10](v)       end end)
end
local function InitBase()
 if not gpl_preset then return end
 pcall(function() if not internal_shared["RevertSettings_PrioritizeYourPing"] and gpl_preset[1] then gpl_preset[1]() end end)
 pcall(function() if not internal_shared["RevertSettings_PredictJump"]         and gpl_preset[2] then gpl_preset[2]() end end)
 pcall(function() if not internal_shared["RevertSettings_PredictLag"]          and gpl_preset[3] then gpl_preset[3]() end end)
end

-- ====== эвристика попаданий ======
local function RegisterHit()
 local s=State.Stats; s.Hits=s.Hits+1; s.Kills=s.Kills+1; s.CurrentStreak=s.CurrentStreak+1
 if s.CurrentStreak>s.BestStreak then s.BestStreak=s.CurrentStreak end
 State.ShotArmed=false; if HitMarker.Fire then HitMarker.Fire() end
end
local function ArmShot(t) State.LastShotTime=clock(); State.LastShotTarget=t; State.ShotArmed=true end
local function CheckHitProxy()
 if not State.ShotArmed then return end
 local t=State.LastShotTarget
 if not t or not t.Parent then State.ShotArmed=false; return end
 local c=t.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
 if (not c) or (not h) or h.Health<=0 then RegisterHit() elseif clock()-State.LastShotTime>HIT_WINDOW then State.ShotArmed=false end
end

-- ====== компактный HUD + hit-marker (БЕЗ RenderStepped) ======
local HUD={gui=nil,label=nil,stroke=nil,dot=nil,acc=0,hmH=nil,hmV=nil,hm=nil}
local lastHUDKey=nil
local function GetHUDGui()
 local parent; pcall(function() if gethui then parent=gethui() end end)
 pcall(function() if (not parent or typeof(parent)~="Instance") and getcore then parent=getcore() end end)
 if typeof(parent)~="Instance" then parent=CoreGui end
 local sg=parent:FindFirstChild("@ui_hud_v248")
 if not sg then sg=Instance.new("ScreenGui"); sg.Name="@ui_hud_v248"; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true
  pcall(function() sg.ScreenInsets=Enum.ScreenInsets.None end)
  if syn and syn.protect_gui then pcall(syn.protect_gui,sg) end; sg.Parent=parent end
 return sg
end
local function dcol(d) if d<25 then return "#ff5a5a" elseif d<80 then return "#ffb454" else return "#9fb0c0" end end

-- пульс точки через Tween-петлю: ноль Lua в кадре
local function startPulse()
 if not HUD.dot or not HUD.dot.Parent then return end
 local t1=TweenService:Create(HUD.dot,TweenInfo.new(.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Size=UDim2.new(0,11,0,11)})
 t1.Completed:Connect(function(st)
  if st==Enum.PlaybackState.Cancelled then return end
  if not HUD.dot or not HUD.dot.Parent then return end
  local t2=TweenService:Create(HUD.dot,TweenInfo.new(.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Size=UDim2.new(0,7,0,7)})
  t2.Completed:Connect(function(st2) if st2~=Enum.PlaybackState.Cancelled then startPulse() end end)
  t2:Play()
 end)
 t1:Play()
end

local function HUD_Init()
 local sg=GetHUDGui()
 local f=Instance.new("Frame"); f.Name="@uihud"; f.Size=UDim2.new(0,0,0,22); f.AutomaticSize=Enum.AutomaticSize.X
 f.Position=UDim2.new(.5,0,0,36); f.AnchorPoint=Vector2.new(.5,0)
 f.BackgroundColor3=Color3.fromRGB(12,14,18); f.BackgroundTransparency=.12; f.BorderSizePixel=0; f.ZIndex=10; f.Parent=sg
 Instance.new("UICorner",f).CornerRadius=UDim.new(1,0)
 local st=Instance.new("UIStroke",f); st.Color=Color3.fromRGB(70,80,100); st.Thickness=1; st.Transparency=.55
 local li=Instance.new("UIListLayout",f); li.FillDirection=Enum.FillDirection.Horizontal
 li.VerticalAlignment=Enum.VerticalAlignment.Center; li.SortOrder=Enum.SortOrder.LayoutOrder; li.Padding=UDim.new(0,6)
 local pd=Instance.new("UIPadding",f); pd.PaddingLeft=UDim.new(0,9); pd.PaddingRight=UDim.new(0,10)
 pd.PaddingTop=UDim.new(0,4); pd.PaddingBottom=UDim.new(0,4)
 local dot=Instance.new("Frame"); dot.LayoutOrder=1; dot.Size=UDim2.new(0,7,0,7)
 dot.BackgroundColor3=Color3.fromRGB(120,130,150); dot.BorderSizePixel=0; dot.ZIndex=11; dot.Parent=f
 Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
 local lb=Instance.new("TextLabel",f); lb.LayoutOrder=2; lb.Size=UDim2.new(0,0,1,0); lb.AutomaticSize=Enum.AutomaticSize.X
 lb.BackgroundTransparency=1; lb.Font=Enum.Font.GothamBold; lb.RichText=true
 lb.Text='<font color="#788296">⚡OFF</font>'; lb.TextColor3=Color3.fromRGB(220,230,240); lb.TextSize=11; lb.ZIndex=11
 local hm=Instance.new("Frame"); hm.Name="@hitmarker"; hm.Size=UDim2.new(0,40,0,40)
 hm.Position=UDim2.new(.5,0,.5,0); hm.AnchorPoint=Vector2.new(.5,.5); hm.BackgroundTransparency=1; hm.ZIndex=12; hm.Parent=sg
 local hmH=Instance.new("Frame",hm); hmH.Size=UDim2.new(0,24,0,2); hmH.Position=UDim2.new(.5,0,.5,0); hmH.AnchorPoint=Vector2.new(.5,.5)
 hmH.BackgroundColor3=Color3.fromRGB(255,255,255); hmH.BackgroundTransparency=1; hmH.BorderSizePixel=0; Instance.new("UICorner",hmH).CornerRadius=UDim.new(1,0)
 local hmV=Instance.new("Frame",hm); hmV.Size=UDim2.new(0,2,0,24); hmV.Position=UDim2.new(.5,0,.5,0); hmV.AnchorPoint=Vector2.new(.5,.5)
 hmV.BackgroundColor3=Color3.fromRGB(255,255,255); hmV.BackgroundTransparency=1; hmV.BorderSizePixel=0; Instance.new("UICorner",hmV).CornerRadius=UDim.new(1,0)
 HUD.gui,HUD.label,HUD.stroke,HUD.dot,HUD.hm,HUD.hmH,HUD.hmV=sg,lb,st,dot,hm,hmH,hmV
 startPulse()
end
HitMarker.Fire=function()
 if not HUD.hmH then return end
 HUD.hmH.BackgroundTransparency,HUD.hmV.BackgroundTransparency=0,0
 HUD.hmH.BackgroundColor3,HUD.hmV.BackgroundColor3=Color3.fromRGB(255,90,90),Color3.fromRGB(255,90,90)
 HUD.hm.Size=UDim2.new(0,28,0,28)
 TweenService:Create(HUD.hm,TweenInfo.new(.12,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,44,0,44)}):Play()
 TweenService:Create(HUD.hmH,TweenInfo.new(.26),{BackgroundTransparency=1}):Play()
 TweenService:Create(HUD.hmV,TweenInfo.new(.26),{BackgroundTransparency=1}):Play()
end

-- HUD: пересборка текста ТОЛЬКО при смене ключа (нет аллокаций строк в покое)
local function HUD_Update(dt)
 if not HUD.label then return end; HUD.acc=HUD.acc+dt; if HUD.acc<0.12 then return end; HUD.acc=0
 local m=State.MurdererPlayer
 local d5="-"; local hasD=false
 if m and State.MyRoot then local r=GetRoot(m)
  if r then d5=floor((r.Position-State.MyRoot.Position).Magnitude/5); hasD=true end end
 local key=(State.Enabled and 1 or 0).."|"..State.CurrentMode.."|"..(m and m.Name or "-").."|"..d5
 if key==lastHUDKey then return end
 lastHUDKey=key
 if not State.Enabled then
  HUD.label.Text='<font color="#788296">⚡OFF</font>'
  HUD.dot.BackgroundColor3=Color3.fromRGB(120,130,150)
  HUD.stroke.Color=Color3.fromRGB(70,80,100); HUD.stroke.Transparency=.55; return
 end
 local mt='<font color="#7ec8ff">⚡'..State.CurrentMode..'</font>'
 if m then
  local dtxt=hasD and (' <font color="'..dcol(d5*5)..'">'..(d5*5)..'</font>') or ""
  HUD.label.Text=mt..' <font color="#ff6e6e">▸'..m.Name..'</font>'..dtxt
  HUD.dot.BackgroundColor3=Color3.fromRGB(255,90,90)
  HUD.stroke.Color=Color3.fromRGB(255,80,80); HUD.stroke.Transparency=.15
 else
  HUD.label.Text=mt..' <font color="#788296">▸—</font>'
  HUD.dot.BackgroundColor3=Color3.fromRGB(120,180,255)
  HUD.stroke.Color=Color3.fromRGB(120,180,255); HUD.stroke.Transparency=.25
 end
end

-- ====== компактное меню ======
local section=shared.AddSection("⚡ ULTRA INSTINCT "..VERSION)
section:AddToggle("⚡ АКТИВИРОВАТЬ", function(st)
 State.Enabled=st
 if st then InitBase(); UpdateCache(); State.Target=nil else State.Target=nil end
end)
section:AddDropdown("Режим", {"PRO","INSTINCT","SECRETIVE","ANNIHILATING","ADAPTIVE"}, function(s) State.CurrentMode=s; lastHUDKey=nil end)
local g=section:AddToggle("Гравитация", function(s) State.Settings.useGravity=s end); g(true)
local d=section:AddToggle("Сопротивление", function(s) State.Settings.useDrag=s end); d(true)
local j=section:AddToggle("Прыжки", function(s) State.Settings.predictJump=s end); j(true)
local a=section:AddToggle("Адаптив", function(s) State.Settings.adaptiveLead=s end); a(true)
local l=section:AddToggle("Lock цели", function(s) State.Settings.targetLock=s end); l(true)
section:AddButton("Статистика (F9)", function()
 local s=State.Stats; local ac=s.Shots>0 and string.format("%.1f%%",(s.Hits/s.Shots)*100) or "-"
 print("══ ULTRA INSTINCT ══  Shots:"..s.Shots.." Hits:"..s.Hits.." Acc:"..ac.." Kills:"..s.Kills.." Deaths:"..s.Deaths.." Streak:"..s.CurrentStreak.."/"..s.BestStreak.." Mode:"..State.CurrentMode)
end)

-- ====== основной цикл: ОДИН Heartbeat, ноль RenderStepped ======
local _lw=0; local _lastScan=0
local function tick(dt)
 if not State.MyRoot or not State.MyRoot.Parent then UpdateCache(); if not State.MyRoot then DecayAdaptive(); return end end
 CheckHitProxy()
 local target=FindBestTarget()
 if not target then State.Target=nil; DecayAdaptive(); return end
 local mR=GetRoot(target); if not mR then DecayAdaptive(); return end
 local myR=State.MyRoot; local myP=myR.Position; local mP=mR.Position; local dist=(mP-myP).Magnitude
 if dist<State.Settings.minDistance or dist>State.Settings.maxDistance then State.Target=nil; DecayAdaptive(); return end
 local sp,sv=SmoothData(mR,dt); if not sp then return end
 local rp=LocalPlayer:GetNetworkPing()*1000; if rp<=0 then rp=State.PingSmooth or 60 end; local ping=SmoothPing(rp)
 local delta=CalculateLead(sp,sv,myP,ping,dist)
 local lx=clamp(delta.X*.02,-6,6); local ly=clamp(delta.Y*.02,-6,6); local lz=clamp(delta.Z*.02,-6,6)
 if State.Settings.adaptiveLead then AdaptiveCorrection(delta) end
 local ad=State.AdaptiveOffset; local mk=State.CurrentMode; local mode=MODES[mk] or MODES.ADAPTIVE
 if mk=="ADAPTIVE" and mode.auto_switch then
  if dist<30 then mode=ASUB.CLOSE elseif dist<80 then mode=ASUB.MID elseif dist<150 then mode=ASUB.SNIP else mode=ASUB.DEF end end
 local mult=State.Settings.leadMultiplier; local vc=State.Settings.verticalCorrection; local speed=sv.Magnitude
 local hL=clamp((mode.h_base+ping*mode.h_ping+speed*mode.h_speed+lx*2)*mult+ad.x*3,80,500)
 local vL=clamp((mode.v_base+ping*mode.v_ping+dist*mode.v_dist+ly*2)*vc+ad.y*3,80,450); local yO=0
 if State.Settings.predictJump then local vs=sv.Y; if vs>3 then vL=vL+35; yO=yO+3 elseif vs<-8 then vL=vL-25; yO=yO-4 end end
 local sim=clamp(mode.sim_base+speed*mode.sim_speed+abs(lx)*.5+abs(ad.x)*.2,15,130)
 local intv=clamp(mode.int_base+speed*mode.int_speed-abs(lx)*.3-abs(ad.x)*.1,5,120)
 local oX=mode.offX+lx*.5+ad.x; local oY=mode.offY+ly*.5+yO+ad.y; local oZ=mode.offZ+lz*.5+ad.z
 ApplyGPL(floor(sim),floor(intv),floor(oX),floor(oY),floor(oZ),floor(hL),floor(vL))
end

track(RunService.Heartbeat:Connect(function(dt)
 local now=clock()
 if now-_lastScan>=MURDERER_SCAN then _lastScan=now; UpdateMurdererCache() end  -- один проход ролей на всех
 HUD_Update(dt)
 if State.Enabled then
  local ok,err=pcall(tick,dt)
  if not ok then if now-_lw>5 then _lw=now; warn("[UltraInstinct] "..tostring(err)) end end
 end
end))

track(Players.PlayerRemoving:Connect(function(p)
 if State.Target==p then State.Target=nil; State.TargetLockTime=0 end
 if State.MurdererPlayer==p then State.MurdererPlayer=nil end   -- инвалидация кэша
 State.ThreatMap[p]=nil
end))
track(LocalPlayer.CharacterAdded:Connect(function()
 UpdateCache(); State.Target=nil; State.TargetLockTime=0; State.LastCheck=0; resetSmooth(); lastHUDKey=nil
end))

local function hookChar(char)
 local hum=char:WaitForChild("Humanoid",5)
 if hum then track(hum.Died:Connect(function() State.Stats.Deaths=State.Stats.Deaths+1; State.Stats.CurrentStreak=0 end)) end
 local function hookTool(it) if it:IsA("Tool") then track(it.Activated:Connect(function()
  if State.Enabled and State.WeaponType=="gun" then State.Stats.Shots=State.Stats.Shots+1; ArmShot(State.Target) end
 end)) end end
 for _,it in ipairs(char:GetChildren()) do hookTool(it) end
 track(char.ChildAdded:Connect(hookTool))
end
track(LocalPlayer.CharacterAdded:Connect(hookChar))
pcall(function() if LocalPlayer.Character then hookChar(LocalPlayer.Character) end end)

local function cleanup()
 State.Enabled=false; for _,c in ipairs(_conns) do pcall(function() c:Disconnect() end) end; _conns={}
 pcall(function() if HUD.gui then HUD.gui:Destroy() end end)
 HUD.gui,HUD.label,HUD.stroke,HUD.dot,HUD.hm,HUD.hmH,HUD.hmV=nil,nil,nil,nil,nil,nil,nil
 lastHUDKey=nil
 if _G.__UI_CLEANUP==cleanup then _G.__UI_CLEANUP=nil end
end
_G.__UI_CLEANUP=cleanup

UpdateCache(); UpdateMurdererCache(); HUD_Init()
print("⚡ ULTRA INSTINCT "..VERSION.." loaded (perf: no RenderStepped/GC, cached roles, key-gated HUD).")
