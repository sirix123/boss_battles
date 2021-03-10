r_blade_vortex = class({})
LinkLuaModifier( "r_blade_vortex_thinker", "player/warlord/modifiers/r_blade_vortex_thinker", LUA_MODIFIER_MOTION_NONE )

function r_blade_vortex:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function r_blade_vortex:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function r_blade_vortex:OnSpellStart()
    if IsServer() then

        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        local caster = self:GetCaster()
        self.radius = self:GetSpecialValueFor("radius")

        local vTargetPos = nil
        vTargetPos = Clamp(caster:GetOrigin(), Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

        -- sound effect
        caster:EmitSound("Hero_Juggernaut.HealingWard.Cast")

        CreateModifierThinker(
            caster,
            self,
            "r_blade_vortex_thinker",
            {
                duration = self:GetSpecialValueFor( "duration" ),
                target_x = vTargetPos.x,
                target_y = vTargetPos.y,
                target_z = vTargetPos.z,
            },
            vTargetPos,
            caster:GetTeamNumber(),
            false
        )

    end
end
---------------------------------------------------------------------------

