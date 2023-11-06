r_delayed_aoe_heal = class({})
LinkLuaModifier("r_delayed_aoe_heal_modifier", "player/queenofpain/modifiers/r_delayed_aoe_heal_modifier", LUA_MODIFIER_MOTION_NONE)

function r_delayed_aoe_heal:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function r_delayed_aoe_heal:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function r_delayed_aoe_heal:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function r_delayed_aoe_heal:OnSpellStart()
    if IsServer() then
        -- init
        self.caster = self:GetCaster()

        self.modifier = CreateModifierThinker(
            self.caster,
            self,
            "r_delayed_aoe_heal_modifier",
            {
                duration = self:GetSpecialValueFor( "duration" ),
                target_x = self:GetCursorPosition().x,
                target_y = self:GetCursorPosition().y,
                target_z = self:GetCursorPosition().z,
            },
            self:GetCursorPosition(),
            self.caster:GetTeamNumber(),
            false
        )

        EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Hero_Bloodseeker.BloodRite.Cast", self.caster)

	end
end
----------------------------------------------------------------------------------------------------------------