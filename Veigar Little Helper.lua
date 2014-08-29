if myHero.charName ~= "Veigar" then return end
local version = 2.1
--[GLOBALS]--
local DFG = GetInventorySlotItem(3128)
local ignite = nil
local qRange = 650
local lastFarmCheck = 0
local farmCheckTick = 100
local int1 = 0
local int2 = 0
local int3 = 0
local int4 = 0
local int5 = 0
local eTarget = nil
local CT = 1000
local Comboing = false
local ComboTick = 0
local znaReady = 0
local wgtReady = 0
local expos

--[KEYS]--
local autoFarmKey = string.byte("J")
local AutoBuy = string.byte("P")

--[SKILL INFO]--
local Q = 0
local W = 0
local E = 0
local R = 0
local ignitos = 0
local DFGI = 0

--[SKILL LVLS]--
local Qlevel = 0
local Wlevel = 0
local Elevel = 0
local Rlevel = 0

--[Skill attributes]--
local qrange = 650
local ignrange = 600
local wcastspeed = 1.25 
local wrange = 900
local wradius = 230 
local eradius = 330 
local erange = 600
local ecastspeed = 0.34 
local aarange = 525
local xprange = 1400
local eradius = 330 
local erange = 600
local wRange = 900
local Edelay = 0.2
local Ewidth = 10
local Wdelay = 1.25

--[MANACOSTS]--
local QMana = {60, 65, 70, 75, 80}
local WMana = {70, 80, 90, 100, 110}
local EMana = { 80, 90, 100, 110, 120}
local RMana = {125, 175, 225}
local ComboMana = GetSpellData(_Q).mana + GetSpellData(_W).mana + GetSpellData(_E).mana + GetSpellData(_R).mana

--[AUTO POTIONS]--
local hppot = 0
local mppot = 0
local elixir = 0
local flaskk = 0
local Biscuit = 0

local hppot = GetInventorySlotItem(2003)
local mppot = GetInventorySlotItem(2004)
local elixir = GetInventorySlotItem(2037)
local flaskk = GetInventorySlotItem(2041)
local Biscuit = GetInventorySlotItem(2010)
local zhonya = GetInventorySlotItem(3157)
local wooglet = GetInventorySlotItem(3090)

--[AUTOLEVEL]--
local abilitySequence
local qOff, wOff, eOff, rOff = 0,0,0,0

--[LAG FREE INFO]--
 local eCircleColor = ARGB(255,255,0,255)--0xB820C3 -- purple by default
 local wCircleColor = ARGB(255,255,0,0)--0xEA3737 -- orange by default
 local qCircleColor = ARGB(255,0,255,0)--0x19A712 --green by default
 
 --[V2 STUN]--
local cageSpellRange = 650
local cageItselfRange = 375
local cageDiff = 50
local cageRange = cageSpellRange + (cageItselfRange/2) - cageDiff -- spell range + range of cage

--[Interuptions]--
    local LastCastedSpell = {}
  --[[  local spells =
    {
        {name = "CaitlynAceintheHole", menuname = "Caitlyn (R)"},
        {name = "AhriTumble", menuname = "Ahri (R)"},
        {name = "DariusExecute", menuname = "Darius (R)"},
        {name = "Crowstorm", menuname = "Fiddlesticks (R)"},
        {name = "DrainChannel", menuname = "Fiddlesticks (W)"},
        {name = "GalioIdolOfDurand", menuname = "Galio (R)"},
        {name = "KatarinaR", menuname = "Katarina (R)"},
        {name = "InfiniteDuress", menuname = "WarWick (R)"},
        {name = "AbsoluteZero", menuname = "Nunu (R)"},
        {name = "MissFortuneBulletTime", menuname = "Miss Fortune (R)"},
        {name = "FallenOne", menuname = "Karthus (R)"},
        {name = "LucianR", menuname = "Lucian (R)"},
        {name = "SoulShackles", menuname = "Morgana (R)"},
        {name = "UndyingRage", menuname = "Tryndamere (R)"},
        {name = "GrandSkyfall", menuname = "Pantheon (R)"},
        {name = "AlZaharNetherGrasp", menuname = "Malzahar (R)"},    
        {name = "VolibearQ", menuname = "Volibear (Q)"},
        {name = "InfiniteDuress", menuname = "Warwick (R)"},
        {name = "MonkeyKingSpinToWin", menuname = "Wukong (R)"},
        {name = "XerathLocusOfPower2", menuname = "Xerath (R)"},
        {name = "ZacR", menuname = "Zac (R)"},
    }
	]]
