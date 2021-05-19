r_remnant_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity.beam = thisEntity:FindAbilityByName( "m1_beam_remnant" )
	thisEntity.beam:StartCooldown(1)

	thisEntity.e_fireball_remnant = thisEntity:FindAbilityByName( "e_fireball_remnant" )

    thisEntity:SetContextThink( "RemnantThinker", RemnantThinker, 0.3)

    thisEntity.idleAnimate = true --thisEntity:StartGestureWithPlaybackRate(ACT_DOTA_IDLE, 1.0)

end
--------------------------------------------------------------------------------

function RemnantThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	if thisEntity:HasModifier("cast_fireball_modifier") then
		if thisEntity.e_fireball_remnant:IsFullyCastable() and thisEntity.e_fireball_remnant:IsCooldownReady() and thisEntity.e_fireball_remnant:IsInAbilityPhase() == false then
			CastFireball( )
		end
	end

	if thisEntity.beam:IsFullyCastable() and thisEntity.beam:IsCooldownReady() and thisEntity.beam:IsInAbilityPhase() == false and thisEntity:IsChanneling() == false then
        CastBeam( )
    end

	return 0.3
end
--------------------------------------------------------------------------------

function CastBeam( )

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.beam:entindex(),
		Queue = false,
	})

	return thisEntity.beam:GetChannelTime()
end

function CastFireball( )

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.e_fireball_remnant:entindex(),
		Queue = false,
	})

	return thisEntity.e_fireball_remnant:GetChannelTime()
end

