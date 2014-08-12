if myHero.charName ~= "Veigar" then return end
local version = 1.4
--[GLOBALS]
local DFG = GetInventorySlotItem(3128)
local ignite = nil
local qRange = 650
local lastFarmCheck = 0
local farmCheckTick = 100
local int1 = 0
local int2 = 0
local int3 = 0
local eTarget = nil
local CT = 1000
local Comboing = false
local ComboTick = 0

--[KEYS]
local autoFarmKey = string.byte("J")
local ExtraInfoKey = string.byte("Z")
local AutoBuy = string.byte("P")
local MainCalcKey = string.byte("A")
local AutoWKey = string.byte("G")

--[SKILL INFO]
local Q = 0
local W = 0
local R = 0
local ignitos = 0
local DFGI = 0

local eradius = 330 
local erange = 600
local wRange = 900

--[SKILL LVLS]
local Qlevel = 0
local Wlevel = 0
local Elevel = 0
local Rlevel = 0

--[Skill attributes]
local qrange = 650
local wcastspeed = 1.25 
local wrange = 900
local wradius = 230 
local eradius = 330 
local erange = 600
local ecastspeed = 0.34 

--[MANACOSTS]
local QMana = {60, 65, 70, 75, 80}
local WMana = {70, 80, 90, 100, 110}
local EMana = { 80, 90, 100, 110, 120}
local RMana = {125, 175, 225}
local ComboMana = GetSpellData(_Q).mana + GetSpellData(_W).mana + GetSpellData(_E).mana + GetSpellData(_R).mana

--[AUTO POTIONS]
local hppot = 0
local mppot = 0
local elixir = 0
local flaskk = 0
local Biscuit = 0

--[LAG FREE INFO]
 local eCircleColor = ARGB(255,255,0,255)--0xB820C3 -- purple by default
 local wCircleColor = ARGB(255,255,0,0)--0xEA3737 -- orange by default
 local qCircleColor = ARGB(255,0,255,0)--0x19A712 --green by default

function OnTick()
	ts:update()
	AutoBuyy()
	autoFarm()
	ManaCosts()
	AutoWharrasQ()
	ExtraExtraInfo()
	DFGcheck()
	EWandCage()
	SmartCombo()
	Potions()
end

function OnDraw()
	ManaRegenSec()
	if not myHero.dead or VeigarConfig.other.Death then
		DamageCalculator()
		ExtraInformation()
		Drawing()
	end
end

