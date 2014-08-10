if myHero.charName ~= "Veigar" then return end
local version = 1.3
--[GLOBALS]
local DFG = GetInventorySlotItem(3128)
local ignite = nil
local qRange = 650
local lastFarmCheck = 0
local farmCheckTick = 100
local int1 = 0
local int2 = 0

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

--[MANACOSTS]
local QMana = {60, 65, 70, 75, 80}
local WMana = {70, 80, 90, 100, 110}
local EMana = { 80, 90, 100, 110, 120}
local RMana = {125, 175, 225}
local ComboMana = GetSpellData(_Q).mana + GetSpellData(_W).mana + GetSpellData(_E).mana + GetSpellData(_R).mana

--[LAG FREE INFO]
 local eCircleColor = ARGB(255,255,0,255)--0xB820C3 -- purple by default
 local wCircleColor = ARGB(255,255,0,0)--0xEA3737 -- orange by default
 local qCircleColor = ARGB(255,0,255,0)--0x19A712 --green by default

function OnTick()
	AutoBuyy()
	autoFarm()
	ManaCosts()
	AutoWharrasQ()
	ExtraExtraInfo()
	DFGcheck()
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
		
	VeigarConfig:addSubMenu("Other","other")
		VeigarConfig.other:addParam("autoW", "Auto W Stunned Enemies", SCRIPT_PARAM_ONKEYTOGGLE, false, AutoWKey)
		VeigarConfig.other:addParam("AutoBuy", "Buy Starting Items", SCRIPT_PARAM_ONKEYDOWN, false, AutoBuy)
		VeigarConfig.other:addParam("ShowMana", "Show Time For Mana Regen", SCRIPT_PARAM_ONOFF, true)
		VeigarConfig.other:addParam("Death", "Show Info After Death", SCRIPT_PARAM_ONOFF, false)
		VeigarConfig.other:addParam("ExtraInfo", "Show Best Killing Combo", SCRIPT_PARAM_ONKEYTOGGLE, true, ExtraInfoKey)
		VeigarConfig.other:addParam("MainCalc", "Show Main Calculations", SCRIPT_PARAM_ONKEYTOGGLE, true, MainCalcKey)
		
	VeigarConfig.other:permaShow("autoW")
	VeigarConfig.farm:permaShow("autoFarm")
	VeigarConfig.other:permaShow("ExtraInfo")
	
	VP = VPrediction(true)
	NSOW = SOW(VP)
	
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
					elseif (enemy.health < (Qdmgi + AAdmg + DFGdmg) and Q ~= 0 and DFGI ~= 0) then																													--DFG Q
					DrawText3D(("|DFG|Q"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Qdmg + Wdmg + AAdmg) and Q ~= 0 and W ~= 0 ) then 																														--Q+W
					DrawText3D(("Q+W"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Qdmgi + Wdmgi + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and DFGI ~= 0) then 																								--DFG Q+W
					DrawText3D(("|DFG|Q+W"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Qdmg + Wdmg + IGNITEdmg + AAdmg) and Q ~= 0 and W ~= 0 and ignitos ~= 0 ) then																							--Q+W+IGN
					DrawText3D(("Q+W+IGN"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Qdmgi + Wdmgi + IGNITEdmg + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and ignitos ~= 0 and DFGI ~= 0) then																	--DFG Q+W+IGN
					DrawText3D(("|DFG|Q+W+IGN"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Qdmg + AAdmg + Rdmg) and Q ~= 0 and R ~= 0 ) then																														--Q+R
					DrawText3D(("Q+R"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Qdmgi + AAdmg + DFGdmg + Rdmgi) and Q ~= 0 and R ~= 0 and DFGI ~= 0) then																								--DFG Q+R
					DrawText3D(("|DFG|Q+R"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Qdmg + IGNITEdmg + AAdmg + Rdmg) and Q ~= 0 and R ~= 0 and ignitos ~= 0 ) then																							--Q+R+IGN
					DrawText3D(("Q+R+IGN"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Qdmgi + IGNITEdmg + AAdmg + DFGdmg + Rdmgi) and Q ~= 0 and R ~= 0 and ignitos ~= 0 and DFGI ~= 0) then																	--DFG Q+R+IGN
					DrawText3D(("|DFG|Q+R+IGN"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Qdmg + Wdmg + Rdmg + AAdmg ) and Q ~= 0 and W ~= 0 and R ~= 0 ) then																									--Q+W+R
					DrawText3D(("Q+W+R"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Qdmgi + Wdmgi + Rdmgi + AAdmg + DFGdmg ) and Q ~= 0 and W ~= 0 and R ~= 0 and DFGI ~= 0) then																			--DFG Q+W+R
					DrawText3D(("|DFG|Q+W+R"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Qdmg + Wdmg + Rdmg + IGNITEdmg + AAdmg ) and Q ~= 0 and W ~= 0 and R ~= 0 and ignitos ~= 0 ) then																		--Q+W+R+IGN
					DrawText3D(("Q+W+R+IGN"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Qdmgi + Wdmgi + Rdmgi + IGNITEdmg + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and R ~= 0 and ignitos ~= 0 and DFGI ~= 0) then												--DFG Q+W+R+IGN
					DrawText3D(("|DFG|Q+W+R+IGN"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
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
