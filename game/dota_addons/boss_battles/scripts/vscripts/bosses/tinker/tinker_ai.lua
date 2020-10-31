tinker_ai = class({})

LinkLuaModifier("shield_effect", "bosses/tinker/modifiers/shield_effect", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

	CreateUnitByName( "npc_crystal", Vector(-10673,11950,0), true, thisEntity, thisEntity, DOTA_TEAM_BADGUYS)

	thisEntity:AddNewModifier( nil, nil, "shield_effect", { duration = -1 } )
	thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 } )

	thisEntity.PHASE = 1
	thisEntity.stack_count = 0

	thisEntity.chain_light_v2 = thisEntity:FindAbilityByName( "chain_light_v2" )
	thisEntity.chain_light_v2:StartCooldown(thisEntity.chain_light_v2:GetCooldown(thisEntity.chain_light_v2:GetLevel()))

	thisEntity.ice_shot_tinker = thisEntity:FindAbilityByName( "ice_shot_tinker" )
	thisEntity.ice_shot_tinker:StartCooldown(thisEntity.ice_shot_tinker:GetCooldown(thisEntity.ice_shot_tinker:GetLevel()))

	thisEntity.summon_bird = thisEntity:FindAbilityByName( "summon_bird" )
	--thisEntity.summon_bird:StartCooldown(thisEntity.summon_bird:GetCooldown(thisEntity.summon_bird:GetLevel()))

	thisEntity.tinker_teleport = thisEntity:FindAbilityByName( "tinker_teleport" )
	thisEntity.tinker_teleport:StartCooldown(thisEntity.tinker_teleport:GetCooldown(thisEntity.tinker_teleport:GetLevel()))

    thisEntity:SetContextThink( "TinkerThinker", TinkerThinker, 0.1 )

end
--------------------------------------------------------------------------------

function TinkerThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	--print("tinker thisEntity.PHASE ", thisEntity.PHASE)

	-- handles the phase changes etc
	if thisEntity:HasModifier("beam_counter") then
		thisEntity.stack_count = thisEntity:FindModifierByName("beam_counter"):GetStackCount()
		--print("stack_count ", thisEntity.stack_count)
	end

	-- if this unit has the beam phase modiifier then phase == 2
	if thisEntity:HasModifier("beam_phase") then
		thisEntity.PHASE = 2
	else
		thisEntity.PHASE = 1
	end

	if thisEntity.stack_count == 5 then
		thisEntity:RemoveModifierByName("shield_effect")
		thisEntity.PHASE = 3
	end

	-- phase 1
	if thisEntity.PHASE == 1 then
		if thisEntity.tinker_teleport ~= nil and thisEntity.tinker_teleport:IsFullyCastable() and thisEntity.tinker_teleport:IsCooldownReady() then
			--return CastTeleport()
		end

		if thisEntity.chain_light_v2 ~= nil and thisEntity.chain_light_v2:IsFullyCastable() and thisEntity.chain_light_v2:IsCooldownReady() then
			return CastChainLight()
		end

		if thisEntity.ice_shot_tinker ~= nil and thisEntity.ice_shot_tinker:IsFullyCastable() and thisEntity.ice_shot_tinker:IsCooldownReady() then
			--return CastIceShot()
		end

		if thisEntity.summon_bird ~= nil and thisEntity.summon_bird:IsFullyCastable() and thisEntity.summon_bird:IsCooldownReady() then
			--return CastSummonBird()
		end

	end

	-- crystal phase
	if thisEntity.PHASE == 2 then
		if thisEntity.tinker_teleport ~= nil and thisEntity.tinker_teleport:IsFullyCastable() and thisEntity.tinker_teleport:IsCooldownReady() then
			return CastTeleport()
		end
	end

	-- phase 2
	if thisEntity.PHASE == 2 then

	end

	return 0.5
end
--------------------------------------------------------------------------------

function CastTeleport(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.tinker_teleport:entindex(),
        Queue = false,
    })
    return 1
end
--------------------------------------------------------------------------------

function CastChainLight(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.chain_light_v2:entindex(),
        Queue = false,
    })
    return 1
end
--------------------------------------------------------------------------------

function CastIceShot(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.ice_shot_tinker:entindex(),
        Queue = false,
    })
    return 1
end
--------------------------------------------------------------------------------

function CastSummonBird(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.summon_bird:entindex(),
        Queue = false,
    })
    return 1
end
--------------------------------------------------------------------------------

