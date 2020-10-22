encaserocks_death_modifier = class({})
-----------------------------------------------------------------------------

function encaserocks_death_modifier:RemoveOnDeath()
    return true
end

function encaserocks_death_modifier:OnCreated( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------


function encaserocks_death_modifier:OnRefresh( kv )
	if IsServer() then

    end
end
----------------------------------------------------------------------------

function encaserocks_death_modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        }
        return funcs
end


function encaserocks_death_modifier:OnDeath(params)
    if not IsServer() then return nil end
    if params.unit ~= self:GetParent() then return nil end

    --print("ive died and im running this code")

    local units = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(),	-- int, your team number
        self:GetParent():GetAbsOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        50,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
        DOTA_UNIT_TARGET_ALL,	-- int, type filter
        DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
        FIND_ANY_ORDER,	-- int, order filter
        false	-- bool, can grow cache
    )

    for _, unit in pairs(units) do
        --print("unit:GetUnitName() ",unit:GetUnitName())
        if unit:HasModifier("fire_ele_encase_rocks_debuff") == true then
            --print("revmoing rooted")
            unit:RemoveModifierByName("modifier_rooted")
            unit:RemoveModifierByName("fire_ele_encase_rocks_debuff")
        end
    end
end

