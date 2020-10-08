tinker_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity.green_beam = thisEntity:FindAbilityByName( "green_beam" )

    thisEntity:SetContextThink( "CrystalThinker", CrystalThinker, 0.1 )

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

    if thisEntity.green_beam ~= nil and thisEntity.green_beam:IsFullyCastable() and thisEntity.green_beam:IsCooldownReady() then
        return CastGreenBeam()
    end

	return 9999
end
--------------------------------------------------------------------------------

function CastGreenBeam(  )

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.green_beam:entindex(),
        Queue = false,
    })

    return 9999
end
--------------------------------------------------------------------------------