function OnLoad()
	player = myHero
	PrintChat("<font color=\"#ffffff\">You are using Veigar Little Helper ["..version.."] by DedToto.</font>")
	player = GetMyHero()
	UpdateCheck()
	IgniteCheck()
	spaceHK = 32
	
	VeigarConfig = scriptConfig("Little Veigar Helper", "littlehelper")
	VeigarConfig:addSubMenu("Drawing","draw")
		VeigarConfig.draw:addParam("Erange", "Draw E range", SCRIPT_PARAM_ONOFF, true)
		VeigarConfig.draw:addParam("ErangeMax", "Draw E rangeMax", SCRIPT_PARAM_ONOFF, false)
		VeigarConfig.draw:addParam("Wrange", "Draw W range", SCRIPT_PARAM_ONOFF, false)
		VeigarConfig.draw:addParam("drawLagFree","Lag free circles", SCRIPT_PARAM_ONOFF, false)
		VeigarConfig.draw:addParam("chordLength","Lag Free Chord Length", SCRIPT_PARAM_SLICE, 75, 75, 2000, 0)
		
	VeigarConfig:addSubMenu("AutoFarm","farm")
		VeigarConfig.farm:addParam("autoFarm", "Auto farm with Q", SCRIPT_PARAM_ONKEYTOGGLE, false, autoFarmKey)
		VeigarConfig.farm:addParam("manasavep", "Mana % to conserve", SCRIPT_PARAM_SLICE, 1, 1, 100, 0)
		VeigarConfig.farm:addParam("manasave", "Conserve mana during farm", SCRIPT_PARAM_ONOFF,false)
		VeigarConfig.farm:addParam("SaveE", "Dont farm if Mana < EManaCost",  SCRIPT_PARAM_ONOFF, true)
		
	VeigarConfig:addSubMenu("Harras","harras")
		VeigarConfig.harras:addParam("Qharras", "Harras enemy in range with Q", SCRIPT_PARAM_ONKEYDOWN, false, spaceHK)
		VeigarConfig.harras:addParam("manasaveQP", "Mana % to conserve", SCRIPT_PARAM_SLICE, 1, 1, 100, 0)
		VeigarConfig.harras:addParam("manasaveQ", "Conserve mana during harras", SCRIPT_PARAM_ONOFF,false)
		VeigarConfig.harras:addParam("eCastActive", "Use E+W", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("E"))
		VeigarConfig.harras:addParam("addq", "use Q in E+W Combo", SCRIPT_PARAM_ONOFF, false)

	VeigarConfig:addSubMenu("Auto Potions","AP")
		VeigarConfig.AP:addParam("hp", "Use potions when HP < %", SCRIPT_PARAM_SLICE, 0, 1, 100, 0)
		VeigarConfig.AP:addParam("mp", "Use potions when Mana < %", SCRIPT_PARAM_SLICE, 0, 1, 100, 0)
		VeigarConfig.AP:addParam("flask", "Use flask as HP potion settings", SCRIPT_PARAM_ONOFF, true)
		VeigarConfig.AP:addParam("elixir", "Auto Elixir of Fortitude when  < %", SCRIPT_PARAM_SLICE, 0, 1, 100, 0)		

	VeigarConfig:addSubMenu("Other","other")
		VeigarConfig.other:addParam("autoW", "Auto W Stunned Enemies", SCRIPT_PARAM_ONOFF, false)
		VeigarConfig.other:addParam("AutoBuy", "Buy Starting Items", SCRIPT_PARAM_ONKEYDOWN, false, AutoBuy)
		VeigarConfig.other:addParam("ShowMana", "Show Time For Mana Regen", SCRIPT_PARAM_ONOFF, true)
		VeigarConfig.other:addParam("Death", "Show Info After Death", SCRIPT_PARAM_ONOFF, false)
		VeigarConfig.other:addParam("ExtraInfo", "Show Best Killing Combo", SCRIPT_PARAM_ONKEYTOGGLE, true, ExtraInfoKey)
		VeigarConfig.other:addParam("MainCalc", "Show Main Calculations", SCRIPT_PARAM_ONKEYTOGGLE, true, MainCalcKey)
	
	VeigarConfig:addParam("spacebarActive", "SpaceToWin", SCRIPT_PARAM_ONKEYDOWN, false, spaceHK)
	VeigarConfig:addParam("cageTeamActive", "Cage Team", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
	
	VeigarConfig:permaShow("spacebarActive")
	VeigarConfig.farm:permaShow("autoFarm")
	VeigarConfig.other:permaShow("ExtraInfo")
	
	VP = VPrediction(true)
	NSOW = SOW(VP)
	ts = TargetSelector(TARGET_LOW_HP, erange + eradius, DAMAGE_MAGIC)
	ts.name = "Veigar"
	VeigarConfig:addTS(ts)
	VeigarConfig:addSubMenu("["..myHero.charName.." - OrbWalking]", "OrbWalking")
		NSOW:LoadToMenu(VeigarConfig.OrbWalking)
	
end

function DamageCalculator()
	
	if VeigarConfig.other.MainCalc then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) then
			local Qdmg = getDmg("Q", enemy, myHero)
			local Wdmg = getDmg("W", enemy, myHero)
			local Rdmg = getDmg("R", enemy, myHero)
			local AAdmg = (getDmg("AD", enemy, myHero))
			local DFGdmg = 0
			local IGNITEdmg = 50 + 20 * myHero.level
			local DMG = 0 + AAdmg
			if DFGI ~= 0 then DFGdmg = getDmg("DFG", enemy ,myHero) end
				
			if DFGI ~= 0 then
			local DFGDMG = 0
			if CanUseSpell(_Q) == READY then DFGDMG = DFGDMG + Qdmg end
			if CanUseSpell(_W) == READY then DFGDMG = DFGDMG + Wdmg end
			if CanUseSpell(_R) == READY then DFGDMG = DFGDMG + Rdmg end
			DFGDMG = DFGDMG * 1.2
			DMG = DMG + DFGDMG
			
			IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
			if IREADY then DMG = DMG + IGNITEdmg end
			DMG = DMG + DFGdmg
				
			else
			if CanUseSpell(_Q) == READY then DMG = DMG + Qdmg end
			if CanUseSpell(_W) == READY then DMG = DMG + Wdmg end
			if CanUseSpell(_R) == READY then DMG = DMG + Rdmg end
			IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
			if IREADY then DMG = DMG + IGNITEdmg end
			end

				if enemy.health <= DMG then
				DrawText3D(""..math.floor((DMG - enemy.health)+0.5).." Extra !!", enemy.x, enemy.y, enemy.z, 25, RGB(255, 0, 0), true)
				else
				DrawText3D(""..math.floor((enemy.health - DMG)+0.5).." More !!", enemy.x, enemy.y, enemy.z, 25, RGB(255, 255, 255), true)
				end
			end
		end
	end
	
end

