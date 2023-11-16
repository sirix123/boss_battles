space_shadowstep_teleport_back = class({})

function space_shadowstep_teleport_back:OnAbilityPhaseStart()
    if IsServer() then


        return true
    end
end
---------------------------------------------------------------------------

function space_shadowstep_teleport_back:OnAbilityPhaseInterrupted()
    if IsServer() then

    end
end
---------------------------------------------------------------------------

function space_shadowstep_teleport_back:OnSpellStart()
    if IsServer() then

        local caster = self:GetCaster()

        local shadows = FindUnitsInRadius(
            caster:GetTeamNumber(),	-- int, your team number
            caster:GetOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if shadows ~= nil or shadows ~= 0 then
            for _, shadow in pairs(shadows) do
                if shadow:GetUnitName() == "npc_shadow" then
                    FindClearSpaceForUnit(caster, shadow:GetAbsOrigin() , true)
                    shadow:RemoveSelf()
                end
            end
        end

        -- add modifier
        if caster:HasModifier("space_shadowstep_caster_modifier") then
            caster:RemoveModifierByName("space_shadowstep_caster_modifier")
        end

        -- Play effects
        local sound_cast = "Hero_PhantomAssassin.Blur"
        EmitSoundOn( sound_cast, caster )

        -- swap to next ability (handled in modifier now)
        caster:SwapAbilities("space_shadowstep_teleport_back", "space_shadowstep", false, true)
    end
end