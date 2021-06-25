npc_fire_puddle_summon_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity.channel_tinker_buff_lava_mob = thisEntity:FindAbilityByName( "channel_tinker_buff_lava_mob" )

    thisEntity:SetContextThink( "LavaThink", LavaThink, 1.0 )

end
--------------------------------------------------------------------------------

function LavaThink()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
    end

    if thisEntity.channel_tinker_buff_lava_mob ~= nil and thisEntity.channel_tinker_buff_lava_mob:IsFullyCastable() and thisEntity.channel_tinker_buff_lava_mob:IsCooldownReady() and thisEntity.channel_tinker_buff_lava_mob:IsInAbilityPhase() == false and thisEntity.channel_tinker_buff_lava_mob:IsChanneling() == false then

        local friendlies_tinker = FindUnitsInRadius(
            thisEntity:GetTeamNumber(),	-- int, your team number
            thisEntity:GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            10000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
            DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if friendlies_tinker ~= nil and #friendlies_tinker ~= 0 then
            for _, friend in pairs(friendlies_tinker) do
                if friend:GetUnitName() == "npc_tinker" then
                    thisEntity.target = friend
                end
            end
        end

        if thisEntity.target then
            return CastFireEleAttack( thisEntity.target )
        end

    end

	return 0.5
end

function CastFireEleAttack(  target  )

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
        TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.channel_tinker_buff_lava_mob:entindex(),
		Queue = false,
	})

	return 1
end

