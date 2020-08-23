space_shadowstep = class({})
LinkLuaModifier("space_shadowstep_unit_modifier", "player/rogue/modifiers/space_shadowstep_unit_modifier", LUA_MODIFIER_MOTION_NONE)

function space_shadowstep:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            pMovespeedReduction = -80,
        })

        return true
    end
end
---------------------------------------------------------------------------

function space_shadowstep:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function space_shadowstep:OnSpellStart()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)

        local caster = self:GetCaster()

        local vTargetLocation = Clamp(caster:GetOrigin(), Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

        -- create unit at target location
        local unit = CreateUnitByName("npc_shadow", vTargetLocation, true, caster, caster, caster:GetTeamNumber())
        unit:SetOwner(caster)
        unit:EmitSound("Hero_EmberSpirit.FireRemnant.Activate")
        unit:SetRenderColor(255, 255, 255)

        -- add modifier to unit
        unit:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "space_shadowstep_unit_modifier", -- modifier name
            { } -- kv
        )

        -- Play effects
        local sound_cast = "Hero_PhantomAssassin.Blur"
        EmitSoundOn( sound_cast, caster )

        -- swap to next ability
        caster:SwapAbilities("space_shadowstep", "space_shadowstep_teleport", false, true)

    end
end