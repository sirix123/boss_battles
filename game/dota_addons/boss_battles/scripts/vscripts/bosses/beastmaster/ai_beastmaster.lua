
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
	thisEntity.stampede = thisEntity:FindAbilityByName( "stampede" )
	thisEntity.change_to_phase_2 = thisEntity:FindAbilityByName( "change_to_phase_2" )
	thisEntity.change_to_phase_1 = thisEntity:FindAbilityByName( "change_to_phase_1" )

	thisEntity.stampede = thisEntity:FindAbilityByName( "stampede" )

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
	PHASE_1_DURATION = 10
	PHASE_2_DURATION = 10
	PHASE_ONE = 1
	PHASE_TWO = 2
	TRIGGER_PHASE_CD = 5

	thisEntity.Phase = PHASE_ONE
	thisEntity.CurrentPhase = nil
	thisEntity.flPhaseOneTriggerEndTime = 0
	thisEntity.flPhaseTwoTriggerEndTime = 0
	thisEntity.flNextPhaseTime = nil

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

	if thisEntity.flNextPhaseTime == nil then
		thisEntity.flNextPhaseTime = GameRules:GetGameTime() + TRIGGER_PHASE_CD
	end

	-- check if we need to change phases 
	CheckPhaseChange()


	
	-- might need a seperaet function here to cast 'enter phase1 / phase2'
	if thisEntity.Phase == PHASE_ONE then
		--print("Calling Phase_1()")
		thisEntity.CurrentPhase = PHASE_ONE
		Phase_1()
	elseif thisEntity.Phase == PHASE_TWO then
		print("Calling Phase_2()")
		thisEntity.CurrentPhase = PHASE_TWO
		Phase_2()
	end
	
	-- if animals die remove them from the table
	ClearAnimals()

	return 0.5
end

--------------------------------------------------------------------------------
function CheckPhaseChange()

	if thisEntity.flNextPhaseTime > GameRules:GetGameTime() then
		return false
	end

	thisEntity.flPhaseOneTriggerEndTime = GameRules:GetGameTime() + PHASE_1_DURATION
	thisEntity.flPhaseTwoTriggerEndTime = GameRules:GetGameTime() + PHASE_2_DURATION

	if thisEntity.Phase == PHASE_ONE then 
		if thisEntity.flPhaseOneTriggerEndTime > GameRules:GetGameTime() then
			CastChangeToPhase2()
			thisEntity.flNextPhaseTime = GameRules:GetGameTime() + TRIGGER_PHASE_CD + PHASE_2_DURATION
			thisEntity.Phase = PHASE_TWO
		end
	elseif thisEntity.Phase == PHASE_TWO then 
		if thisEntity.flPhaseTwoTriggerEndTime > GameRules:GetGameTime() then
			CastChangeToPhase1()
			thisEntity.flNextPhaseTime = GameRules:GetGameTime() + TRIGGER_PHASE_CD + PHASE_1_DURATION
			thisEntity.Phase = PHASE_ONE
		end
	end
	
	return thisEntity.Phase
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
	--BearCastingTiming(delayBeforeFirstBear, delayAfterBearDeath)

	-- handles summon quill boars, summons the first set of boars after x gametime
	-- handles summoning the second+ sets
	-- summons 3 boars initially then every x seconds will replace dead boars with new ones based on delayAfterLastBoarDeath 
	local delayBeforeFirstBoarSet = 10
	local delayAfterLastBoarDeath = 50
	--BoarCastingTiming(delayBeforeFirstBoarSet, delayAfterLastBoarDeath)

	-- handles the spear throw logic
	-- phase one spears start x time in to the fight
	-- time between spears is longer then other phases
	local delayBeforeFirstNet = 1
	local delayAfterLastNet = 2
	NetCastingTime(delayBeforeFirstNet, delayAfterLastNet)

	-- casts mark on CD as well 
	--BeastmasterMark()

	-- will only try and cast breakarmor on a targets postion if in range 
	--BreakArmor()

	-- attack move? attack highest HP hero?

end
--------------------------------------------------------------------------------

-- phase 2

 isStampedeInProgress = false
function Phase_2()
	--print("Phase_2()")

	if not isStampedeInProgress then
		print("Stampede not in progress. Starting Stampede")
		isStampedeInProgress = true
		ChannelStampede() 

	end
	if isStampedeInProgress then
		print("Stampede in progress")
	end
	

