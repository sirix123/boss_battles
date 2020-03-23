
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
	
	-- overall phase transitions
	local phase1Duration = 60

	if (GameRules:GetGameTime() < phase1Duration) then
		Phase_1()
	elseif (GameRules:GetGameTime() > phase1Duration) then
		Phase_2()
	end
	--elseif (GameRules:GetGameTime() > phase1Duration and thisEntity) then
		--Phase_3()
	--end
	
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
	local delayBeforeFirstBear = 10
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
	local delayBeforeFirstNet = 30
	local delayAfterLastNet = 20
	NetCastingTime(delayBeforeFirstNet, delayAfterLastNet)

	CastBeastmasterMark()

	CastBreakArmor()

end
--------------------------------------------------------------------------------

-- phase 2
--[[

]]--
function Phase_2()

	-- handles bear summoning, summons first bear after x gametime
	-- summons second+ bear after x time, LastBearDeath is populated in the ClearAnimals() function
	local delayBeforeFirstBear = 0
	local delayAfterBearDeath = 60
	BearCastingTiming(delayBeforeFirstBear, delayAfterBearDeath)

	-- handles summon quill boars, summons the first set of boars after x gametime
	-- handles summoning the second+ sets
	-- summons 3 boars initially then every x seconds will replace dead boars with new ones based on delayAfterLastBoarDeath 
	local delayBeforeFirstBoarSet = 0
	local delayAfterLastBoarDeath = 30
	BoarCastingTiming(delayBeforeFirstBoarSet, delayAfterLastBoarDeath)

	-- handles the spear throw logic
	-- phase one spears start x time in to the fight
	-- time between spears is longer then other phases
	local delayBeforeFirstNet = 0
	local delayAfterLastNet = 10
	NetCastingTime(delayBeforeFirstNet, delayAfterLastNet)

	BreakArmor()

end

--------------------------------------------------------------------------------

-- phase 3
--[[
 stampede phase
]]--
function Phase_3()

	print("Beastmaster Starting Phase 3 ...")

	-- handles summon quill boars, summons the first set of boars after x gametime
	-- handles summoning the second+ sets
	-- summons 3 boars initially then every x seconds will replace dead boars with new ones based on delayAfterLastBoarDeath 
	local delayBeforeFirstBoarSet = 15
	local delayAfterLastBoarDeath = 30
	BoarCastingTiming(delayBeforeFirstBoarSet, delayAfterLastBoarDeath)

	-- handles the spear throw logic
	-- phase one spears start x time in to the fight
	-- time between spears is longer then other phases
	local delayBeforeFirstNet = 30
	local delayAfterLastNet = 5
	NetCastingTime(delayBeforeFirstNet, delayAfterLastNet)

end

--------------------------------------------------------------------------------
function NetCastingTime(delayBeforeFirstNet, delayAfterLastNet)
	if (GameRules:GetGameTime() > delayBeforeFirstNet) and thisEntity.firstNet == true then
		CastBeastmasterNet()
		thisEntity.firstNet = false
	elseif GameRules:GetGameTime() > (thisEntity.lastNet + delayAfterLastNet) then
		thisEntity.lastNet = GameRules:GetGameTime()
		CastBeastmasterNet()
	end
end

--------------------------------------------------------------------------------
function BoarCastingTiming(delayBeforeFirstBoarSet, delayAfterLastBoarDeath)
	if (GameRules:GetGameTime() > delayBeforeFirstBoarSet) and thisEntity.firstBoar  == true then
		SummonQuillBoar()
		thisEntity.firstBoar  = false
	elseif GameRules:GetGameTime() > (thisEntity.lastBoarDeath + delayAfterLastBoarDeath) then
		SummonQuillBoar()
	end
end

--------------------------------------------------------------------------------
function BearCastingTiming(delayBeforeFirstBear, delayAfterBearDeath)
	if (GameRules:GetGameTime() > delayBeforeFirstBear) and thisEntity.firstBear == true then
		SummonBear()
		thisEntity.firstBear = false
	elseif GameRules:GetGameTime() > (thisEntity.lastBearDeath + delayAfterBearDeath) then
		SummonBear()
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

	-- cast mark on target
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = hTarget:entindex(),
		AbilityIndex = thisEntity.beastmaster_mark:entindex(),
		Queue = false,
	})

	return 1.0
end



--------------------------------------------------------------------------------
function AttackClosest()
	
	-- find all players in the entire map
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
	if #enemies == 0 then
		return 0.5
	end

	-- select random enemy 
	local hTarget = enemies[ RandomInt( 1, #enemies ) ]

	-- attack cloest on target
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET ,
		TargetIndex = hTarget:entindex(),
		Queue = false,
	})

	-- apply break armor 
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = hTarget:entindex(),
		AbilityIndex = thisEntity.beastmaster_break:entindex(),
		Queue = false,
	})

	return 0.5
end

--------------------------------------------------------------------------------
function BreakArmor()

	-- find all players in the entire map
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
	if #enemies == 0 then
		return 0.5
	end

	local vTargetPos = nil

	if thisEntity.beastmaster_break ~= nil and thisEntity.beastmaster_break:IsFullyCastable() then
		for key, enemy in pairs(enemies) do
			vTargetPos = enemy:GetAbsOrigin()
		end

		if vTargetPos ~= nil then
			return CastBreakArmor( vTargetPos )
		else
			return 0.5
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
			print('summoing bear')
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

function CastBeastmasterNet()

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
			return LaunchNet( vTargetPos )
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
	})
	return 0.5
end

--------------------------------------------------------------------------------

function LaunchNet(vTargetPos)
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