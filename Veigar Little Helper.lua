if myHero.charName ~= "Veigar" then return end
PrintChat (" >> LOOOOOL")
local version = 1.3
local AUTOUPDATE = true
local SCRIPT_NAME = "Veigar Little Helper"

local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"

if FileExist(SOURCELIB_PATH) then
	require("SourceLib")
else
	DOWNLOADING_SOURCELIB = true
	DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() PrintChat("Required libraries downloaded successfully, please reload") end)
end

if DOWNLOADING_SOURCELIB then PrintChat("Downloading required libraries, please wait...") return end

if AUTOUPDATE then
	SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/DedToto/Veigar-Little-Helper/master/Veigar Little Helper.lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/DedToto/Veigar-Little-Helper/master/"..SCRIPT_NAME..".version"):CheckUpdate()
end

--Welcome to my Little Veigar Helper! I'd made it for those who only want calculations and misc to be done for them. Also this is my first script.


--[GLOBALS]
local DFG = GetInventorySlotItem(3128)
local ignite = nil
local qRange = 650
local lastFarmCheck = 0
local farmCheckTick = 100
local rofl = 0

--[KEYS]
local autoFarmKey = string.byte("J")
local ExtraInfoKey = string.byte("Z")
local AutoBuy = string.byte("P")
local MainCalcKey = string.byte("X")

--[SKILLS]
local Q = 0
local W = 0
local R = 0
local ignitos = 0
local DFGI = 0

--[SKILL LVL]
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

function OnLoad()
	PrintChat("<font color=\"#ffffff\">You are using Veigar Little Helper ["..version.."] by DedToto.</font>")
	createMenu()
	player = GetMyHero()

	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
        ignite = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
        ignite = SUMMONER_2
    end

end


function OnTick()

	ExtraExtraInfo()
	
	--[DFG AVAILABILITY CHECK]
	if GetInventorySlotItem(3128) ~= nil then 
		if myHero:CanUseSpell(DFG) == READY then
			DFGI = 1
		else
			DFGI = 0
		end
	end
	
	--[SKILL MANACOSTS]
	Qlevel = myHero:GetSpellData(_Q).level
	Wlevel = myHero:GetSpellData(_W).level
	Elevel = myHero:GetSpellData(_E).level
	Rlevel = myHero:GetSpellData(_R).level
	
	--AutoFarm
	if VeigarConfig.farm.autoFarm then autoFarm() end

	--AutoBuy 
	if VeigarConfig.AutoBuy and rofl ~= 1 then
		--You can change these items but don't touch rofl.
		BuyItem(1004)
		BuyItem(2003)
		BuyItem(2003)
		BuyItem(2003)
		BuyItem(2003)
		BuyItem(2003)
		BuyItem(2004)
		BuyItem(2004)
		BuyItem(2004)
		rofl = 1
	end
	
end

function createMenu()

	VeigarConfig = scriptConfig("Little Veigar Helper", "littlehelper")
	VeigarConfig:addSubMenu("Drawing","draw")
		VeigarConfig.draw:addParam("Erange", "Draw E range", SCRIPT_PARAM_ONOFF, true)
		VeigarConfig.draw:addParam("ErangeMax", "Draw E rangeMax", SCRIPT_PARAM_ONOFF, false)
		VeigarConfig.draw:addParam("Wrange", "Draw W range", SCRIPT_PARAM_ONOFF, false)
	VeigarConfig:addSubMenu("AutoFarm","farm")
		VeigarConfig.farm:addParam("autoFarm", "Auto farm with Q", SCRIPT_PARAM_ONKEYTOGGLE, false, autoFarmKey)
		VeigarConfig.farm:addParam("manasavep", "Mana % to conserve", SCRIPT_PARAM_SLICE, 1, 1, 100, 0)
		VeigarConfig.farm:addParam("manasave", "Conserve mana during farm", SCRIPT_PARAM_ONOFF,false)
	VeigarConfig:addParam("doDraw", "Draw E circle", SCRIPT_PARAM_ONOFF, true)
	VeigarConfig:addParam("AutoBuy", "Buy Starting Items", SCRIPT_PARAM_ONKEYDOWN, false, AutoBuy)
	VeigarConfig:addParam("ShowMana", "Show Time For Mana Regen", SCRIPT_PARAM_ONOFF, true)
	VeigarConfig:addParam("Death", "Show Info After Death", SCRIPT_PARAM_ONOFF, false)
	VeigarConfig:addParam("ExtraInfo", "Show Best Killing Combo", SCRIPT_PARAM_ONKEYTOGGLE, true, ExtraInfoKey)
	VeigarConfig:addParam("MainCalc", "Show Main Calculations", SCRIPT_PARAM_ONKEYTOGGLE, true, MainCalcKey)
	VeigarConfig.farm:permaShow("autoFarm")
	VeigarConfig:permaShow("ExtraInfo")
	
