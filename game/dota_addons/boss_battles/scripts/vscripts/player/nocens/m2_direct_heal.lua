m2_direct_heal = class({})
LinkLuaModifier( "m2_direct_heal_modifier_thinker", "player/nocens/modifiers/m2_direct_heal_modifier_thinker", LUA_MODIFIER_MOTION_NONE )

function m2_direct_heal:OnAbilityPhaseStart()
    if IsServer() then

        self.point = nil
        self.point = Vector(self:GetCursorPosition().x, self:GetCursorPosition().y, self:GetCursorPosition().z)

        self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/custom/markercircle/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self.point )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, Vector( self:GetSpecialValueFor( "radius" ), -self:GetSpecialValueFor( "radius" ), -self:GetSpecialValueFor( "radius" ) ) )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, Vector( self:GetCastPoint(), 0, 0 ) );

        return true
    end
end
---------------------------------------------------------------------------

function m2_direct_heal:OnAbilityPhaseInterrupted()
    if IsServer() then
        ParticleManager:DestroyParticle( self.nPreviewFXIndex, false )
    end
end
---------------------------------------------------------------------------

function m2_direct_heal:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function m2_direct_heal:OnSpellStart()

    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

    self.caster = self:GetCaster()

    self.modifier = CreateModifierThinker(
        self.caster,
        self,
        "m2_direct_heal_modifier_thinker",
        {
            duration = self:GetSpecialValueFor( "delay" ),
            radius = self:GetSpecialValueFor( "radius" ),
            target_x = self.point.x,
            target_y = self.point.y,
            target_z = self.point.z,
        },
        self.caster:GetOrigin(),
        self.caster:GetTeamNumber(),
        false
    )

end
---------------------------------------------------------------------------