--local InterruptList = {"CaitlynAceintheHole", "Crowstorm", "DrainChannel", "GalioIdolOfDurand", "KatarinaR", "InfiniteDuress", "AbsoluteZero", "MissFortuneBulletTime", "AlZaharNetherGrasp", "DariusExecute", "AhriTumble", "FallenOne", "LucianR", "SoulShackles", "UndyingRage", "GrandSkyfall", "VolibearQ", "MonkeyKingSpinToWin", "XerathLocusOfPower2", "ZacR"}
--[MAIN PART]
function OnLoad()
	player = myHero
	PrintChat("<font color=\"#ffffff\">You are using Veigar Little Helper ["..version.."] by DedToto.</font>")
	enemyMinions = minionManager(MINION_ENEMY, qrange, myHero, MINION_SORT_HEALTH_ASC)
	player = GetMyHero()
	UpdateCheck()
	IgniteSlot()
	spaceHK = 32
	
	VeigarConfig = scriptConfig("Little Veigar Helper", "littlehelper")
	
	VeigarConfig:addSubMenu("Combo","combo")
			VeigarConfig.combo:addSubMenu("Auto R/Q/IGN Killable","autokillf")
			VeigarConfig.combo.autokillf:addParam("autokill", "Auto ULT/Q/IGN killable", SCRIPT_PARAM_ONOFF, true)
			VeigarConfig.combo.autokillf:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, false)
			VeigarConfig.combo.autokillf:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
			VeigarConfig.combo.autokillf:addParam("usedfg", "Use DFG", SCRIPT_PARAM_ONOFF, false)
			VeigarConfig.combo.autokillf:addParam("useign", "Use IGN", SCRIPT_PARAM_ONOFF, false)
			VeigarConfig.combo.autokillf:addParam("saveab", "Don't waste spells if OverDmg is > than", SCRIPT_PARAM_ONOFF, false)
			VeigarConfig.combo.autokillf:addParam("saveabsl", "OverDamage config ", SCRIPT_PARAM_SLICE, 1, 1, 1000, 0)
		VeigarConfig.combo:addParam("table","------------------Settings--------------",SCRIPT_PARAM_INFO,"")	
			if VIP_USER then VeigarConfig.combo:addParam("packet", "Use Packets to Cast Skills", SCRIPT_PARAM_ONOFF, false) end
			VeigarConfig.combo:addParam("savedfg", "Only use DFG in biggest combos", SCRIPT_PARAM_ONOFF, false)
			VeigarConfig.combo:addParam("ShowMana", "Show Time for full combo mana regen", SCRIPT_PARAM_ONOFF, true)
			VeigarConfig.combo:addParam("ShowCombo", "Show current spacebar combo(target)", SCRIPT_PARAM_ONOFF, false)
			VeigarConfig.combo:addParam("tryq", "Always try to lasthit enemy with Q", SCRIPT_PARAM_ONOFF, false)
			VeigarConfig.combo:addParam("forceaa", "AA after combo(RECOMMENDED)", SCRIPT_PARAM_ONOFF, true)	
		VeigarConfig.combo:addParam("table","------------------Combos--------------",SCRIPT_PARAM_INFO,"")
			VeigarConfig.combo:addParam("lightcombo", "Light Combo E+W+Q", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
			VeigarConfig.combo:addParam("wasteall", "Cast everything in target", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
			VeigarConfig.combo:addParam("spacebarActive", "SpaceToWin(SmartCombo)", SCRIPT_PARAM_ONKEYDOWN, false, spaceHK)
	
	VeigarConfig:addSubMenu("E and W","ew")
			VeigarConfig.ew:addParam("stunv", "Select E logic", SCRIPT_PARAM_LIST, 1, { "Standart", "Alternative","Alternative 2"})
			VeigarConfig.ew:addParam("eCastActive", "Use E+W", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("E"))
			VeigarConfig.ew:addParam("cageTeamActive", "Cage Team", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
			VeigarConfig.ew:addParam("addq", "use Q in E+W Combo", SCRIPT_PARAM_ONOFF, false)
			VeigarConfig.ew:addParam("forcestun", "Always cast E(even for Q+R kill)", SCRIPT_PARAM_ONOFF, false)
			VeigarConfig.ew:addParam("stuntt", "Stun Enemies attacked by turret", SCRIPT_PARAM_ONOFF, true)
			VeigarConfig.ew:addParam("stunall", "W on any stunned enemy", SCRIPT_PARAM_ONOFF, false)
			
	VeigarConfig:addSubMenu("Drawing","draw")
	
		VeigarConfig.draw:addParam("table","------------------MyHero Related--------------",SCRIPT_PARAM_INFO,"")
			VeigarConfig.draw:addParam("Erange", "Draw E,Q,R range", SCRIPT_PARAM_ONOFF, true)
			VeigarConfig.draw:addParam("ErangeMax", "Draw E rangeMax", SCRIPT_PARAM_ONOFF, true)
			VeigarConfig.draw:addParam("Wrange", "Draw W range", SCRIPT_PARAM_ONOFF, false)
			VeigarConfig.draw:addParam("AArange", "Draw AA range", SCRIPT_PARAM_ONOFF, false)
			VeigarConfig.draw:addParam("XPrange", "Draw XP range", SCRIPT_PARAM_ONOFF, false)
			VeigarConfig.draw:addParam("drawKillableMinions", "Draw Circle around killable minions", SCRIPT_PARAM_ONOFF, true)
			VeigarConfig.draw:addParam("LifeSaverRange", "Draw LifeSaver range", SCRIPT_PARAM_ONOFF, true)
				
		VeigarConfig.draw:addParam("table1","------------------Enemies Related-------------",SCRIPT_PARAM_INFO,"")
		
			VeigarConfig.draw:addParam("targg", "Mark Target with circle", SCRIPT_PARAM_ONOFF, true)
			VeigarConfig.draw:addParam("targ", "Draw line to Target(for team fights)", SCRIPT_PARAM_ONOFF, false)
			VeigarConfig.draw:addParam("ExtraInfo", "Draw best combo for kill", SCRIPT_PARAM_ONOFF, true)
			VeigarConfig.draw:addParam("MainCalc", "Draw Extra/Needed damage", SCRIPT_PARAM_ONOFF, true)
	
	VeigarConfig.draw:addParam("drawLagFree","Lag free circles", SCRIPT_PARAM_ONOFF, true)
	VeigarConfig.draw:addParam("chordLength","Lag Free Chord Length", SCRIPT_PARAM_SLICE, 75, 75, 2000, 0)
	
	VeigarConfig:addSubMenu("AutoFarm","farm")
		VeigarConfig.farm:addParam("autoFarm", "Auto farm with Q", SCRIPT_PARAM_ONKEYTOGGLE, false, autoFarmKey)
		VeigarConfig.farm:addParam("EnabledW", "Auto farm with W", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("K"))
		VeigarConfig.farm:addParam("manasavep", "Mana % to conserve", SCRIPT_PARAM_SLICE, 1, 1, 100, 0)
		VeigarConfig.farm:addParam("manasave", "Conserve mana during farm", SCRIPT_PARAM_ONOFF,false)
		VeigarConfig.farm:addParam("SaveE", "Dont farm if Mana < EManaCost",  SCRIPT_PARAM_ONOFF, false)
		VeigarConfig.farm:addParam("orbw", "Move To Mouse when farming",  SCRIPT_PARAM_ONOFF, false)
		VeigarConfig.farm:addParam("farmm", "Select Q farming way preference", SCRIPT_PARAM_LIST, 1, { "Turn ON/OFF", "Hold and farm"})
		VeigarConfig.farm:addParam("farmmm", "Select W farming way preference", SCRIPT_PARAM_LIST, 2, { "Turn ON/OFF", "Hold and farm"})
		
	VeigarConfig:addSubMenu("Harras","harras")
		VeigarConfig.harras:addParam("Qharras", "Harras enemy in range with Q", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
		VeigarConfig.harras:addParam("manasaveQP", "Mana % to conserve", SCRIPT_PARAM_SLICE, 1, 1, 100, 0)
		VeigarConfig.harras:addParam("moveto", "MoveToMouse when harrasing", SCRIPT_PARAM_ONOFF,false)
		VeigarConfig.harras:addParam("manasaveQ", "Conserve mana during harras", SCRIPT_PARAM_ONOFF,false)

	VeigarConfig:addSubMenu("Auto Potions","AP")
		VeigarConfig.AP:addParam("pots", "Use autopotions", SCRIPT_PARAM_ONOFF, false)
		VeigarConfig.AP:addParam("hp", "Use potions when HP < %", SCRIPT_PARAM_SLICE, 60, 1, 100, 0)
		VeigarConfig.AP:addParam("mp", "Use potions when Mana < %", SCRIPT_PARAM_SLICE, 15, 1, 100, 0)
		VeigarConfig.AP:addParam("elixir", "Auto Elixir of Fortitude when  < %", SCRIPT_PARAM_SLICE, 0, 1, 100, 0)		
	
	VeigarConfig:addSubMenu("Life Saver","LifeSaver")
		VeigarConfig.LifeSaver:addParam("LifeSaver", "Stun enemies Who come too close", SCRIPT_PARAM_ONOFF, false)
		VeigarConfig.LifeSaver:addParam("LifeSaverRange","Range of LifeSaver", SCRIPT_PARAM_SLICE, 400, 1, 800, 0)
		VeigarConfig.LifeSaver:addParam("usew", "Use W on emeies caught in LifeSaver", SCRIPT_PARAM_ONOFF, false)
		VeigarConfig.LifeSaver:addParam("zwsave", "Auto activate Zhonyas/Wooglets", SCRIPT_PARAM_ONOFF, false)
		VeigarConfig.LifeSaver:addParam("zwhealth", "Min Health % for Zhonyas/Wooglets", SCRIPT_PARAM_SLICE, 15, 0, 100, -1)
		VeigarConfig.LifeSaver:addParam("antign", "Auto Pots when ignited/morde R", SCRIPT_PARAM_ONOFF, true)
	
	VeigarConfig:addSubMenu("Other","other")
		VeigarConfig.other:addParam("AutoBuy", "Buy Starting Items", SCRIPT_PARAM_ONKEYDOWN, false, AutoBuy)
		VeigarConfig.other:addParam("Autolvl", "Auto level up skills", SCRIPT_PARAM_ONOFF, false)
		VeigarConfig.other:addParam("lvlup", "Select skill sequence", SCRIPT_PARAM_LIST, 1, { "Q>W>E", "W>Q>E", "W>E>Q" })
		VeigarConfig.other:addParam("autoW", "Auto W Stunned Enemies", SCRIPT_PARAM_ONOFF, false)
		VeigarConfig.other:addParam("Death", "Show Info After Death", SCRIPT_PARAM_ONOFF, false)
	
	VeigarConfig:addParam("info",">> Version "..version.."",SCRIPT_PARAM_INFO,"")
	
	VeigarConfig.combo:permaShow("spacebarActive")
	VeigarConfig.combo:permaShow("wasteall")
	VeigarConfig.combo:permaShow("lightcombo")
	VeigarConfig.farm:permaShow("autoFarm")
	
	VP = VPrediction(true)
	NSOW = SOW(VP)
	ts = TargetSelector(TARGET_LOW_HP, erange + eradius, DAMAGE_MAGIC)
	ts.name = "Veigar"
	EnemyMinions = minionManager(MINION_ENEMY, qrange, myHero, MINION_SORT_HEALTH_ASC)
	EnemyMinions2 = minionManager(MINION_ENEMY, wrange, myHero, MINION_SORT_HEALTH_ASC)
	VeigarConfig:addTS(ts)
	VeigarConfig:addSubMenu("["..myHero.charName.." - OrbWalking]", "OrbWalking")
		NSOW:LoadToMenu(VeigarConfig.OrbWalking)
	
end

function OnTick()
	Checks()
	AutoBuyy()
	autoFarm()
	ManaCosts()
	AutoWharrasQ()
	EWandCage()
	Potions()
	AutoLevel()
	LifeSaver()
	CheckStunnedTargets()
	--interrupt()
end

function OnDraw()
	ManaRegenSec()
	if not myHero.dead or VeigarConfig.other.Death then
		DamageCalculator()
		ExtraInformation()
		Drawing()
	end
end

--[END OF THE MAIN PART]

function OnProcessSpell(object, spellProc)
	targt = spellProc.target
	if object.type == "obj_AI_Turret" and GetDistance(player, targt) < (erange + eradius) then
		if targt.type == myHero.type and VeigarConfig.ew.stuntt then
		useStun(targt)
		end
	end
end
--[[
local LastTick = 0
local TickLimit = 10
]]
function CheckStunnedTargets()
	--if (os.clock() - LastTick) > 1/TickLimit then
		for i, enemy in ipairs(GetEnemyHeroes())  do
			--[[
			local Position, HitChance = VP:GetPredictedPos(enemy, Edelay)
			if HitChance >= 3 then
				ProdictionECallback(enemy, enemy, _E)
			end
			]]
			--Position, HitChance = VP:GetPredictedPos(enemy, Wdelay)
			if enemy.canMove ~= true then
				if VeigarConfig.ew.stunall then
					if VeigarConfig.combo.lightcombo or VeigarConfig.combo.wasteall or VeigarConfig.combo.spacebarActive or VeigarConfig.ew.cageTeamActive or VeigarConfig.ew.eCastActive then
						if ts.target ~= nil and enemy.name == ts.target.name then
							ProdictionWCallback(enemy, enemy, _W)
						end
						
						else
						ProdictionWCallback(enemy, enemy, _W)
					end
					else
					if VeigarConfig.combo.lightcombo or VeigarConfig.combo.wasteall or VeigarConfig.combo.spacebarActive or VeigarConfig.ew.cageTeamActive or VeigarConfig.LifeSaver.usew or VeigarConfig.ew.eCastActive then
						if ts.target ~= nil and enemy.name == ts.target.name then
							ProdictionWCallback(enemy, enemy, _W)
						end
					end
				end
			end
		end
	--end
end

function performLightCombo()
		targ = ts.target
		UseSpell(_E, targ)
		UseSpell(_Q, targ)
		int4 = 0
end

function aa()
	if VeigarConfig.autoattack and ValidTarget(ts.target) and GetDistance(ts.target) <= aarange then
		myHero:Attack(ts.target)
	end
end

function interrupt()
    if myHero:CanUseSpell(_E) == READY then
        for i, spell in ipairs(spells) do
            if VeigarConfig.AutoInterrupt[spell.name] then
                for j, LastCast in pairs(LastCastedSpell) do
                    if LastCast.name == spell.name:lower() and (os.clock() - LastCast.time) < 3 and GetDistance(LastCast.caster.visionPos, myHero.visionPos) < erange + 330 and ValidTarget(LastCast.caster) then
                         UseSpell(_E,LastCast.caster)
                        break
                    end
                end
            end
        end
    end
end

function DamageCalculator()
	
	if VeigarConfig.draw.MainCalc then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) then
			local Qdmg = getDmg("Q", enemy, myHero)
			local Wdmg = getDmg("W", enemy, myHero)
			local Rdmg = getDmg("R", enemy, myHero)
			local AAdmg = (getDmg("AD", enemy, myHero))
			local DFGdmg = 0
			local IGNITEdmg = 0
			local DMG = 0 + AAdmg
			if ignitos ~= 0 then IGNITEdmg = 50 + 20 * myHero.level end
			if DFGI ~= 0 then DFGdmg = getDmg("DFG", enemy ,myHero) end
			
			if DFGI ~= 0 then
			local DFGDMG = 0
			if CanUseSpell(_Q) == READY then DFGDMG = DFGDMG + Qdmg end
			if CanUseSpell(_W) == READY then DFGDMG = DFGDMG + Wdmg end
			if CanUseSpell(_R) == READY then DFGDMG = DFGDMG + Rdmg end
			DFGDMG = DFGDMG * 1.2
			DMG = DMG + DFGDMG
			
			if ignitos ~= 0 then DMG = DMG + IGNITEdmg end
			DMG = DMG + DFGdmg
				
			else
			if CanUseSpell(_Q) == READY then DMG = DMG + Qdmg end
			if CanUseSpell(_W) == READY then DMG = DMG + Wdmg end
			if CanUseSpell(_R) == READY then DMG = DMG + Rdmg end
			
			if ignitos ~= 0 then DMG = DMG + IGNITEdmg end
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

	if VeigarConfig.draw.ExtraInfo then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) then
				local Qdmg = getDmg("Q", enemy, myHero)
				local Wdmg = getDmg("W", enemy, myHero)
				local Rdmg = getDmg("R", enemy, myHero)
				local AAdmg = (getDmg("AD", enemy, myHero))
				local DFGdmg = 0
				local IGNITEdmg = 0
				local DMG = 0 + AAdmg
				local Qdmgi = Qdmg * 1.2
				local Wdmgi = Wdmg * 1.2
				local Rdmgi = Rdmg * 1.2
				
				if ignitos ~= 0 then IGNITEdmg = 50 + 20 * myHero.level end
				if DFGI ~= 0 then DFGdmg = getDmg("DFG", enemy ,myHero) end
				
				if VeigarConfig.combo.autokillf.autokill and not VeigarConfig.combo.spacebaractive then
					if (enemy.health < Qdmg and Q ~= 0 and GetDistance(enemy) < qrange and VeigarConfig.combo.autokillf.useq) then
						UseSpell(_Q, enemy)
						elseif (enemy.health < IGNITEdmg and ignitos ~= 0 and GetDistance(enemy) < ignrange and VeigarConfig.combo.autokillf.useign) then
						if VeigarConfig.combo.autokillf.saveab then
							if (enemy.health - IGNITEdmg) > VeigarConfig.combo.autokillf.saveabsl then return end
						else
						UseSpell(ignite, enemy)
						end
						elseif (enemy.health < Rdmg and R ~= 0 and GetDistance(enemy) < qrange and VeigarConfig.combo.autokillf.user) then
						if VeigarConfig.combo.autokillf.saveab then
							if (enemy.health - Rdmg) > VeigarConfig.combo.autokillf.saveabsl then return end
						else
						UseSpell(_R, enemy)
						end
						elseif (enemy.health < (Qdmg + IGNITEdmg) and Q ~= 0 and ignitos ~= 0 and GetDistance(enemy) < ignrange and VeigarConfig.combo.autokillf.useign and VeigarConfig.combo.autokillf.useq) then
						if VeigarConfig.combo.autokillf.saveab then
							if (enemy.health - (Qdmg + IGNITEdmg)) > VeigarConfig.combo.autokillf.saveabsl then return end
						else
						UseSpell(ignite, enemy)
						UseSpell(_Q, enemy)
						end
						elseif (enemy.health < (Rdmg + IGNITEdmg) and R ~= 0 and ignitos ~= 0 and GetDistance(enemy) < ignrange and VeigarConfig.combo.autokillf.useign and VeigarConfig.combo.autokillf.user) then
						if VeigarConfig.combo.autokillf.saveab then
							if (enemy.health - (Rdmg + IGNITEdmg)) > VeigarConfig.combo.autokillf.saveabsl then return end
						else
						UseSpell(_R, enemy)
						UseSpell(ignite, enemy)
						end
						elseif (enemy.health < (Qdmg + Rdmg) and Q ~= 0 and R ~= 0 and GetDistance(enemy) < qrange and VeigarConfig.combo.autokillf.useq and VeigarConfig.combo.autokillf.user) then
						if VeigarConfig.combo.autokillf.saveab then
							if (enemy.health - (Rdmg + Qdmg)) > VeigarConfig.combo.autokillf.saveabsl then return end
						else
						UseSpell(_R, enemy)
						UseSpell(_Q, enemy)
						end
						elseif (enemy.health < (Qdmgi + DFGdmg) and Q ~= 0 and DFGI ~= 0 and VeigarConfig.combo.autokillf.usedfg and GetDistance(enemy) < qrange and VeigarConfig.combo.autokillf.useq) then
						if VeigarConfig.combo.autokillf.saveab then
							if (enemy.health - (DFGdmg + Qdmgi)) > VeigarConfig.combo.autokillf.saveabsl then return end
						else
						DFG = GetInventorySlotItem(3128)
						UseSpell(DFG, enemy)
						UseSpell(_Q, enemy)
						end
						elseif (enemy.health < (IGNITEdmg + DFGdmg) and ignitos ~= 0 and DFGI ~= 0 and VeigarConfig.combo.autokillf.usedfg and GetDistance(enemy) < ignrange and VeigarConfig.combo.autokillf.useign and VeigarConfig.combo.autokillf.usedfg ) then
						if VeigarConfig.combo.autokillf.saveab then
							if (enemy.health - (DFGdmg + IGNITEdmg)) > VeigarConfig.combo.autokillf.saveabsl then return end
						else
						DFG = GetInventorySlotItem(3128)
						UseSpell(DFG, enemy)
						UseSpell(ignite, enemy)
						end
						elseif (enemy.health < (Rdmgi + DFGdmg) and R ~= 0 and DFGI ~= 0 and VeigarConfig.combo.autokillf.usedfg and GetDistance(enemy) < qrange and VeigarConfig.combo.autokillf.user) then
						if VeigarConfig.combo.autokillf.saveab then
							if (enemy.health - (DFGdmg + Rdmgi)) > VeigarConfig.combo.autokillf.saveabsl then return end
						else
						DFG = GetInventorySlotItem(3128)
						UseSpell(DFG, enemy)
						UseSpell(_R, enemy)
						end
						elseif (enemy.health < (DFGdmg + Qdmgi + IGNITEdmg) and Q ~= 0 and DFGI ~= 0 and ignitos ~= 0 and VeigarConfig.combo.autokillf.usedfg and GetDistance(enemy) < ignrange and VeigarConfig.combo.autokillf.useq and VeigarConfig.combo.autokillf.useign) then
						if VeigarConfig.combo.autokillf.saveab then
							if (enemy.health - (DFGdmg + Qdmgi + IGNITEdmg)) > VeigarConfig.combo.autokillf.saveabsl then return end
						else
						DFG = GetInventorySlotItem(3128)
						UseSpell(DFG, enemy)
						UseSpell(ignite, enemy)
						UseSpell(_Q, enemy)
						end
						elseif (enemy.health < (DFGdmg + Rdmgi + IGNITEdmg) and R ~= 0 and DFGI ~= 0 and ignitos ~= 0 and VeigarConfig.combo.autokillf.usedfg and GetDistance(enemy) < ignrange and VeigarConfig.combo.autokillf.user and VeigarConfig.combo.autokillf.useign) then
						if VeigarConfig.combo.autokillf.saveab then
							if (enemy.health - (DFGdmg + Rdmgi + IGNITEdmg)) > VeigarConfig.combo.autokillf.saveabsl then return end
						else
						DFG = GetInventorySlotItem(3128)
						UseSpell(DFG, enemy)
						UseSpell(_R, enemy)
						UseSpell(ignite, enemy)
						end
						elseif (enemy.health < (Qdmgi + Rdmgi + DFGdmg) and Q ~= 0 and R ~= 0 and DFGI ~= 0 and VeigarConfig.combo.autokillf.usedfg and GetDistance(enemy) < qrange and VeigarConfig.combo.autokillf.useq and VeigarConfig.combo.autokillf.user ) then
						if VeigarConfig.combo.autokillf.saveab then
							if (enemy.health - (DFGdmg + Qdmgi + Rdmgi)) > VeigarConfig.combo.autokillf.saveabsl then return end
						else
						DFG = GetInventorySlotItem(3128)
						UseSpell(DFG, enemy)
						UseSpell(_R, enemy)
						UseSpell(_Q, enemy)
						end
						elseif (enemy.health < (Qdmgi + Rdmgi + DFGdmg + IGNITEdmg) and Q ~= 0 and R ~= 0 and DFGI ~= 0 and ignitos ~= 0 and VeigarConfig.combo.autokillf.usedfg and GetDistance(enemy) < ignrange and VeigarConfig.combo.autokillf.useq and VeigarConfig.combo.autokillf.user and VeigarConfig.combo.autokillf.useign) then
						if VeigarConfig.combo.autokillf.saveab then
							if (enemy.health - (DFGdmg + Qdmgi + Rdmgi + IGNITEdmg)) > VeigarConfig.combo.autokillf.saveabsl then return end
						else
						DFG = GetInventorySlotItem(3128)
						UseSpell(DFG, enemy)
						UseSpell(_R, enemy)
						UseSpell(ignite, enemy)
						UseSpell(_Q, enemy)
						end
					end
				end
				
				if (enemy.health < (Qdmg) and Q ~= 0 ) then																																							--Q
					DrawText3D(("Q"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true) 
					elseif (enemy.health < (Qdmg + AAdmg) and Q ~= 0 ) then																																			--Q+AA
					DrawText3D(("Q+AA"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true) 
					elseif (enemy.health < (Qdmgi + AAdmg + DFGdmg) and Q ~= 0 and DFGI ~= 0) then																													--DFG Q
					DrawText3D(("|DFG|Q"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health <= (Wdmg + AAdmg) and W ~= 0 and E ~= 0) then																																--W
					DrawText3D(("W"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health <= (Wdmg + DFGdmg + AAdmg) and W ~= 0 and E ~= 0 and DFGI ~= 0) then																										--DFG W	
					DrawText3D(("|DFG|W"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health <= (IGNITEdmg) and ignitos ~= 0) then																																		--IGN
					DrawText3D(("IGN"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Qdmg + Wdmg + AAdmg) and Q ~= 0 and W ~= 0 ) then 																														--Q+W
					DrawText3D(("Q+W"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Qdmgi + Wdmgi + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and DFGI ~= 0) then 																								--DFG Q+W
					DrawText3D(("|DFG|Q+W"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Qdmg + Wdmg + IGNITEdmg + AAdmg) and Q ~= 0 and W ~= 0 and ignitos ~= 0 ) then																							--Q+W+IGN
					DrawText3D(("Q+W+IGN"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Qdmgi + Wdmgi + IGNITEdmg + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and ignitos ~= 0 and DFGI ~= 0) then																	--DFG Q+W+IGN
					DrawText3D(("|DFG|Q+W+IGN"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
					elseif (enemy.health < (Rdmg + AAdmg) and R ~= 0) then																																			--R
					DrawText3D(("R"), enemy.x, enemy.y + 120, enemy.z, 20, RGB(255, 255, 255), true)
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
					elseif (enemy.health > (Qdmgi + Wdmgi + Rdmgi + IGNITEdmg + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and R ~= 0 and ignitos ~= 0 and DFGI ~= 0) then												--unkillable
				end
			end
		end
	end
end

function autoFarm()

	local usedQ = false
	if VeigarConfig.farm.autoFarm and GetTickCount() > lastFarmCheck + farmCheckTick then
		if not VeigarConfig.combo.spacebarActive and not VeigarConfig.ew.eCastActive and not VeigarConfig.harras.Qharras and not VeigarConfig.ew.cageTeamActive and not VeigarConfig.combo.wasteall and not VeigarConfig.combo.lightcombo then
			if (VeigarConfig.farm.manasave and manaPct() > VeigarConfig.farm.manasavep) or not VeigarConfig.farm.manasave then
				if myHero.mana > ComboManaCost({_Q, _E}) or not VeigarConfig.farm.SaveE then
				if VeigarConfig.farm.orbw then moveToMouse() end
					if CanUseSpell(_Q) then
						for k = 1, objManager.maxObjects do
							if not usedQ then
								local minion = objManager:GetObject(k)
								if minion ~= nil and minion.name:find("Minion_") and minion.team ~= myHero.team and minion.dead == false and GetDistance(minion) < qRange then
									local qDamage = getDmg("Q",minion,myHero)
									if qDamage >= minion.health then
										UseSpell(_Q, minion)
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
	
	if VeigarConfig.farm.EnabledW then
		Max = 0
		local MaxPos
		EnemyMinions2:update()
		for i, minion in pairs(EnemyMinions2.objects) do
			if (GetDistance(minion) < wrange) and (minion.charName:find("Wizard") or minion.charName:find("Caster")) then
				Count = GetNMinionsHit(minion, wradius)
				if Count > Max then
					Max = Count
					MaxPos = Vector(minion.x, 0, minion.z)
					if (Max > 4) and (myHero.mana > ComboManaCost({_Q, _E})) or not VeigarConfig.farm.SaveE and MaxPos ~= 0  then
						CastSpell(_W, MaxPos.x, MaxPos.z)
					end
				end
			end
		end
		

	end
end

function AutoWharrasQ()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		
		if ValidTarget(enemy) then
			if VeigarConfig.other.autoW and player:CanUseSpell(_W) == READY and enemy.canMove ~= true and IsGoodTarget(enemy, erange) then
				UseSpell(_W, enemy)
				return
			end
			if VeigarConfig.harras.moveto and VeigarConfig.harras.Qharras then moveToMouse() end
			if VeigarConfig.harras.Qharras and IsGoodTarget(enemy, qRange) then
				if (VeigarConfig.harras.manasaveQ and manaPct() > VeigarConfig.harras.manasaveQP) or not VeigarConfig.harras.manasaveQ then
					UseSpell(_Q, enemy) -- cast spell
					return
				end
				
			end
		end
	end
end

function EWandCage()
local players = heroManager.iCount
  if VeigarConfig.ew.eCastActive == true and not player.dead then
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
	UseSpell(_E,eTarget)
	  if VeigarConfig.ew.addq then
		UseSpell(_Q, eTarget)
	  end
    end
  end

  if VeigarConfig.ew.cageTeamActive == true and ts.target ~= nil and not player.dead then
    local spellPos = FindGroupCenterFromNearestEnemies(eradius, erange)
    if spellPos ~= nil then
      CastSpell(_E, spellPos.center.x, spellPos.center.z)
    end
  end  
end

function Drawing()
	if VeigarConfig.draw.Erange then
		CustomDrawCircle(player.x, player.y, player.z, qrange, qCircleColor)
	end
		
	if VeigarConfig.draw.ErangeMax then
		CustomDrawCircle(player.x, player.y, player.z, erange + eradius, eCircleColor)
	end
		
	if VeigarConfig.draw.Wrange then
		CustomDrawCircle(player.x, player.y, player.z, wRange, wCircleColor)
	end
	
	if VeigarConfig.draw.AArange then
		CustomDrawCircle(player.x, player.y, player.z, aarange, qCircleColor)
	end
	
	if VeigarConfig.draw.XPrange then
		CustomDrawCircle(player.x, player.y, player.z, xprange, qCircleColor)
	end
	
	if VeigarConfig.draw.LifeSaverRange and VeigarConfig.LifeSaver.LifeSaver then
		CustomDrawCircle(player.x, player.y, player.z, VeigarConfig.LifeSaver.LifeSaverRange, wCircleColor)
	end
	
	if VeigarConfig.draw.targg and ValidTarget(ts.target) then
	targ = ts.target
    DrawCircle(targ.x, targ.y, targ.z, 100, ARGB(250, 253, 33, 33))
    end
	
	if VeigarConfig.draw.targ and ValidTarget(ts.target) then    
	targ = ts.target    
		DrawLine3D(myHero.x, myHero.y, myHero.z, targ.x, targ.y, targ.z, 5, ARGB(250,235,33,33))
    end
	
	if VeigarConfig.draw.drawKillableMinions then
      enemyMinions:update()
      if enemyMinions.objects[1] then
        local targetMinion = enemyMinions.objects[1]

        if ValidTarget(targetMinion, erange+eradius) and string.find(targetMinion.name, "Minion_") then
          if targetMinion.health < player:CalcMagicDamage(targetMinion, 45 * (player:GetSpellData(_Q).level - 1) + 80 + (.6 * player.ap)) then
           DrawCircle(targetMinion.x,targetMinion.y,targetMinion.z, 75, qCircleColor)
          end
        end
      end
    end
	
	if int5 ~= 0 and ts.target ~= nil and VeigarConfig.combo.ShowCombo then
	targ = ts.target
		if int5 == 1 then
			DrawText3D(("Q"), targ.x, targ.y + 2, targ.z, 20, RGB(255, 255, 255), true) 
			elseif int5 == 2 then
			DrawText3D(("|DFG|Q"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true) 
			elseif int5 == 17 then
			DrawText3D(("W"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true) 
			elseif int5 == 18 then
			DrawText3D(("|DFG|W"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true)
			elseif int5 == 19 then
			DrawText3D(("IGN"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true) 			
			elseif int5 == 3 then
			DrawText3D(("Q+W"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true) 
			elseif int5 == 4 then
			DrawText3D(("|DFG|Q+W"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true) 
			elseif int5 == 5 then
			DrawText3D(("Q+W+IGN"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true) 
			elseif int5 == 6 then
			DrawText3D(("|DFG|Q+W+IGN"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true) 
			elseif int5 == 16 then
			DrawText3D(("R"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true) 
			elseif int5 == 7 then
			DrawText3D(("Q+R"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true) 
			elseif int5 == 8 then
			DrawText3D(("|DFG|Q+R"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true) 
			elseif int5 == 9 then
			DrawText3D(("Q+R+IGN"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true) 
			elseif int5 == 10 then
			DrawText3D(("|DFG|Q+R+IGN"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true) 
			elseif int5 == 11 then
			DrawText3D(("Q+W+R"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true) 
			elseif int5 == 12 then
			DrawText3D(("|DFG|Q+W+R"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true) 
			elseif int5 == 13 then
			DrawText3D(("Q+W+R+IGN"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true) 
			elseif int5 == 14 then
			DrawText3D(("|DFG|Q+W+R+IGN"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true) 
			elseif int5 == 15 then	
			DrawText3D(("unkillable"), targ.x, targ.y + 240, targ.z, 20, RGB(255, 255, 255), true)
		end
	end
end

function useStun(object)
  local spellPos, hitchance
  if player:CanUseSpell(_E) == READY and not object.dead then
    castESpellOnTarget(object)
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
      CastSpell(_E, CircX, CircZ)
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
--[[
function UseSpell(Spell,param1,param2)
    if param1 and param2 then
      CastSpell(Spell,param1,param2)
    elseif param1 then
      CastSpell(Spell,param1)
    else
      CastSpell(Spell)
    end
end
]]
function UseSpell(Spell,target)
	if Spell == _Q then
		if VeigarConfig.combo.packet then
			Packet("S_CAST", {spellId = Spell, targetNetworkId = target.networkID}):send()
		else
			CastSpell(Spell, target)
		end
	elseif Spell == _W then
		--Only on stunned
	
	elseif Spell == _E then
		if VeigarConfig.ew.stunv == 1 then useStun(target) elseif VeigarConfig.ew.stunv == 2 then UseStunV2() elseif VeigarConfig.ew.stunv == 3 then UseStunV3() end
	elseif Spell == _R then
		if VeigarConfig.combo.packet then
			Packet("S_CAST", {spellId = Spell, targetNetworkId = target.networkID}):send()
		else
			CastSpell(Spell, target)
		end
	elseif Spell == DFG then
		if VeigarConfig.combo.packet then
			Packet("S_CAST", {spellId = Spell, targetNetworkId = target.networkID}):send()
		else
			CastSpell(DFG, ts.target)
		end
	elseif Spell == ignite then
		if VeigarConfig.combo.packet then
			Packet("S_CAST", {spellId = Spell, targetNetworkId = target.networkID}):send()
		else
			CastSpell(Spell, target)
		end
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
		BuyItem(3340)
		int1 = 1
	end
end

function ManaRegenSec()
	if VeigarConfig.combo.ShowMana then
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

function IgniteSlot()
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then
		return SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
		return SUMMONER_2
	else
		return nil
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

function Potions()
		if VeigarConfig.LifeSaver.zwsave and myHero.health < (myHero.maxHealth * (VeigarConfig.LifeSaver.zwhealth / 100)) then
			if znaReady then
				CastSpell(zhonya)
			end
			
			if wgtReady then
				CastSpell(wooglet)
			end
		end

		if  TargetHaveBuff("SummonerDot", myHero) or TargetHaveBuff("MordekaiserChildrenOfTheGrave", myHero) and not InFountain() and VeigarConfig.LifeSaver.antign then
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
	if VeigarConfig.AP.pots then
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
		
		if VeigarConfig.AP.flask and flaskk ~= nil then
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
end

function performWasteCombo()
	targ = ts.target
	local DFG = GetInventorySlotItem(3128)
	UseSpell(_E, targ)
	if DFGI ~= 0 then UseSpell(DFG, targ) end
	if VeigarConfig.combo.tryq then
	if R ~= 0 then UseSpell(_R, targ) end
	if ignitos ~= 0 then UseSpell(ignite, targ) end
	if Q ~= 0 then UseSpell(_Q, targ) end
	else
	if Q ~= 0 then UseSpell(_Q, targ) end
	if R ~= 0 then UseSpell(_R, targ) end
	if ignitos ~= 0 then UseSpell(ignite, targ) end
	end
	int4 = 0
end

function performSmartCombo()
	
	targ = ts.target
	combo = dmgCalc(targ, false)
	if aLock[targ.name] == 0 or aTime[targ.name] == nil then
		aLock[targ.name] = 1
		aTime[targ.name] = GetTickCount()
	end
	if combo == 1 then
	int4 = 1
		performcombo1()
	elseif combo == 2 then
	int4 = 1
		performcombo2()
	elseif combo == 17 then
	int4 = 1
		performcombo17()
	elseif combo == 18 then
	int4 = 1
		performcombo18()
	elseif combo == 19 then
	int4 = 1
		performcombo19()
	elseif combo == 3 then
	int4 = 1
		performcombo3()
	elseif combo == 4 then
	int4 = 1
		performcombo4()
	elseif combo == 5 then
	int4 = 1
		performcombo5()
	elseif combo == 6 then
	int4 = 1
		performcombo6()
	elseif combo == 16 then
	int4 = 1
		performcombo16()
	elseif combo == 7 then
	int4 = 1
		performcombo7()
	elseif combo == 8 then
	int4 = 1
		performcombo8()
	elseif combo == 9 then
	int4 = 1
		performcombo9()
	elseif combo == 10 then
	int4 = 1
		performcombo10()
	elseif combo == 11 then
	int4 = 1
		performcombo11()
	elseif combo == 12 then
	int4 = 1
		performcombo12()
	elseif combo == 13 then
	int4 = 1
		performcombo13()
	elseif combo == 14 then
	int4 = 1
		performcombo14()
	elseif combo == 15 then
	int4 = 1
		performcombo15()		
	end
end

aCombo = {}
aTime = {}
aLock = {}
function dmgCalc(drawtarget)
	if drawtarget ~= nil and drawtarget.team ~= player.team and drawtarget.visible and not drawtarget.dead then
		if aTime[drawtarget.name]~= nil and GetTickCount() - aTime[drawtarget.name] < 2000 then
			return aCombo[drawtarget.name]
		end
		aLock[drawtarget.name] = 0
		local Qdmg = getDmg("Q", drawtarget, myHero)
		local Wdmg = getDmg("W", drawtarget, myHero)
		local Rdmg = getDmg("R", drawtarget, myHero)
		local AAdmg = (getDmg("AD", drawtarget, myHero))
		local DFGdmg = 0
		local IGNITEdmg = 50 + 20 * myHero.level
		local DMG = 0 + AAdmg
		local Qdmgi = Qdmg * 1.2
		local Wdmgi = Wdmg * 1.2
		local Rdmgi = Rdmg * 1.2
		if DFGI ~= 0 then DFGdmg = getDmg("DFG", drawtarget,myHero) end
		
				if VeigarConfig.combo.savedfg then
					if (drawtarget.health <= (Qdmg + AAdmg) and Q ~= 0 ) then																																				--Q
						aCombo[drawtarget.name] = 1
						return 1
						--elseif (drawtarget.health <= (Qdmgi + AAdmg + DFGdmg) and Q ~= 0 and DFGI ~= 0) then																												--DFG Q
						--aCombo[drawtarget.name] = 2
						--return 2
						--int5 = 1
						elseif (drawtarget.health <= (Wdmg + AAdmg) and W ~= 0 and E ~= 0) then																																--W
						aCombo[drawtarget.name] = 17
						int5 = 17
						return 17
						elseif (drawtarget.health <= (Wdmgi + DFGdmg + AAdmg) and W ~= 0 and E ~= 0 and DFGI ~= 0) then																										--DFG W						--W
						aCombo[drawtarget.name] = 17
						int5 = 18
						return 18
						elseif (drawtarget.health <= (IGNITEdmg) and ignitos ~= 0) then																																		--IGNITE
						int5 = 19
						return 19
						elseif (drawtarget.health <= (Qdmg + Wdmg + AAdmg) and Q ~= 0 and W ~= 0 and E ~= 0) then 																											--Q+W
						aCombo[drawtarget.name] = 3
						return 3
						--elseif (drawtarget.health <= (Qdmgi + Wdmgi + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and DFGI ~= 0 and E ~= 0) then 																				--DFG Q+W
						--aCombo[drawtarget.name] = 4
						--return 4
						--int5 = 3
						elseif (drawtarget.health <= (Qdmg + Wdmg + IGNITEdmg + AAdmg) and Q ~= 0 and W ~= 0 and ignitos ~= 0 and E ~= 0) then																				--Q+W+IGN
						aCombo[drawtarget.name] = 5
						return 5
						--int5 = 5
						--elseif (drawtarget.health <= (Qdmgi + Wdmgi + IGNITEdmg + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and ignitos ~= 0 and DFGI ~= 0 and E ~= 0) then													--DFG Q+W+IGN
						--aCombo[drawtarget.name] = 6
						--return 6
						elseif (drawtarget.health <= (Rdmg + AAdmg) and R ~= 0) then																																		--R
						aCombo[drawtarget.name] = 16
						return 16
						--int5 = 16
						elseif (drawtarget.health <= (Qdmg + AAdmg + Rdmg) and Q ~= 0 and R ~= 0 ) then																														--Q+R
						aCombo[drawtarget.name] = 7
						return 7
						--int5 = 7
						--elseif (drawtarget.health <= (Qdmgi + AAdmg + DFGdmg + Rdmgi) and Q ~= 0 and R ~= 0 and DFGI ~= 0) then																							--DFG Q+R
						--aCombo[drawtarget.name] = 8
						--return 8
						elseif (drawtarget.health <= (Qdmg + IGNITEdmg + AAdmg + Rdmg) and Q ~= 0 and R ~= 0 and ignitos ~= 0 ) then																						--Q+R+IGN
						aCombo[drawtarget.name] = 9
						return 9
						--int5 = 9
						--elseif (drawtarget.health <= (Qdmgi + IGNITEdmg + AAdmg + DFGdmg + Rdmgi) and Q ~= 0 and R ~= 0 and ignitos ~= 0 and DFGI ~= 0) then																--DFG Q+R+IGN
						--aCombo[drawtarget.name] = 10
						--return 10
						elseif (drawtarget.health <= (Qdmg + Wdmg + Rdmg + AAdmg ) and Q ~= 0 and W ~= 0 and R ~= 0 and E ~= 0) then																						--Q+W+R
						aCombo[drawtarget.name] = 11
						return 11
						--int5 = 11
						elseif (drawtarget.health <= (Qdmgi + Wdmgi + Rdmgi + AAdmg + DFGdmg ) and Q ~= 0 and W ~= 0 and R ~= 0 and DFGI ~= 0 and E ~= 0) then																--DFG Q+W+R
						aCombo[drawtarget.name] = 12
						return 12
						--int5 = 12
						elseif (drawtarget.health <= (Qdmg + Wdmg + Rdmg + IGNITEdmg + AAdmg ) and Q ~= 0 and W ~= 0 and R ~= 0 and ignitos ~= 0 and E ~= 0 ) then												 			--Q+W+R+IGN
						aCombo[drawtarget.name] = 13
						return 13
						--int5 = 13
						elseif (drawtarget.health <= (Qdmgi + Wdmgi + Rdmgi + IGNITEdmg + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and R ~= 0 and ignitos ~= 0 and DFGI ~= 0 and E ~= 0) then									--DFG Q+W+R+IGN
						aCombo[drawtarget.name] = 14
						return 14
						--int5 = 14
						elseif (drawtarget.health > (Qdmgi + Wdmgi + Rdmgi + IGNITEdmg + AAdmg + DFGdmg) and Q ~= 0) then																									--unkillable
						aCombo[drawtarget.name] = 15
						return 15
						--int5 = 15
					end
					else
					if (drawtarget.health <= (Qdmg + AAdmg) and Q ~= 0 ) then																																				--Q
						aCombo[drawtarget.name] = 1
						int5 = 1
						return 1
						elseif (drawtarget.health <= (Qdmgi + AAdmg + DFGdmg) and Q ~= 0 and DFGI ~= 0) then																												--DFG Q
						aCombo[drawtarget.name] = 2
						int5 = 2
						return 2
						elseif (drawtarget.health <= (Wdmg + AAdmg) and W ~= 0 and E ~= 0) then																																--W
						aCombo[drawtarget.name] = 17
						int5 = 17
						return 17
						elseif (drawtarget.health <= (Wdmgi + DFGdmg + AAdmg) and W ~= 0 and E ~= 0 and DFGI ~= 0) then																										--DFG W						--W
						aCombo[drawtarget.name] = 17
						int5 = 18
						return 18
						elseif (drawtarget.health <= (IGNITEdmg) and ignitos ~= 0) then																																		--IGNITE
						int5 = 19
						return 19
						elseif (drawtarget.health <= (Qdmg + Wdmg + AAdmg) and Q ~= 0 and W ~= 0 and E ~= 0) then 																											--Q+W
						aCombo[drawtarget.name] = 3
						int5 = 3
						return 3
						elseif (drawtarget.health <= (Qdmgi + Wdmgi + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and DFGI ~= 0 and E ~= 0) then 																					--DFG Q+W
						aCombo[drawtarget.name] = 4
						int5 = 4
						return 4
						elseif (drawtarget.health <= (Qdmg + Wdmg + IGNITEdmg + AAdmg) and Q ~= 0 and W ~= 0 and ignitos ~= 0 and E ~= 0) then																				--Q+W+IGN
						aCombo[drawtarget.name] = 5
						int5 = 5
						return 5
						elseif (drawtarget.health <= (Qdmgi + Wdmgi + IGNITEdmg + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and ignitos ~= 0 and DFGI ~= 0 and E ~= 0) then														--DFG Q+W+IGN
						aCombo[drawtarget.name] = 6
						int5 = 6
						return 6
						elseif (drawtarget.health <= (Rdmg + AAdmg) and R ~= 0) then																																		--R
						aCombo[drawtarget.name] = 16
						int5 = 16
						return 16
						elseif (drawtarget.health <= (Qdmg + AAdmg + Rdmg) and Q ~= 0 and R ~= 0 ) then																														--Q+R
						aCombo[drawtarget.name] = 7
						int5 = 7
						return 7
						elseif (drawtarget.health <= (Qdmgi + AAdmg + DFGdmg + Rdmgi) and Q ~= 0 and R ~= 0 and DFGI ~= 0) then																								--DFG Q+R
						aCombo[drawtarget.name] = 8
						int5 = 8
						return 8
						elseif (drawtarget.health <= (Qdmg + IGNITEdmg + AAdmg + Rdmg) and Q ~= 0 and R ~= 0 and ignitos ~= 0 ) then																						--Q+R+IGN
						aCombo[drawtarget.name] = 9
						int5 = 9
						return 9
						elseif (drawtarget.health <= (Qdmgi + IGNITEdmg + AAdmg + DFGdmg + Rdmgi) and Q ~= 0 and R ~= 0 and ignitos ~= 0 and DFGI ~= 0) then																--DFG Q+R+IGN
						aCombo[drawtarget.name] = 10
						int5 = 10
						return 10
						elseif (drawtarget.health <= (Qdmg + Wdmg + Rdmg + AAdmg ) and Q ~= 0 and W ~= 0 and R ~= 0 and E ~= 0) then																						--Q+W+R
						aCombo[drawtarget.name] = 11
						int5 = 11
						return 11
						elseif (drawtarget.health <= (Qdmgi + Wdmgi + Rdmgi + AAdmg + DFGdmg ) and Q ~= 0 and W ~= 0 and R ~= 0 and DFGI ~= 0 and E ~= 0) then																--DFG Q+W+R
						aCombo[drawtarget.name] = 12
						int5 = 12
						return 12
						elseif (drawtarget.health <= (Qdmg + Wdmg + Rdmg + IGNITEdmg + AAdmg ) and Q ~= 0 and W ~= 0 and R ~= 0 and ignitos ~= 0 and E ~= 0 ) then												 			--Q+W+R+IGN
						aCombo[drawtarget.name] = 13
						int5 = 13
						return 13
						elseif (drawtarget.health <= (Qdmgi + Wdmgi + Rdmgi + IGNITEdmg + AAdmg + DFGdmg) and Q ~= 0 and W ~= 0 and R ~= 0 and ignitos ~= 0 and DFGI ~= 0 and E ~= 0) then									--DFG Q+W+R+IGN
						aCombo[drawtarget.name] = 14
						int5 = 14
						return 14
						elseif Q ~= 0 then																																													--unkillable
						aCombo[drawtarget.name] = 15
						int5 = 15
						return 15
					end
				end
				
		aCombo[drawtarget.name] = 0
		int5 = 0 
		return 0
	end
end

function performcombo1()
	if ts.target ~= nil then
		targ = ts.target
		if VeigarConfig.ew.forcestun then UseSpell(_E, targ) end
			UseSpell(_Q, targ)
			int4 = 0
	end
end

function performcombo2()
	if ts.target ~= nil then
		local DFG = GetInventorySlotItem(3128)
		targ = ts.target
			
		if VeigarConfig.ew.forcestun then UseSpell(_E, targ) end
			UseSpell(DFG, targ)
			UseSpell(_Q, targ)
			int4 = 0
	end
end

function performcombo3()
	if ts.target ~= nil then 
		targ = ts.target
			
		UseSpell(_E,targ)
			if W ~= 1 then
			UseSpell(_Q, targ)
			end
			int4 = 0
	end
end

function performcombo4()
	if ts.target ~= nil then 
		local DFG = GetInventorySlotItem(3128)
			targ = ts.target
			
		UseSpell(_E, targ)
			if W ~= 1 then
			UseSpell(DFG, targ)
			UseSpell(_Q, targ)
			end
			int4 = 0
	end
end

function performcombo5()
	if ts.target ~= nil then 
		targ = ts.target
		UseSpell(_E, targ)
		if W ~= 1 then
			if VeigarConfig.combo.tryq then
			UseSpell(ignite, targ)
			UseSpell(_Q, targ)
			else
			UseSpell(_Q, targ)
			UseSpell(ignite, targ)
			end
		end
		int4 = 0
	end
end

function performcombo6()
	if ts.target ~= nil then 
	local DFG = GetInventorySlotItem(3128)
		targ = ts.target
		UseSpell(_E, targ)
			if W ~= 1 then
			UseSpell(DFG, targ)
			if VeigarConfig.combo.tryq then
			UseSpell(ignite, targ)
			UseSpell(_Q, targ)
			else
			UseSpell(_Q, targ)
			UseSpell(ignite, targ)
			end
		end
		int4 = 0
	end
end

function performcombo7()
	if ts.target ~= nil then 
		targ = ts.target
		if VeigarConfig.ew.forcestun then UseSpell(_E, targ) end
		if VeigarConfig.combo.tryq then
		UseSpell(_R, targ)
		UseSpell(_Q, targ)
		else
		UseSpell(_Q, targ)
		UseSpell(_R, targ)
		end
		int4 = 0
	end
end

function performcombo8()
	if ts.target ~= nil then 
	local DFG = GetInventorySlotItem(3128)
		targ = ts.target
		if VeigarConfig.ew.forcestun then UseSpell(_E, targ) end
		UseSpell(DFG, targ)
		if VeigarConfig.combo.tryq then
		UseSpell(_R, targ)
		UseSpell(_Q, targ)
		else
		UseSpell(_Q, targ)
		UseSpell(_R, targ)
		end
		int4 = 0
	end
end

function performcombo9()
	if ts.target ~= nil then 
		targ = ts.target
		if VeigarConfig.ew.forcestun then UseSpell(_E, targ) end
		if VeigarConfig.combo.tryq then
		UseSpell(_R, targ)
		UseSpell(ignite, targ)
		UseSpell(_Q, targ)
		else
		UseSpell(_Q, targ)
		UseSpell(_R, targ)
		UseSpell(ignite, targ)
		end
		int4 = 0
	end
end

function performcombo10()
	if ts.target ~= nil then 
	local DFG = GetInventorySlotItem(3128)
		targ = ts.target
		UseSpell(_E, targ)
		UseSpell(DFG, targ)
		if VeigarConfig.combo.tryq then
		UseSpell(_R, targ)
		UseSpell(ignite, targ)
		UseSpell(_Q, targ)
		else
		UseSpell(_Q, targ)
		UseSpell(_R, targ)
		UseSpell(ignite, targ)
		end
		int4 = 0
	end
end

function performcombo11()
	if ts.target ~= nil then 
		targ = ts.target
		UseSpell(_E, targ)
			if W ~= 1 then
			if VeigarConfig.combo.tryq then
			UseSpell(_R, targ)
			UseSpell(_Q, targ)
			else
			UseSpell(_Q, targ)
			UseSpell(_R, targ)
			end
		end
		int4 = 0
	end
end

function performcombo12()
	if ts.target ~= nil then 
	local DFG = GetInventorySlotItem(3128)
		targ = ts.target
		UseSpell(_E, targ)
			if W ~= 1 then
			UseSpell(DFG, targ)
			if VeigarConfig.combo.tryq then
			UseSpell(_R, targ)
			UseSpell(_Q, targ)
			else
			UseSpell(_Q, targ)
			UseSpell(_R, targ)
			end
		end
		int4 = 0
	end
end

function performcombo13()
	if ts.target ~= nil then 
		targ = ts.target
		UseSpell(_E, targ)
			if W ~= 1 then
			if VeigarConfig.combo.tryq then
			UseSpell(_R, targ)
			UseSpell(ignite, targ)
			UseSpell(_Q, targ)
			else
			UseSpell(_Q, targ)
			UseSpell(_R, targ)
			UseSpell(ignite, targ)
			end
		end
		int4 = 0
	end
end

function performcombo14()
	if ts.target ~= nil then 
	local DFG = GetInventorySlotItem(3128)
		targ = ts.target
		UseSpell(_E, targ)
			if W ~= 1 then
			UseSpell(DFG, targ)
			if VeigarConfig.combo.tryq then
			UseSpell(_R, targ)
			UseSpell(ignite, targ)
			UseSpell(_Q, targ)
			else
			UseSpell(_Q, targ)
			UseSpell(_R, targ)
			UseSpell(ignite, targ)
			end
		end
		int4 = 0
	end
end

function performcombo15()
	if ts.target ~= nil then 
		targ = ts.target
		if VeigarConfig.ew.forcestun then UseSpell(_E, targ) end
		UseSpell(_Q, targ)
		int4 = 0
	end
end

function performcombo16()
	if ts.target ~= nil then 
		targ = ts.target
		if VeigarConfig.ew.forcestun then UseSpell(_E, targ) end
		UseSpell(_R, targ)
		int4 = 0
	end
end

function performcombo17()
	if ts.target ~= nil then 
		targ = ts.target
		UseSpell(_E, targ)
	int4 = 0
	end
end

function performcombo18()
	if ts.target ~= nil then 
		local DFG = GetInventorySlotItem(3128)
		targ = ts.target
		UseSpell(_E, targ)
			if targ.canMove ~= true then
			UseSpell(DFG, targ)
			end
	int4 = 0
	end
end

function performcombo19()
	if ts.target ~= nil then 
		local DFG = GetInventorySlotItem(3128)
		targ = ts.target
		if VeigarConfig.ew.forcestun then UseSpell(_E, targ) end
		UseSpell(ignite, targ)
	int4 = 0
	end
end


function AutoLevel()
	if VeigarConfig.other.lvlup == 1 then
		abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 2, 1, 4, 2, 2, 3, 2, 4, 3, 3, }
	elseif VeigarConfig.other.lvlup == 2 then
		abilitySequence = { 1, 3, 2, 1, 2, 4, 2, 3, 2, 1, 4, 2, 1, 3, 1, 4, 1, 3, }
	elseif VeigarConfig.other.lvlup == 3 then
		abilitySequence = { 1, 3, 2, 3, 2, 4, 3, 2, 3, 2, 4, 3, 2, 1, 1, 4, 1, 1, }
	end
	
	if VeigarConfig.other.Autolvl then
		local qL, wL, eL, rL = player:GetSpellData(_Q).level + qOff, player:GetSpellData(_W).level + wOff, player:GetSpellData(_E).level + eOff, player:GetSpellData(_R).level + rOff
		if qL + wL + eL + rL < player.level then
			local spellSlot = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
			local level = { 0, 0, 0, 0 }
			for i = 1, player.level, 1 do
				level[abilitySequence[i]] = level[abilitySequence[i]] + 1
			end
			for i, v in ipairs({ qL, wL, eL, rL }) do
				if v < level[i] then LevelSpell(spellSlot[i]) end
			end
		end
	end
end

function LifeSaver()
	if VeigarConfig.LifeSaver.LifeSaver then
	local closestEnemy = findClosestEnemy()
		if closestEnemy ~= nil and CanUseSpell(_E) == READY and not myHero.dead and GetDistance(closestEnemy) < VeigarConfig.LifeSaver.LifeSaverRange then
			UseSpell(_E,closestEnemy)
		end
	end
end

function findClosestEnemy()
	local closestEnemy = nil
	local currentEnemy = nil
	for i=1, heroManager.iCount do
		currentEnemy = heroManager:GetHero(i)
		if currentEnemy.team ~= myHero.team and not currentEnemy.dead and currentEnemy.visible then
			if closestEnemy == nil then
				closestEnemy = currentEnemy
			elseif GetDistance(currentEnemy) < GetDistance(closestEnemy) then
				closestEnemy = currentEnemy
			end
		end
	end
	return closestEnemy
end

function UseStunV2()
		local lowest = nil
		local lowPos = nil

		for i=0, heroManager.iCount, 1 do
			local enemy = heroManager:GetHero(i)
			local position = CagePosition(player, enemy, true)

			if position ~= nil then
				lowPos = position
				lowest = enemy
			end
		end

		if lowest ~= nil and player:CanUseSpell(_E) == READY then
			CastSpell(_E, lowPos.x, lowPos.z)
		end

end

function UseStunV3()
		minD = 0
		minE = nil
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, erange+eradius) then
				if GetDistance(enemy) < minD or minE == nil then
					minD = GetDistance(enemy)
					minE = enemy
				end
			end
		end
		if minE ~= nil then
			UseE(minE)
		end
end

function UseE(target)
	local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(target, Edelay, Ewidth, math.huge)
	ProdictionECallback(target, Position, _E)
end

function ProdictionECallback(unit, pos, spell)
	if not E == 1 then return end
	local PredictedPosition = Vector(pos.x, 0, pos.z)
	local myPos = Vector(myHero.x, 0, myHero.z)
	local Targets = {}
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) and (enemy.charName ~= unit.charName) then
				local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(enemy, Edelay, Ewidth, math.huge)
				if Position and (GetDistance(Position) <= erange + eradius) then
					table.insert(Targets, Position)
				end
			end
		end
		
		--[[At the moment only 2 targets supported]]
		while #Targets > 1 do
			table.remove(Targets, 1)
		end
		
		--[[The main target and another 1]]
		if #Targets == 1 then
			PredictedTargetPos = PredictedPosition -- for debugging
			SecondaryPos = Vector(Targets[1].x, 0, Targets[1].z)
			if (GetDistance(PredictedPosition, SecondaryPos) <= eradius * 2) and (GetDistance(PredictedPosition, SecondaryPos) ~= 0) then
				--Get the point(s) to get the two targets 
				Solution1, Solution2 = CalculateEcastPoints(SecondaryPos, PredictedPosition)
				if GetDistance(Solution1) <= erange then
					ECastPosition = Solution1
				elseif GetDistance(Solution2) <= erange then
					ECastPosition = Solution2
				else--[[Solutions out of range, calculate the solution for the main target]]
					table.remove(Targets, 1)
				end
			else --Cant get the two targets, calculate the solution for the main target
				table.remove(Targets, 1)
			end
		end
	
	--[[Only 1 target in range, cast E in our direction]]
	if #Targets == 0 then
		local DirectionVector = eradius * (myPos - PredictedPosition):normalized()
		ECastPosition = Vector(PredictedPosition.x + DirectionVector.x, 0, PredictedPosition.z + DirectionVector.z)
	end
	
	if ECastPosition and (GetDistance(ECastPosition) < erange) then
			CastSpell(_E, ECastPosition.x, ECastPosition.z)
	end
end

function ProdictionWCallback(unit, pos, spell)
	local PredictedPosition = Vector(pos.x, 0, pos.z)
	local myPos = Vector(myHero.x, 0, myHero.z)
		if (GetDistance(PredictedPosition) < (wrange + wradius)) and W ~= 0 then
			local DirectionVector = wrange * (PredictedPosition - myPos):normalized()
			if GetDistance(PredictedPosition) <= wrange then
				CastSpell(_W, PredictedPosition.x, PredictedPosition.z)		
			else
				CastSpell(_W, myPos.x + DirectionVector.x, myPos.z + DirectionVector.z)
			end
		end

end

function CalculateEcastPoints(target1, target2)
	local CenterPoint = Vector((target1.x + target2.x)/2,0,(target1.z + target2.z)/2)
	local Perpendicular = Vector(target1.x - target2.x, 0, target1.z - target2.z):normalized():perpendicular()
	local D = GetDistance(target1, target2) / 2
	local A = math.sqrt(eradius * eradius - D * D)
	local S1 = CenterPoint + A * Perpendicular
	local S2 = CenterPoint - A * Perpendicular
	return S1, S2
end

function CagePosition(player, enemy, prediction)
	if IsGoodTarget(enemy, cageRange) and OtherTeam(enemy) then
		local enemyPred = nil

		if prediction == true then
			enemyPred = GetPredictionPos(enemy, 500)
		else
			enemyPred = enemy
		end

		-- calculation of cage position
		local a = (enemyPred.z - player.z) / (enemyPred.x - player.x)
		local b = player.z - a * player.x

		local pos = { }
		pos.x = player.x + 1
		pos.z = a * pos.x + b

		local plusX  = (GetDistance(player, enemyPred) - cageItselfRange + cageDiff) / GetDistance(player, pos)

		if GetDistance(enemyPred, pos) < GetDistance(enemyPred, player) then
			pos.x = player.x + plusX
		else
			pos.x = player.x - plusX
		end

		pos.z = a * pos.x + b
		pos.y = player.y

		return pos
	else
		return nil
	end
end

function OtherTeam(target)
	return target.team ~= player.team
end

function Checks()
	ts:update()
	--DFG CHECK--
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
	--Q,W,E,R,IGNITE CHECK--
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
	
	ignite = IgniteSlot()
	if (ignite ~= nil) and (myHero:CanUseSpell(ignite) == READY) then 
	ignitos = 1
	else
	ignitos = 0
	end
	
	if CanUseSpell(_E) == READY then
	E = 1
	else
	E = 0
	end
	--Farm way check--
	if VeigarConfig.farm.farmm == 1 then SetMode = SCRIPT_PARAM_ONKEYTOGGLE else SetMode = SCRIPT_PARAM_ONKEYDOWN end
	VeigarConfig.farm._param[1].pType = SetMode
	if VeigarConfig.farm.farmmm == 1 then SetMode1 = SCRIPT_PARAM_ONKEYTOGGLE else SetMode1 = SCRIPT_PARAM_ONKEYDOWN end
	VeigarConfig.farm._param[2].pType = SetMode1
	--Zhonya&Wooglet check--
	znaReady = (zhonya ~= nil and myHero:CanUseSpell(zhonya) == READY)
	wgtReady = (wooglet ~= nil and myHero:CanUseSpell(wooglet) == READY)
	--COMBO CHECKS--
	if VeigarConfig.combo.spacebarActive and ValidTarget(ts.target) then
		performSmartCombo()
		if int4 ~= 1 and VeigarConfig.combo.forceaa then aa() end
	end
	
	if VeigarConfig.combo.wasteall and ValidTarget(ts.target) then
		performWasteCombo()
		if int4 ~= 1 and VeigarConfig.combo.forceaa then aa() end
	end
	
	if VeigarConfig.combo.lightcombo and ValidTarget(ts.target) then
		performLightCombo()
		if int4 ~= 1 and VeigarConfig.combo.forceaa then aa() end
	end
	
	for i, enemy in ipairs(GetEnemyHeroes()) do
		expos = enemy.pos
	end
	--SLOT CHECKS--
	hppot = GetInventorySlotItem(2003)
	mppot = GetInventorySlotItem(2004)
	elixir = GetInventorySlotItem(2037)
	flaskk = GetInventorySlotItem(2041)
	Biscuit = GetInventorySlotItem(2010)
	zhonya = GetInventorySlotItem(3157)
	wooglet = GetInventorySlotItem(3090)
end

function GetNMinionsHit(Pos, radius)
	local count = 0
	for i, minion in pairs(EnemyMinions2.objects) do
		if GetDistance(minion, Pos) < (radius + 50) then
			count = count + 1
		end
	end
	return count
end