end

function OnDraw()

	DamageCalculator()
	ExtraInformation()
	
	--[DRAW RANGES]
	if not myHero.dead or VeigarConfig.Death then
		if VeigarConfig.draw.Erange then
			DrawCircle(myHero.x, myHero.y, myHero.z, 650, 0xFFFF00)
		end
			
		if VeigarConfig.draw.ErangeMax then
			DrawCircle(myHero.x, myHero.y, myHero.z, 1000, 0xFFFF00)
		end
			
		if VeigarConfig.draw.Wrange then
			DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0xFFFF00)
		end
	end
	
	--[MANA REGEN FOR COMBO]
	if VeigarConfig.ShowMana then
		if not myHero.dead or VeigarConfig.Death then
			if myHero.mana < ComboManaCost({_Q, _W, _E, _R}) then
				DrawNoMana()
			end
		end
	end
	
end

function DamageCalculator()
	
	if VeigarConfig.MainCalc then
		if not myHero.dead or VeigarConfig.Death then
			for i, enemy in ipairs(GetEnemyHeroes()) do
				if ValidTarget(enemy) then
				local Qdmg = getDmg("Q", enemy, myHero)
				local Wdmg = getDmg("W", enemy, myHero)
				local Rdmg = getDmg("R", enemy, myHero)
				local AAdmg = (getDmg("AD", enemy, myHero))
				local DFGdmg = (GetInventorySlotItem(3128) and getDmg("DFG", enemy ,myHero) or 0)
				local IGNITEdmg = 50 + 20 * myHero.level
				local DMG = 0 + AAdmg
				
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
					DrawText3D(tostring(math.floor((DMG - enemy.health)+0.5)), enemy.x, enemy.y, enemy.z, 25, RGB(255, 0, 0), true)
					else
					DrawText3D(tostring(math.floor((enemy.health - DMG)+0.5)), enemy.x, enemy.y, enemy.z, 25, RGB(255, 255, 255), true)
					
					end
				end
			end
		end
	end
end

function ExtraInformation()

	if VeigarConfig.ExtraInfo then
		if not myHero.dead or VeigarConfig.Death then
			for i, enemy in ipairs(GetEnemyHeroes()) do
				if ValidTarget(enemy) then
				
					local Qdmg = getDmg("Q", enemy, myHero)
					local Wdmg = getDmg("W", enemy, myHero)
					local Rdmg = getDmg("R", enemy, myHero)
					local AAdmg = (getDmg("AD", enemy, myHero))
					local IGNITEdmg = 50 + 20 * myHero.level
					local DFGdmg = (GetInventorySlotItem(3128) and getDmg("DFG", enemy ,myHero) or 0)
					local DMG = 0 + AAdmg
					local Qdmgi = Qdmg * 1.2
					local Wdmgi = Wdmg * 1.2
					local Rdmgi = Rdmg * 1.2
					IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
					
				
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
end

function autoFarm()
	local usedQ = false
	if VeigarConfig.farm.autoFarm and GetTickCount() > lastFarmCheck + farmCheckTick then
		if (VeigarConfig.farm.manasave and manaPct() > VeigarConfig.farm.manasavep) or not VeigarConfig.farm.manasave then
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

--[MISC FOR EXTRA]
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

--[MISC FOR MANA REGEN]
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

--[MISC FOR MANA REGEN]
function ComboManaCost(Combo)
	local Result = 0	
	for i, spell in ipairs(Combo) do
		Result = Result + ManaCost(spell)
	end
	return Result
end

--[MISC FOR MANA REGEN]
function DrawNoMana()
	timetoregen = (ComboManaCost({_Q, _W, _E, _R}) - myHero.mana) / myHero.mpRegen
	DrawText3D("No Mana ("..math.floor(timetoregen).."s) !!", myHero.x, myHero.y, myHero.z, 25, RGB(30, 83, 231), true)
end

function manaPct()
  return math.round((myHero.mana / myHero.maxMana)*100)
end
