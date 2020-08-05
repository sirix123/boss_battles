assistant_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

	thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )

    thisEntity.furnace_master_grab_throw = thisEntity:FindAbilityByName( "furnace_master_grab_throw" )
	thisEntity.furnace_master_throw = thisEntity:FindAbilityByName( "furnace_master_throw" )

    thisEntity.flThrowTimer = 0.0 -- set externally in throw/grab modifiers
    thisEntity.fEnemySearchRange = 10000

    thisEntity:SetContextThink( "AssistantThink", AssistantThink, 0.1 )

end
--------------------------------------------------------------------------------

function AssistantThink()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

    local enemies = FindUnitsInRadius(
        thisEntity:GetTeamNumber(),
        thisEntity:GetOrigin(),
        nil,
        thisEntity.fEnemySearchRange,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_CLOSEST,
        false
    )

    if #enemies == 0 then -- if 1 player alive and he is gripped this will return gripped enemies are not found
		return 0.1
    end

    local hNearestEnemy = enemies[ 1 ]

    local hGrabbedEnemyBuff = thisEntity:FindModifierByName( "furnace_master_grabbed_buff" )
    local hGrabbedTarget = nil

    if hGrabbedEnemyBuff == nil then
        if thisEntity.furnace_master_grab_throw ~= nil and thisEntity.furnace_master_grab_throw:IsFullyCastable() then
			if hNearestEnemy ~= nil then
				--print( "Grab the nearest enemy ", hNearestEnemy:GetUnitName() )
                return CastGrab( hNearestEnemy )
            end
		end
	else
		-- Note: hThrowObject and flThrowTimer are both set by the modifier
        local hGrabbedTarget = hGrabbedEnemyBuff.hThrowObject -- set externally in throw/grab modifiers
        --print("hGrabbedTarget",hGrabbedTarget:GetUnitName())
		if GameRules:GetGameTime() > thisEntity.flThrowTimer and hGrabbedTarget ~= nil then
			if thisEntity.furnace_master_throw ~= nil and thisEntity.furnace_master_throw:IsFullyCastable() then
                return CastThrow( )
			end
		end
	end

	return 5
end

--------------------------------------------------------------------------------

function CastGrab( enemy )
	if enemy == nil or enemy:IsAlive() == false then
		return 0.1
	end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = enemy:entindex(),
		AbilityIndex = thisEntity.furnace_master_grab_throw:entindex(),
	})

	return 0.5
end

--------------------------------------------------------------------------------

function CastThrow(  )

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.furnace_master_throw:entindex(),
		Queue = false,
	})

	return 5
end
