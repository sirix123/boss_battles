tinker_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity.green_beam = thisEntity:FindAbilityByName( "green_beam" )
    thisEntity.spawn_rocks = thisEntity:FindAbilityByName( "spawn_rocks" )
    thisEntity.electric_field = thisEntity:FindAbilityByName( "electric_field" )

    thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )

    thisEntity:SetContextThink( "CrystalThinker", CrystalThinker, 0.1 )
    

    -- during an activation phase particles/units/heroes/hero_rubick/rubick_golem_ambient.vpcf use this particle

end
--------------------------------------------------------------------------------

function CrystalThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
    end

    if thisEntity.electric_field ~= nil and thisEntity.electric_field:IsFullyCastable() and thisEntity.electric_field:IsCooldownReady() then
        --thisEntity:RemoveModifierByName("cast_electric_field") and thisEntity:HasModifier("cast_electric_field")
        return CastElectricField()
    end

    if thisEntity.green_beam ~= nil and thisEntity.green_beam:IsFullyCastable() and thisEntity.green_beam:IsCooldownReady() then
        --return CastGreenBeam()
    end

    if thisEntity.spawn_rocks ~= nil and thisEntity.spawn_rocks:IsFullyCastable() and thisEntity.spawn_rocks:IsCooldownReady() then
        --return SpawnRocks()
    end

	return 0.5
end
--------------------------------------------------------------------------------

function CastGreenBeam(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.green_beam:entindex(),
        Queue = false,
    })
    return 1
end
--------------------------------------------------------------------------------

function SpawnRocks(  )
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.spawn_rocks:entindex(),
        Queue = false,
    })
    return 1
end
--------------------------------------------------------------------------------

function CastElectricField(  )
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.electric_field:entindex(),
        Queue = false,
    })
    return 1
end
--------------------------------------------------------------------------------

