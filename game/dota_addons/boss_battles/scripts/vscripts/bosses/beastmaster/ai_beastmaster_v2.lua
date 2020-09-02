LinkLuaModifier("ai_bear", "bosses/beastmaster/ai_bear", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	-- boss setup 
	-- controls max number of animals he can summon
	thisEntity.BEAST_MASTER_SUMMONED_QUILBOARS = {  }
	thisEntity.MAX_QUILBOARS = 3

	-- max bears
	thisEntity.BEAST_MASTER_SUMMONED_BEARS = {  }
	thisEntity.MAX_BEARS = 1

	-- abilities this boss has
	thisEntity.beastmaster_mark = thisEntity:FindAbilityByName( "beastmaster_mark" )
	thisEntity.summon_bear = thisEntity:FindAbilityByName( "summon_bear" )
	thisEntity.summon_quillboar = thisEntity:FindAbilityByName( "summon_quillboar" )
	thisEntity.beastmaster_net = thisEntity:FindAbilityByName( "beastmaster_net" )
	thisEntity.beastmaster_break = thisEntity:FindAbilityByName( "beastmaster_break" )

	-- used for bear summoning logic
	thisEntity.firstBear = true
	thisEntity.lastBearDeath = 0

	-- used for boar summoning logic
	thisEntity.firstBoar = true
	thisEntity.lastBoarDeath = 0

	-- used for first net logic
	thisEntity.firstNet = true
	thisEntity.lastNet = 0

	-- the gametime beastmaster was spawned
	thisEntity.beastMasterSpawnTime = GameRules:GetGameTime()

	thisEntity:SetContextThink( "Beastmaster", BeastmasterThink, 1 )
end

--------------------------------------------------------------------------------

function BeastmasterThink()
	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	-- cast spells on cd 
	-- start beastmasters cooldowns on spawn so there is some time at start of fight

	-- summon bear on spawn
	-- if bear dies perma buff boss (function for that)

	-- handles bear summoning, summons first bear after x gametime
	-- summons second+ bear after x time, LastBearDeath is populated in the ClearAnimals() function
	local delayBeforeFirstBear = 5
	local delayAfterBearDeath = 120
	BearCastingTiming(delayBeforeFirstBear, delayAfterBearDeath)

	-- handles summon quill boars, summons the first set of boars after x gametime
	-- handles summoning the second+ sets
	-- summons 3 boars initially then every x seconds will replace dead boars with new ones based on delayAfterLastBoarDeath 
	local delayBeforeFirstBoarSet = 15
	local delayAfterLastBoarDeath = 50
	BoarCastingTiming(delayBeforeFirstBoarSet, delayAfterLastBoarDeath)

	-- handles the spear throw logic
	-- phase one spears start x time in to the fight
	-- time between spears is longer then other phases
	local delayBeforeFirstNet = 5
	local delayAfterLastNet = 2
	NetCastingTime(delayBeforeFirstNet, delayAfterLastNet)

	-- casts mark on CD as well 
	BeastmasterMark()

	-- will only try and cast breakarmor on a targets postion if in range 
	BreakArmor()

	-- attack move? attack highest HP hero?

	-- if animals die remove them from the table
	ClearAnimals()

	return 0.5
end

--------------------------------------------------------------------------------
function BreakArmor()

	-- slam ground within some radius (hardcoded 500 atm)
	-- apply -armor debuff
	-- some sort of telegraph required (red circle on the ground, missile salvo reference)

	-- find all players in the entire map
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, 500 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	if #enemies == 0 then
		return 0.5
	end

	local vTargetPos = enemies[ RandomInt( 1, #enemies ) ]:GetAbsOrigin()

	CastBreakArmor( vTargetPos )

	return 0.5
end

--------------------------------------------------------------------------------

function ClearAnimals()

	-- if bear dies remove from summon table
	for i, hSummonedBear in ipairs(thisEntity.BEAST_MASTER_SUMMONED_BEARS) do
		if hSummonedBear:IsAlive() == false then
			table.remove( thisEntity.BEAST_MASTER_SUMMONED_BEARS, i )
			thisEntity.lastBearDeath = GameRules:GetGameTime()
		end
	end

	-- if quilboar dies remove from summon table
	for i, hSummonedQuillboar in ipairs(thisEntity.BEAST_MASTER_SUMMONED_QUILBOARS) do
		if hSummonedQuillboar:IsAlive() == false then
			table.remove( thisEntity.BEAST_MASTER_SUMMONED_QUILBOARS, i )
			thisEntity.lastBoarDeath = GameRules:GetGameTime()
		end
	end

	return 0.5
end

--------------------------------------------------------------------------------

function SummonBear()

	-- find all units on map
	-- if bear is found and is alive
	-- startcd for bear
	-- check this function every whatever
	-- if bear is dead and cd ready then summon bear 

	-- summon logic for bear
	-- have we hit the limit?
	if #thisEntity.BEAST_MASTER_SUMMONED_BEARS < thisEntity.MAX_BEARS then 
		if thisEntity.summon_bear ~= nil and thisEntity.summon_bear:IsFullyCastable() then
			return CastSummonBear()
		end
	end

	return 0.5
end

--------------------------------------------------------------------------------

function SummonQuillBoar()

	-- summon logic for quillboar
	-- have we hit the limit?
	if #thisEntity.BEAST_MASTER_SUMMONED_QUILBOARS < thisEntity.MAX_QUILBOARS then 
		if thisEntity.summon_quillboar ~= nil and thisEntity.summon_quillboar:IsFullyCastable() then
			return CastSummonQuillboar()
		end
	end

	return 0.5
end

------------------------------------------------------------------------------------------------------------

function BeastmasterMark()


	-- just controls who the bear attacks
	-- switches every xseconds
	-- bear needs to seak player with the mark
	-- duration of this markmodifier needs to control the switching time

	local bHasModifier = nil

	-- find all players in the entire map
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	if #enemies == 0 then
		return 0.5
	end

	-- select random enemy 
	local hTarget = enemies[ RandomInt( 1, #enemies ) ]

	-- if enemey selected is not nil, cast mark target on target
	if hTarget ~= nil then
		return CastMarkTarget(hTarget)
	end

	return 0.5
end

-----------------------------------------------------------------------------------

function BeastmasterNet()

	-- shoot net/spear at enemy player
	-- find all players in the entire map
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	if #enemies == 0 then
		return 0.5
	end

	local vTargetPos = nil

	if thisEntity.beastmaster_net ~= nil and thisEntity.beastmaster_net:IsFullyCastable() then
		for key, enemy in pairs(enemies) do
			vTargetPos = enemy:GetOrigin()
		end

		if vTargetPos ~= nil then
			thisEntity.lastNet = GameRules:GetGameTime()
			return CastLaunchNet( vTargetPos )
		else
			return 0.5
		end

	end
	return 0.5
end

---------------------------------------------------------------------------------

function CastSummonBear()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.summon_bear:entindex(),
		Queue = 0,
	})
	return 0.5
end

--------------------------------------------------------------------------------

function CastLaunchNet(vTargetPos)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = thisEntity.beastmaster_net:entindex(),
		Position = vTargetPos,
		Queue = false,
	})
	return 0.5
end

--------------------------------------------------------------------------------

function CastSummonQuillboar()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.summon_quillboar:entindex(),
		Queue = 0,
	})
	return 0.5
end

--------------------------------------------------------------------------------
function CastBreakArmor(vTargetPos)

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = thisEntity.beastmaster_break:entindex(),
		Position = vTargetPos,
		Queue = false,
	})
	return 0.5
end

--------------------------------------------------------------------------------
function CastMarkTarget(hTarget)

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = hTarget:entindex(),
		AbilityIndex = thisEntity.beastmaster_mark:entindex(),
		Queue = 2,
	})
	return 0.5
end