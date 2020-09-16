LinkLuaModifier("ai_bear", "bosses/beastmaster/ai_bear", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	-- max bears
	thisEntity.BEAST_MASTER_SUMMONED_BEARS = {  }
	thisEntity.MAX_BEARS = 1

	-- abilities this boss has
	thisEntity.beastmaster_mark = thisEntity:FindAbilityByName( "beastmaster_mark" )
	thisEntity.summon_bear = thisEntity:FindAbilityByName( "summon_bear" )

	thisEntity.summon_quillboar = thisEntity:FindAbilityByName( "summon_quillboar" )
	thisEntity.summon_quillboar:StartCooldown(thisEntity.summon_quillboar:GetCooldown(thisEntity.summon_quillboar:GetLevel()))

	thisEntity.beastmaster_net = thisEntity:FindAbilityByName( "beastmaster_net" )
	thisEntity.beastmaster_net:StartCooldown(thisEntity.beastmaster_net:GetCooldown(thisEntity.beastmaster_net:GetLevel()))

	thisEntity.beastmaster_break = thisEntity:FindAbilityByName( "beastmaster_break" )
	thisEntity.beastmaster_break:StartCooldown(thisEntity.beastmaster_break:GetCooldown(thisEntity.beastmaster_break:GetLevel()))

	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 } )

	thisEntity.markTarget = nil

	thisEntity:SetContextThink( "Beastmaster", BeastmasterThink, 0.5 )

	thisEntity:SetHullRadius(60)
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

	if thisEntity.markTarget ~= nil then
		if thisEntity.markTarget:IsAlive() ~= nil and thisEntity.markTarget:IsAlive() ~= true then
			-- target is dead find a new one / end cooddown for mark spell
			thisEntity.beastmaster_mark:EndCooldown()
		end
	end

	if thisEntity.summon_bear:IsFullyCastable() and thisEntity.summon_bear:IsCooldownReady()then
		SummonBear()
	end

	if thisEntity.summon_quillboar:IsFullyCastable() and thisEntity.summon_quillboar:IsCooldownReady() then
		SummonQuillBoar()
	end

	if thisEntity.beastmaster_net:IsFullyCastable() and thisEntity.beastmaster_net:IsCooldownReady() then
		BeastmasterNet()
	end

	if thisEntity.beastmaster_mark:IsFullyCastable() and thisEntity.beastmaster_mark:IsCooldownReady() then
		BeastmasterMark()
	end

	--[[if thisEntity.beastmaster_break:IsFullyCastable() then
		BreakArmor()
	end]]

	ClearAnimals()

	return 0.5
end

--------------------------------------------------------------------------------
function BreakArmor()

	-- find all players in the entire map
	local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetOrigin(),
		nil,
		2500,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false )

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
		end
	end

	return 0.5
end

--------------------------------------------------------------------------------

function SummonBear()

	if #thisEntity.BEAST_MASTER_SUMMONED_BEARS < thisEntity.MAX_BEARS then
		return CastSummonBear()
	end

	return 0.5
end

--------------------------------------------------------------------------------

function SummonQuillBoar()

	return CastSummonQuillboar()
end

------------------------------------------------------------------------------------------------------------

function BeastmasterMark()

	-- find all players in the entire map
	local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetOrigin(),
		nil, 
		4000,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false )

	if #enemies == 0 then
		return 0.5
	end

	thisEntity.markTarget = enemies[ RandomInt( 1, #enemies ) ]

	if thisEntity.markTarget ~= nil then
		return CastMarkTarget(thisEntity.markTarget)
	end

	return 0.5
end

-----------------------------------------------------------------------------------

function BeastmasterNet()

	local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetOrigin(),
		nil,
		5000,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false )

	if #enemies == 0 then
		return 0.5
	end

	local vTargetPos = nil
	local tTargets = {}

	for _, enemy in pairs(enemies) do
		local dist = ( thisEntity:GetAbsOrigin() - enemy:GetAbsOrigin() ):Length2D()
		if dist > 400 then
			table.insert(tTargets,enemy)
		end
	end

	if tTargets ~= nil and #tTargets ~= 0 then
		vTargetPos = tTargets[RandomInt(1,#tTargets)]:GetAbsOrigin()
	else
		return 0.5
	end

	if vTargetPos ~= nil then
		return CastLaunchNet( vTargetPos )
	else
		return 0.5
	end

	return 0.5
end

---------------------------------------------------------------------------------

function CastSummonBear()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.summon_bear:entindex(),
		Queue = false,
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
		Queue = false,
	})
	return 0.5
end