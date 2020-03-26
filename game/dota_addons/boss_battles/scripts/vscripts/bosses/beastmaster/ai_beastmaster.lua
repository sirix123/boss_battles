
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

	-- phase setup variables 
	PHASE_1_DURATION = 60.0
	PHASE_2_DURATION = 30.0 
	PHASE_ONE = 1
	PHASE_TWO = 2
	thisEntity.Phase = PHASE_ONE

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
	
	Phase_1()
	
	-- if animals die remove them from the table
	ClearAnimals()

	return 0.5
end

--------------------------------------------------------------------------------

-- phase 1
--[[
Phase 1 is the intial phase of the beastmaster boss. During this phase he will cast most of his abilities on cooldown the cooldown will not modified.
He will not cast stampede during this phase.
He will also stick on one target for as long as possible.
]]--
function Phase_1()

	-- handles bear summoning, summons first bear after x gametime
	-- summons second+ bear after x time, LastBearDeath is populated in the ClearAnimals() function
	local delayBeforeFirstBear = 5
	local delayAfterBearDeath = 120
	BearCastingTiming(delayBeforeFirstBear, delayAfterBearDeath)

	-- handles summon quill boars, summons the first set of boars after x gametime
	-- handles summoning the second+ sets
	-- summons 3 boars initially then every x seconds will replace dead boars with new ones based on delayAfterLastBoarDeath 
	local delayBeforeFirstBoarSet = 20
	local delayAfterLastBoarDeath = 50
	BoarCastingTiming(delayBeforeFirstBoarSet, delayAfterLastBoarDeath)

	-- handles the spear throw logic
	-- phase one spears start x time in to the fight
	-- time between spears is longer then other phases
	local delayBeforeFirstNet = 30
	local delayAfterLastNet = 20
	NetCastingTime(delayBeforeFirstNet, delayAfterLastNet)

	--

	--BreakArmor()

end
--------------------------------------------------------------------------------

-- phase 2
--[[

]]--
function Phase_2()

----- stampede phase bb

end

--------------------------------------------------------------------------------
function NetCastingTime(delayBeforeFirstNet, delayAfterLastNet)
	if GameRules:GetGameTime() > ( thisEntity.beastMasterSpawnTime + delayBeforeFirstNet ) and thisEntity.firstNet == true then
		BeastmasterNet()
		thisEntity.firstNet = false
	elseif thisEntity.beastMasterSpawnTime > (thisEntity.lastNet + delayAfterLastNet) then
		thisEntity.lastNet = GameRules:GetGameTime()
		BeastmasterNet()
	end
end

--------------------------------------------------------------------------------
function BoarCastingTiming(delayBeforeFirstBoarSet, delayAfterLastBoarDeath)
	if GameRules:GetGameTime() > ( thisEntity.beastMasterSpawnTime + delayBeforeFirstBoarSet ) and thisEntity.firstBoar  == true then
		SummonQuillBoar()
		thisEntity.firstBoar  = false
	elseif thisEntity.beastMasterSpawnTime > (thisEntity.lastBoarDeath + delayAfterLastBoarDeath) then
		SummonQuillBoar()
	end
end

--------------------------------------------------------------------------------
function BearCastingTiming(delayBeforeFirstBear, delayAfterBearDeath)
	if GameRules:GetGameTime() > ( thisEntity.beastMasterSpawnTime + delayBeforeFirstBear ) and thisEntity.firstBear == true then
		SummonBear()
		MarkTarget()
		thisEntity.firstBear = false
	elseif thisEntity.beastMasterSpawnTime > (thisEntity.lastBearDeath + delayAfterBearDeath) then
		SummonBear()
		MarkTarget()
	end 
end

--------------------------------------------------------------------------------
function MarkTarget()
	
	-- find all players in the entire map
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	if #enemies == 0 then
		return 0.5
	end

	-- select random enemy 
	local hTarget = enemies[ RandomInt( 1, #enemies ) ]

	if hTarget ~= nil then
		return CastMarkTarget(hTarget)
	end

	return 0.5
end

--------------------------------------------------------------------------------
function BreakArmor()

	-- find all players in the entire map
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	if #enemies == 0 then
		return 0.5
	end

	local vTargetPos = enemies[ RandomInt( 1, #enemies ) ]:GetAbsOrigin()

	if vTargetPos ~= nil then
		local fabilityRangeCheck = thisEntity.beastmaster_break:GetCastRange(vTargetPos, nil)
		local fRangeToTarget = ( thisEntity:GetOrigin() - vTargetPos ):Length2D()
		--print("break range = ", fabilityRangeCheck, "fRangeToTarget = ", fRangeToTarget)

		if fabilityRangeCheck < fRangeToTarget then
			return CastBreakArmor( vTargetPos )
		end
	end
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

function CastBeastmasterMark()

	local bHasModifier = nil

	-- find all friendlies in the entire map
	local friendlies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE , DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	if #friendlies == 0 then
		return 0.5
	end

	-- cast beastmasterMarkTarget, remove blodo lust stacks on the bear
	if thisEntity.beastmaster_mark ~= nil and thisEntity.beastmaster_mark:IsCooldownReady() then
		-- search for bear with lust stacks
		for key, friendly in pairs(friendlies) do 
			bHasModifier = friendly:HasModifier("bear_bloodlust_modifier")
			if friendly:HasModifier("bear_bloodlust_modifier") then
				bearWithBloodlust = friendly
				bearWithBloodlust:SetModifierStackCount("bear_bloodlust_modifier", bearWithBloodlust, 0)
			end
		end

		return MarkTarget()
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
			vTargetPos = enemy:GetAbsOrigin()
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

--------------------------------------------------------------------------------

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
		Queue = false,
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
		Queue = 1,
	})
	return 0.5
end