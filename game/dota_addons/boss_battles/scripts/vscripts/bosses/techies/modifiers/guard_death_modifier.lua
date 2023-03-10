guard_death_modifier = class({})
-----------------------------------------------------------------------------

function guard_death_modifier:RemoveOnDeath()
    return true
end

function guard_death_modifier:OnCreated( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------


function guard_death_modifier:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function guard_death_modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        }
        return funcs
end


function guard_death_modifier:OnDestroy()
    if not IsServer() then return nil end

    EmitGlobalSound("warlock_golem_wargol_wardead_13")

    local units = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),	-- int, your team number
        self:GetParent():GetOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
        DOTA_UNIT_TARGET_ALL,	-- int, type filter
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
        FIND_ANY_ORDER,	-- int, order filter
        false	-- bool, can grow cache
    )

    for _, unit in pairs(units) do
        if unit:GetUnitName() == "npc_techies" then

            unit:RemoveModifierByNameAndCaster("modifier_invulnerable", nil)
            unit:RemoveModifierByNameAndCaster("modifier_phased", nil)

        end

    end

end

