r_delayed_aoe_heal = class({})
LinkLuaModifier("r_delayed_aoe_heal_modifier", "player/queenofpain/modifiers/r_delayed_aoe_heal_modifier", LUA_MODIFIER_MOTION_NONE)

function r_delayed_aoe_heal:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1.0)

        return true
    end
end
---------------------------------------------------------------------------

function r_delayed_aoe_heal:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)

    end
end
---------------------------------------------------------------------------

function r_delayed_aoe_heal:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function r_delayed_aoe_heal:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)

        -- init
        self.caster = self:GetCaster()

        local point = nil
        point = Clamp(self.caster:GetOrigin(), Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

        self.modifier = CreateModifierThinker(
            self.caster,
            self,
            "r_delayed_aoe_heal_modifier",
            {
                duration = self:GetSpecialValueFor( "duration" ),
                target_x = point.x,
                target_y = point.y,
                target_z = point.z,
            },
            point,
            self.caster:GetTeamNumber(),
            false
        )

        EmitSoundOnLocationWithCaster(point, "Hero_Bloodseeker.BloodRite.Cast", self.caster)

	end
end
----------------------------------------------------------------------------------------------------------------