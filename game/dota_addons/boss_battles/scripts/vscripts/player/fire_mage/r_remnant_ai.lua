r_remnant_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity.beam = thisEntity:FindAbilityByName( "m1_beam_remnant" )
	thisEntity.beam:StartCooldown(2)

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

	if thisEntity.beam:IsFullyCastable() and thisEntity.beam:IsCooldownReady() and thisEntity.beam:IsInAbilityPhase() == false then
        CastBeam( )
    end

    -- in a timer that runs instantly on spawn slight delay 0.3 then every 2-3seconds
    -- find units in beam lenght range
    -- set target as that , need to tracka nd compare current abd prev target
    -- cast beam (need to change beam code to look at who is casting the spell) or create a new spell for this unit might be easier but reference the same kv 

    -- whatever the e spell turns out to be will apply a modifier to all remenats if we have the modifier cast that new spell, then go back to beaming

    -- idle animate while we aren't casting anything



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