end

--------------------------------------------------------------------------------
function NetCastingTime(delayBeforeFirstNet, delayAfterLastNet)
	if GameRules:GetGameTime() > ( thisEntity.beastMasterSpawnTime + delayBeforeFirstNet ) and thisEntity.firstNet == true then
		BeastmasterNet()
		thisEntity.firstNet = false
	elseif GameRules:GetGameTime() > ( thisEntity.lastNet + delayAfterLastNet ) then
		thisEntity.lastNet = GameRules:GetGameTime()
		BeastmasterNet()
	end
end

--------------------------------------------------------------------------------
function BoarCastingTiming(delayBeforeFirstBoarSet, delayAfterLastBoarDeath)
	if GameRules:GetGameTime() > ( thisEntity.beastMasterSpawnTime + delayBeforeFirstBoarSet ) and thisEntity.firstBoar  == true then
		SummonQuillBoar()
		thisEntity.firstBoar  = false
	elseif GameRules:GetGameTime() > ( thisEntity.lastBoarDeath + delayAfterLastBoarDeath ) then
		SummonQuillBoar()
	end
end

--------------------------------------------------------------------------------
function BearCastingTiming(delayBeforeFirstBear, delayAfterBearDeath)
	if GameRules:GetGameTime() > ( thisEntity.beastMasterSpawnTime + delayBeforeFirstBear ) and thisEntity.firstBear == true then
		SummonBear()
		BeastmasterMark()
		thisEntity.firstBear = false
	elseif GameRules:GetGameTime() > ( thisEntity.lastBearDeath + delayAfterBearDeath ) then
		SummonBear()
		BeastmasterMark()
	end 
end

--------------------------------------------------------------------------------
function BreakArmor()

	-- find all players in the entire map
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	if #enemies == 0 then
		return 0.5
	end

	local vTargetPos = enemies[ RandomInt( 1, #enemies ) ]:GetOrigin()

	if vTargetPos ~= nil then
		local fabilityRangeCheck = thisEntity.beastmaster_break:GetCastRange(vTargetPos, nil)
		local fRangeToTarget = ( thisEntity:GetOrigin() - vTargetPos ):Length2D()

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

function BeastmasterMark()

	local bHasModifier = nil

	-- find all players in the entire map
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	if #enemies == 0 then
		return 0.5
	end

	-- select random enemy 
	local hTarget = enemies[ RandomInt( 1, #enemies ) ]

	-- find all friendlies in the entire map
	local friendlies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE , DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	if #friendlies == 0 then
		return 0.5
	end

	-- if BM cd is ready  
	if thisEntity.beastmaster_mark ~= nil and thisEntity.beastmaster_mark:IsCooldownReady() then
		-- search for bear with lust stacks
		for key, friendly in pairs(friendlies) do 
			bHasModifier = friendly:HasModifier("bear_bloodlust_modifier")
			-- set lust stacks to 0
			if friendly:HasModifier("bear_bloodlust_modifier") then
				bearWithBloodlust = friendly
				bearWithBloodlust:SetModifierStackCount("bear_bloodlust_modifier", bearWithBloodlust, 0)
			end

			-- if enemey selected is not nil, cast mark target on target
			if hTarget ~= nil then
				return CastMarkTarget(hTarget)
			end
		end
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

function ChannelStampede()
	print("ChannelStampede()")
	--TELEPORT BM
	--PERFORM CHANNELING ANIMATION
	--NO OTHER ACTIONS WHILE GOING

	
	CastStampede()
end

function CastStampede()
	print("CastStampede()")
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.stampede:entindex(),
		Queue = false,
	})
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
		Queue = 4,
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

--------------------------------------------------------------------------------
function CastChangeToPhase2()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.change_to_phase_2:entindex(),
		Queue = 0,
	})
	return 0.5
end

--------------------------------------------------------------------------------
function CastChangeToPhase1()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.change_to_phase_1:entindex(),
		Queue = 0,
	})
	return 0.5
end

--------------------------------------------------------------------------------
function CastStampede(vTargetPos)

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.stampede:entindex(),
		Queue = true,
	})
	return 0.5
end