space_shadowstep = class({})
LinkLuaModifier("space_shadowstep_unit_modifier", "player/rogue/modifiers/space_shadowstep_unit_modifier", LUA_MODIFIER_MOTION_NONE)

function space_shadowstep:OnAbilityPhaseStart()
    if IsServer() then

        return true
    end
end
---------------------------------------------------------------------------

function space_shadowstep:OnAbilityPhaseInterrupted()
    if IsServer() then

    end
end
---------------------------------------------------------------------------

function space_shadowstep:OnSpellStart()
    if IsServer() then

        local caster = self:GetCaster()

        local vTargetLocation = self:GetCursorPosition()

        -- create unit at target location
        local unit = CreateUnitByName("npc_shadow", vTargetLocation, true, caster, caster, DOTA_TEAM_NEUTRALS)
        unit:SetOwner(caster)
        unit:EmitSound("Hero_EmberSpirit.FireRemnant.Activate")
        unit:SetRenderColor(255, 255, 255)

        -- add modifier to unit
        caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "space_shadowstep_caster_modifier", -- modifier name
            {
                duration = self:GetSpecialValueFor( "duration" ),
            }
        )

        -- add modifier to unit
        unit:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "space_shadowstep_unit_modifier", -- modifier name
            { duration = self:GetSpecialValueFor( "duration" ) } -- kv
        )

        -- Play effects
        local sound_cast = "Hero_PhantomAssassin.Blur"
        EmitSoundOn( sound_cast, caster )

        -- swap to next ability
        caster:SwapAbilities("space_shadowstep", "space_shadowstep_teleport", false, true)

    end
end