function ExtraInformation()

	if VeigarConfig.other.ExtraInfo then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) then
				--target = ts.target
				local Qdmg = getDmg("Q", enemy, myHero)
				local Wdmg = getDmg("W", enemy, myHero)
				local Rdmg = getDmg("R", enemy, myHero)
				local AAdmg = (getDmg("AD", enemy, myHero))
				local DFGdmg = 0
				local IGNITEdmg = 50 + 20 * myHero.level
				local DMG = 0 + AAdmg
				local Qdmgi = Qdmg * 1.2
				local Wdmgi = Wdmg * 1.2
				local Rdmgi = Rdmg * 1.2
					
				if DFGI ~= 0 then DFGdmg = getDmg("DFG", enemy ,myHero) end
				
				if (enemy.health < (Qdmg + AAdmg) and Q ~= 0 ) then																																					--Q
					DrawText3D(("Q"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true) 
					--if enemy == ts.target and VeigarConfig.spacebarActive then performcombo1() end
					elseif (enemy.health < (Qdmgi + AAdmg + DFGdmg) and Q ~= 0 and DFGI ~= 0) then																													--DFG Q
					DrawText3D(("|DFG|Q"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					--if enemy == ts.target and VeigarConfig.spacebarActive then performcombo2() end
					elseif (enemy.health < (Qdmg + Wdmg + AAdmg) and Q ~= 0 and W ~= 0 ) then 																														--Q+W
					DrawText3D(("Q+W"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
				--	if enemy == ts.target and VeigarConfig.spacebarActive then performcombo3() end
					elseif (enemy.health < (Qdmgi + Wdmgi + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and DFGI ~= 0) then 																								--DFG Q+W
					DrawText3D(("|DFG|Q+W"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
				--	if enemy == ts.target and VeigarConfig.spacebarActive then performcombo4() end
					elseif (enemy.health < (Qdmg + Wdmg + IGNITEdmg + AAdmg) and Q ~= 0 and W ~= 0 and ignitos ~= 0 ) then																							--Q+W+IGN
					DrawText3D(("Q+W+IGN"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					--if enemy == ts.target and VeigarConfig.spacebarActive then performcombo5() end
					elseif (enemy.health < (Qdmgi + Wdmgi + IGNITEdmg + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and ignitos ~= 0 and DFGI ~= 0) then																	--DFG Q+W+IGN
					DrawText3D(("|DFG|Q+W+IGN"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
				--	if enemy == ts.target and VeigarConfig.spacebarActive then performcombo6() end
					elseif (enemy.health < (Qdmg + AAdmg + Rdmg) and Q ~= 0 and R ~= 0 ) then																														--Q+R
					DrawText3D(("Q+R"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					--if enemy == ts.target and VeigarConfig.spacebarActive then performcombo7() end
					elseif (enemy.health < (Qdmgi + AAdmg + DFGdmg + Rdmgi) and Q ~= 0 and R ~= 0 and DFGI ~= 0) then																								--DFG Q+R
					DrawText3D(("|DFG|Q+R"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					--if enemy == ts.target and VeigarConfig.spacebarActive then performcombo8() end
					elseif (enemy.health < (Qdmg + IGNITEdmg + AAdmg + Rdmg) and Q ~= 0 and R ~= 0 and ignitos ~= 0 ) then																							--Q+R+IGN
					DrawText3D(("Q+R+IGN"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					--if enemy == ts.target and VeigarConfig.spacebarActive then performcombo9() end
					elseif (enemy.health < (Qdmgi + IGNITEdmg + AAdmg + DFGdmg + Rdmgi) and Q ~= 0 and R ~= 0 and ignitos ~= 0 and DFGI ~= 0) then																	--DFG Q+R+IGN
					DrawText3D(("|DFG|Q+R+IGN"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					--if enemy == ts.target and VeigarConfig.spacebarActive then performcombo10() end
					elseif (enemy.health < (Qdmg + Wdmg + Rdmg + AAdmg ) and Q ~= 0 and W ~= 0 and R ~= 0 ) then																									--Q+W+R
					DrawText3D(("Q+W+R"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					--if enemy == ts.target and VeigarConfig.spacebarActive then performcombo11() end
					elseif (enemy.health < (Qdmgi + Wdmgi + Rdmgi + AAdmg + DFGdmg ) and Q ~= 0 and W ~= 0 and R ~= 0 and DFGI ~= 0) then																			--DFG Q+W+R
					DrawText3D(("|DFG|Q+W+R"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					--if enemy == ts.target and VeigarConfig.spacebarActive then performcombo12() end
					elseif (enemy.health < (Qdmg + Wdmg + Rdmg + IGNITEdmg + AAdmg ) and Q ~= 0 and W ~= 0 and R ~= 0 and ignitos ~= 0 ) then																		--Q+W+R+IGN
					DrawText3D(("Q+W+R+IGN"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					--if enemy == ts.target and VeigarConfig.spacebarActive then performcombo13() end
					elseif (enemy.health < (Qdmgi + Wdmgi + Rdmgi + IGNITEdmg + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and R ~= 0 and ignitos ~= 0 and DFGI ~= 0) then												--DFG Q+W+R+IGN
					DrawText3D(("|DFG|Q+W+R+IGN"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					--if enemy == ts.target and VeigarConfig.spacebarActive then performcombo14() end
					elseif (enemy.health > (Qdmgi + Wdmgi + Rdmgi + IGNITEdmg + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and R ~= 0 and ignitos ~= 0 and DFGI ~= 0) then												--unkillable
					--if enemy == ts.target and VeigarConfig.spacebarActive then performcombo15() end
				end
			end
		end
	end
end

function autoFarm()

	local usedQ = false
	if VeigarConfig.farm.autoFarm and GetTickCount() > lastFarmCheck + farmCheckTick then
		if (VeigarConfig.farm.manasave and manaPct() > VeigarConfig.farm.manasavep) or not VeigarConfig.farm.manasave then
			if myHero.mana > ComboManaCost({_Q, _E}) or not VeigarConfig.farm.SaveE then
				if CanUseSpell(_Q) then
					for k = 1, objManager.maxObjects do
						if not usedQ then
							local minion = objManager:GetObject(k)
							if minion ~= nil and minion.name:find("Minion_") and minion.team ~= myHero.team and minion.dead == false and GetDistance(minion) < qRange then
								local qDamage = getDmg("Q",minion,myHero)
								if qDamage >= minion.health then
									CastSpell(_Q, minion)
									usedQ = true
								end
							end
						end
					end
				end
				lastFarmCheck = GetTickCount()
			end
		end
	end
end

function AutoWharrasQ()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then
			if VeigarConfig.other.autoW and player:CanUseSpell(_W) == READY and enemy.canMove ~= true and IsGoodTarget(enemy, wRange) then
				CastSpell(_W, enemy)
				return
			end
			
			if VeigarConfig.harras.Qharras and IsGoodTarget(enemy, qRange) then
				if (VeigarConfig.harras.manasaveQ and manaPct() > VeigarConfig.harras.manasaveQP) or not VeigarConfig.harras.manasaveQ then
					CastSpell(_Q, enemy) -- cast spell
					return
				end
				
			end
		end
	end
end

function EWandCage()
local players = heroManager.iCount
  if VeigarConfig.harras.eCastActive == true and not player.dead then
    if eTarget then
      if not targetvalid(eTarget) then
        eTarget = nil
      end
    end
    if eTarget == nil then
      if ts.target then
        eTarget = ts.target
      else
        for i = 1, heroManager.iCount, 1 do
          local testTarget = heroManager:getHero(i)
          if targetvalid(testTarget) then
            eTarget = testTarget
          end
        end
      end
    end

    if eTarget then
      useStunCombo(eTarget)
	  if VeigarConfig.harras.addq then
		UseSpell(_Q, eTarget)
	  end
    end
  end

  if VeigarConfig.cageTeamActive == true and ts.target ~= nil and not player.dead then
    local spellPos = FindGroupCenterFromNearestEnemies(eradius, erange)
    if spellPos ~= nil then
      UseSpell(_E, spellPos.center.x, spellPos.center.z)
    end
  end  
end

function Drawing()
	if VeigarConfig.draw.Erange then
		CustomDrawCircle(player.x, player.y, player.z, qRange, qCircleColor)
	end
		
	if VeigarConfig.draw.ErangeMax then
		CustomDrawCircle(player.x, player.y, player.z, erange + eradius, eCircleColor)
	end
		
	if VeigarConfig.draw.Wrange then
		CustomDrawCircle(player.x, player.y, player.z, wRange, wCircleColor)
	end
end

function useStunCombo(object)
  local spellPos, hitchance
  if player:CanUseSpell(_E) == READY and not object.dead then
    castESpellOnTarget(object)
  end
  
    if player:CanUseSpell(_W) == READY and not object.dead then
    if object and targetvalid(object) then
      spellPos, hitchance = VP:GetCircularCastPosition(object, wcastspeed, wradius, wrange)
      if spellPos and (hitchance >= 3) then
        UseSpell(_W, spellPos.x, spellPos.z)
        else
         UseSpell(_W, object)
      end
    end
  end
end

function targetvalid(target)
  return target ~= nil and target.team ~= player.team and target.visible and not target.dead and GetDistanceTo(player, target) <= (erange + eradius)
end

function GetDistanceTo(target1, target2)
  local dis
  if target2 ~= nil and target1 ~= nil then
    dis = math.sqrt((target2.x - target1.x) ^ 2 + (target2.z - target1.z) ^ 2)
  end
  return dis
end

function castESpellOnTarget(object)

  if player:CanUseSpell(_E) then

    local target1 = object
    local CircX, CircZ, returnTarget
    local players = heroManager.iCount
    for j = 1, players, 1 do

      local target2 = heroManager:getHero(j)
      if targetvalid(target1) and targetvalid(target2) and target1.name ~= target2.name then --make sure both targets are valid enemies and in spell range
        if targetsinradius(target1, target2) and CircX == nil and CircZ == nil then --true if a double stun is possible

          CircX, CircZ = calcdoublestun(target1, target2) --calculates coords for stun
          if CircX and CircZ then
            break
          end
      end
      end
    end

    if CircX == nil or CircZ == nil then --true if double stun coords were not found
      if targetvalid(object) then
        CircX, CircZ = calcsinglestun() --calculate stun coords for a single target
    end
    end
    if CircX and CircZ then --true if any coords were found
      UseSpell(_E, CircX, CircZ)
    end
  end
end

function targetsinradius(target1, target2)
  local dis, dis1, dis2, predicted1, predicted2, hitchance1, hitchance2

  predicted1, hitchance1 = VP:GetPredictedPos(target1, ecastspeed)
  predicted2, hitchance2  = VP:GetPredictedPos(target2, ecastspeed)

  if predicted1 and predicted2 then
    dis = math.sqrt((predicted2.x - predicted1.x) ^ 2 + (predicted2.z - predicted1.z) ^ 2) --find the distance between the two targets

    dis1 = math.sqrt((predicted1.x - player.x) ^ 2 + (predicted1.z - player.z) ^ 2) --distance from player to predicted target 1
    dis2 = math.sqrt((predicted2.x - player.x) ^ 2 + (predicted2.z - player.z) ^ 2) --distance from player to predicted target 2
  end

  return dis ~= nil and dis <= (eradius * 2) and dis1 <= (eradius + erange) and dis2 <= (eradius + erange)
end


function calcsinglestun()
  if (ts.target ~= nil) and player:CanUseSpell(SPELL_3) == READY then
    local predicted, hitchance1

    predicted, hitchance1 = VP:GetPredictedPos(ts.target, ecastspeed)


    if predicted and (hitchance1 >=2) then
      local CircX, CircZ
      local dis = math.sqrt((player.x - predicted.x) ^ 2 + (player.z - predicted.z) ^ 2)
      CircX = predicted.x + eradius * ((player.x - predicted.x) / dis)
      CircZ = predicted.z + eradius * ((player.z - predicted.z) / dis)
      return CircX, CircZ
    end
  end
end

function calcdoublestun(target1, target2)

  local CircX, CircZ, predicted1, predicted2, hitchance1, hitchance2

  predicted1, hitchance1 = VP:GetPredictedPos(target1, ecastspeed)
  predicted2, hitchance2  = VP:GetPredictedPos(target2, ecastspeed)

  if predicted1 and predicted2 and (hitchance1 >=2) and (hitchance2 >=2) then

    local h1 = predicted1.x
    local k1 = predicted1.z
    local h2 = predicted2.x
    local k2 = predicted2.z

    local u = (h1) ^ 2 + (h2) ^ 2 - 2 * (h1) * (h2) - (k1) ^ 2 + (k2) ^ 2
    local w = k1 - k2
    local v = h2 - h1

    local a = 4 * (w ^ 2 + v ^ 2)
    local b = 4 * (u * w - 2 * ((v) ^ 2) * (k1))
    local c = (u) ^ 2 - 4 * ((v ^ 2)) * (eradius ^ 2 - k1 ^ 2)

    local Z1 = ((-b) + math.sqrt((b) ^ 2 - 4 * a * c)) / (2 * a) --Z coord for first solution
    local Z2 = ((-b) - math.sqrt((b) ^ 2 - 4 * a * c)) / (2 * a) --Z coord for second solution

    local d = (Z1 - k1) ^ 2 - (eradius) ^ 2
    local e = (Z1 - k2) ^ 2 - (eradius) ^ 2

    local X1 = ((h2) ^ 2 - (h1) ^ 2 - d + e) / (2 * v) -- X Coord for first solution

    local p = (Z2 - k1) ^ 2 - (eradius) ^ 2
    local q = (Z2 - k2) ^ 2 - (eradius) ^ 2

    local X2 = ((h2) ^ 2 - (h1) ^ 2 - p + q) / (2 * v) --X Coord for second solution


    --determine if these 2 points are within range, and which is closest

    local dis1 = math.sqrt((X1 - player.x) ^ 2 + (Z1 - player.z) ^ 2)
    local dis2 = math.sqrt((X2 - player.x) ^ 2 + (Z2 - player.z) ^ 2)

    if dis1 <= (eradius + erange) and dis1 <= dis2 then
      CircX = X1
      CircZ = Z1
    end
    if dis2 <= (eradius + erange) and dis2 < dis1 then
      CircX = X2
      CircZ = Z2
    end
  end
  return CircX, CircZ
end

function UseSpell(Spell,param1,param2)
    if param1 and param2 then
      CastSpell(Spell,param1,param2)
    elseif param1 then
      CastSpell(Spell,param1)
    else
      CastSpell(Spell)
    end
end

function AutoBuyy()
	if VeigarConfig.other.AutoBuy and int1 ~= 1 then
		--You can change these items but don't touch int1.
		BuyItem(1004)
		BuyItem(2003)
		BuyItem(2003)
		BuyItem(2003)
		BuyItem(2003)
		BuyItem(2003)
		BuyItem(2004)
		BuyItem(2004)
		BuyItem(2004)
		int1 = 1
	end
end

function ManaRegenSec()
	if VeigarConfig.other.ShowMana then
		if not myHero.dead or VeigarConfig.other.Death then
			if myHero.mana < ComboManaCost({_Q, _W, _E, _R}) then
				DrawNoMana()
			end
		end
	end
end

function UpdateCheck()
local AUTOUPDATE = true
local SCRIPT_NAME = "Veigar Little Helper"
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"
local DownloadSourceLib = false

	if FileExist(SOURCELIB_PATH) then
		require("SourceLib")
	else
		DownloadSourceLib = true
		DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() PrintChat("SourceLib downloaded, please reload (F9)") end)
	end

	if DownloadSourceLib then print("Downloading required libraries, please wait...") return end

	if AUTOUPDATE then
		SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/DedToto/Veigar-Little-Helper/master/Veigar Little Helper.lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/DedToto/Veigar-Little-Helper/master/"..SCRIPT_NAME..".version"):CheckUpdate()
	end

	local libDownload = Require("SourceLib")
	libDownload:Add("vPrediction", "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua")
	libDownload:Add("SOW", "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua")
	libDownload:Check()

	if libDownload.downloadNeeded == true then return end
end

function IgniteCheck()
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
        ignite = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
        ignite = SUMMONER_2
    end
end

function DFGcheck()
	if GetInventorySlotItem(3128) ~= nil then
		int2 = 1
		else
		int2 = 0
	end
	
	if int2 ~= 0 then 
	local DFG = GetInventorySlotItem(3128)
		if DFG ~= nil and myHero:CanUseSpell(DFG) == READY then
			DFGI = 1
		else
			DFGI = 0
		end
	end
end

function ManaCosts()
	Qlevel = myHero:GetSpellData(_Q).level
	Wlevel = myHero:GetSpellData(_W).level
	Elevel = myHero:GetSpellData(_E).level
	Rlevel = myHero:GetSpellData(_R).level
end

function DrawNoMana()
	timetoregen = (ComboManaCost({_Q, _W, _E, _R}) - myHero.mana) / myHero.mpRegen
	DrawText3D("No Mana ("..math.floor(timetoregen).."s) !!", myHero.x, myHero.y, myHero.z, 25, RGB(48, 213, 200), true)
end

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
  chordlength = chorlength or VeigarConfig.draw.chordLength
  radius = radius or 300
  quality = math.max(8,math.floor(180/math.deg((math.asin((chordlength/(2*radius)))))))
  quality = 2 * math.pi / quality
  radius = radius*.92
  local points = {}
  for theta = 0, 2 * math.pi + quality, quality do
    local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
    points[#points + 1] = D3DXVECTOR2(c.x, c.y)
  end
  DrawLines2(points, width or 1, color or 4294967295)
end

function CustomDrawCircle(x, y, z, radius, color)
  local vPos1 = Vector(x, y, z)
  local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
  local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
  local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))

  if not VeigarConfig.draw.drawLagFree then

    return DrawCircle(x, y, z, radius, color)
  end
  if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
    DrawCircleNextLvl(x, y, z, radius, 1, color, 75)
  end
end

function ExtraExtraInfo()
	if CanUseSpell(_Q) == READY then
	Q = 1
	else
	Q = 0
	end
	
	if CanUseSpell(_W) == READY then
	W = 1
	else
	W = 0
	end
	
	if CanUseSpell(_R) == READY then
	R = 1
	else
	R = 0
	end
	
	if ignite ~= nil and myHero:CanUseSpell(ignite) == READY then
	ignitos = 1
	else
	ignitos = 0
	end
	
end

function ComboManaCost(Combo)
	local Result = 0	
	for i, spell in ipairs(Combo) do
		Result = Result + ManaCost(spell)
	end
	return Result
end

function manaPct()
  return math.round((myHero.mana / myHero.maxMana)*100)
end

function IsGoodTarget(target, range)
	return player:GetDistance(target) < range and target.valid and target.dead == false
	and target.bMagicImunebMagicImune ~= true and target.bInvulnerable ~= true and target.visible
end

function moveToMouse()
    myHero:MoveTo(mousePos.x, mousePos.z)
end

function ManaCost(Spell)
	if Spell == _Q and Qlevel ~= 0 then
		return QMana[Qlevel]
	elseif Spell == _W and Wlevel ~= 0 then
		return WMana[Wlevel]
	elseif Spell == _E and Elevel ~= 0 then
		return EMana[Elevel]
	elseif Spell == _R and Rlevel ~= 0 then
		return RMana[Rlevel]
	end
	return 0
end

class'Circle'
function Circle:__init(center, radius)
  assert((VectorType(center) or center == nil) and (type(radius) == "number" or radius == nil), "Circle: wrong argument types (expected <Vector> or nil, <number> or nil)")
  self.center = Vector(center) or Vector()
  self.radius = radius or 0
end

function Circle:Contains(v)
  assert(VectorType(v), "Contains: wrong argument types (expected <Vector>)")
  return math.close(self.center:dist(v), self.radius)
end

function Circle:__tostring()
  return "{center: " .. tostring(self.center) .. ", radius: " .. tostring(self.radius) .. "}"
end

function CQ()
	if ts.target ~= nil then
		CastSpell(_Q, ts.target)
	end
end

function CR()
	if ts.target ~= nil then
		CastSpell(_R, ts.target)
	end
end

function CW(target)
	if target ~= nil and not target.canMove then
		CastSpell(_W, target)
	end
end

function CDFG()
	if ts.target ~= nil then
		CastSpell(DFG, ts.target)
	end
end

function CIGN()
	if ts.target ~= nil then
		CastSpell(ignite, ts.target)
	end
end

function ComboDMG()
		if ValidTarget(ts.target) then
				local Qdmg = getDmg("Q", ts.target, myHero)
				local Wdmg = getDmg("W", ts.target, myHero)
				local Rdmg = getDmg("R", ts.target, myHero)
				local AAdmg = (getDmg("AD", ts.target, myHero))
				local DFGdmg = 0
				local IGNITEdmg = 50 + 20 * myHero.level
				local DMG = 0 + AAdmg
				local Qdmgi = Qdmg * 1.2
				local Wdmgi = Wdmg * 1.2
				local Rdmgi = Rdmg * 1.2
					
				if DFGI ~= 0 then DFGdmg = getDmg("DFG", ts.target,myHero) end
			if (ts.target.health < (Qdmg + AAdmg) and Q ~= 0 ) then																																					--Q
				int3 = 1
				elseif (ts.target.health < (Qdmgi + AAdmg + DFGdmg) and Q ~= 0 and DFGI ~= 0) then																													--DFG Q
				int3 = 2
				elseif (ts.target.health < (Qdmg + Wdmg + AAdmg) and Q ~= 0 and W ~= 0 ) then 																														--Q+W
				int3 = 3
				elseif (ts.target.health < (Qdmgi + Wdmgi + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and DFGI ~= 0) then 																								--DFG Q+W
				int3 = 4
				elseif (ts.target.health < (Qdmg + Wdmg + IGNITEdmg + AAdmg) and Q ~= 0 and W ~= 0 and ignitos ~= 0 ) then																							--Q+W+IGN
				int3 = 5
				elseif (ts.target.health < (Qdmgi + Wdmgi + IGNITEdmg + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and ignitos ~= 0 and DFGI ~= 0) then																	--DFG Q+W+IGN
				int3 = 6
				elseif (ts.target.health < (Qdmg + AAdmg + Rdmg) and Q ~= 0 and R ~= 0 ) then																														--Q+R
				int3 = 7
				elseif (ts.target.health < (Qdmgi + AAdmg + DFGdmg + Rdmgi) and Q ~= 0 and R ~= 0 and DFGI ~= 0) then																								--DFG Q+R
				int3 = 8
				elseif (ts.target.health < (Qdmg + IGNITEdmg + AAdmg + Rdmg) and Q ~= 0 and R ~= 0 and ignitos ~= 0 ) then																							--Q+R+IGN
				int3 = 9
				elseif (ts.target.health < (Qdmgi + IGNITEdmg + AAdmg + DFGdmg + Rdmgi) and Q ~= 0 and R ~= 0 and ignitos ~= 0 and DFGI ~= 0) then																	--DFG Q+R+IGN
				int3 = 10
				elseif (ts.target.health < (Qdmg + Wdmg + Rdmg + AAdmg ) and Q ~= 0 and W ~= 0 and R ~= 0 ) then																									--Q+W+R
				int3 = 11
				elseif (ts.target.health < (Qdmgi + Wdmgi + Rdmgi + AAdmg + DFGdmg ) and Q ~= 0 and W ~= 0 and R ~= 0 and DFGI ~= 0) then																			--DFG Q+W+R
				int3 = 12
				elseif (ts.target.health < (Qdmg + Wdmg + Rdmg + IGNITEdmg + AAdmg ) and Q ~= 0 and W ~= 0 and R ~= 0 and ignitos ~= 0 ) then																		--Q+W+R+IGN
				int3 = 13
				elseif (ts.target.health < (Qdmgi + Wdmgi + Rdmgi + IGNITEdmg + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and R ~= 0 and ignitos ~= 0 and DFGI ~= 0) then												--DFG Q+W+R+IGN
				int3 = 14
				elseif (ts.target.health > (Qdmgi + Wdmgi + Rdmgi + IGNITEdmg + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and R ~= 0 and ignitos ~= 0 and DFGI ~= 0) then												--unkillable
				int3 = 15
			end
		end
end

function SmartCombo()
	if VeigarConfig.spacebarActive and ts.target ~= nil then
		Comboing = true
		if Comboing then ComboDMG() end
		if GetTickCount() - ComboTick > 1500 then
		Comboing = false
		end
		if int3 == 1 then 
		CQ()
		elseif int3 == 2 then
		CDFG()
		CQ()
		elseif int3 == 3 then
		CW(ts.target)
		CQ()
		elseif int3 == 4 then
		CDFG()
		CW(ts.target)
		CQ()
		elseif int3 == 5 then
		CW(ts.target)
		CQ()
		CIGN()
		elseif int3 == 6 then
		CDFG()
		CW(ts.target)
		CQ()
		CIGN()
		elseif int3 == 7 then
		CQ()
		CR()
		elseif int3 == 8 then
		CDFG()
		CQ()
		CR()
		elseif int3 == 9 then
		CQ()
		CR()
		CIGN()
		elseif int3 == 10 then
		CDFG()
		CQ()
		CR()
		CIGN()
		elseif int3 == 11 then
		CW(ts.target)
		CQ()
		CR()
		elseif int3 == 12 then
		CDFG()
		CW(ts.target)
		CQ()
		CR()
		elseif int3 == 13 then
		CW(ts.target)
		CQ()
		CR()
		CIGN()
		elseif int3 == 14 then
		CDFG()
		CW(ts.target)
		CQ()
		CR()
		CIGN()
		elseif int3 == 15 then
		CQ()
		end
	end
end

function Potions()
hppot = GetInventorySlotItem(2003)
mppot = GetInventorySlotItem(2004)
elixir = GetInventorySlotItem(2037)
flaskk = GetInventorySlotItem(2041)
Biscuit = GetInventorySlotItem(2010)
		if  TargetHaveBuff("SummonerDot", myHero) or TargetHaveBuff("MordekaiserChildrenOfTheGrave", myHero) and not InFountain() then
			if hppot ~= nil then
				CastSpell(hppot)
			end
			
			if flaskk ~= nil then
				CastSpell(flaskk)
			end
			
			if elixir ~= nil then
				CastSpell(elixir)
			end
		end
	
	if not TargetHaveBuff("Recall", myHero) and not TargetHaveBuff("SummonerTeleport", myHero) and not TargetHaveBuff("RecallImproved", myHero) and not InFountain() then
		if VeigarConfig.AP.hp and hppot ~= nil then
			if ((myHero.health/myHero.maxHealth)*100) < VeigarConfig.AP.hp and not TargetHaveBuff("RegenerationPotion", myHero) then
				CastSpell(hppot)
			end
		end
		
		if VeigarConfig.AP.hp and Biscuit ~= nil then
			if ((myHero.health/myHero.maxHealth)*100) < VeigarConfig.AP.hp and not TargetHaveBuff("ItemMiniRegenPotion", myHero) then
				CastSpell(Biscuit)
			end
		end
		
		if VeigarConfig.AP.mp and mppot ~= nil then 
			if ((myHero.mana/myHero.maxMana)*100) < VeigarConfig.AP.mp and not TargetHaveBuff("FlaskOfCrystalWater", myHero) then
				CastSpell(mppot)
			end
		end
		
		if VeigarConfig.AP.flask and flaskk ~= nil and VeigarConfig.AP.flask then
			if ((myHero.health/myHero.maxHealth)*100) < VeigarConfig.AP.hp and not TargetHaveBuff("ItemCrystalFlask", myHero) then
				CastSpell(flaskk)
			end
		end
		
		if VeigarConfig.AP.elixir and elixir ~= nil then
			if ((myHero.health/myHero.maxHealth)*100) < VeigarConfig.AP.elixir then
				CastSpell(elixir)
			end
		end
	end
end


