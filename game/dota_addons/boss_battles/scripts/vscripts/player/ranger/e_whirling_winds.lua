e_whirling_winds = class({})
LinkLuaModifier("e_whirling_winds_modifier", "player/ranger/modifiers/e_whirling_winds_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("e_whirling_winds_modifier_thinker", "player/ranger/modifiers/e_whirling_winds_modifier_thinker", LUA_MODIFIER_MOTION_NONE)

function e_whirling_winds:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function e_whirling_winds:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function e_whirling_winds:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function e_whirling_winds:OnSpellStart()

    self.caster = self:GetCaster()

    local point = nil
    point = Clamp(self.caster:GetOrigin(), Vector(self:GetCursorPosition().x, self:GetCursorPosition().y, self:GetCursorPosition().z), self:GetCastRange(Vector(0,0,0), nil), 0)

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "e_whirling_winds_modifier", 
        { 
            duration = self:GetSpecialValueFor( "duration" ),
            dmg_boost_percent =  self:GetSpecialValueFor("dmg_increase"),
            ms_boost = self:GetSpecialValueFor("ms_increase"),
        })

    self.modifier = CreateModifierThinker(
        self.caster,
        self,
        "e_whirling_winds_modifier_thinker",
        {
            duration = self:GetSpecialValueFor( "duration" ),
            target_x = point.x,
            target_y = point.y,
            target_z = point.z,
        },
        self.caster:GetOrigin(),
        self.caster:GetTeamNumber(),
        false
    )

end
---------------------------------------------------------------------------