m2_direct_heal = class({})
LinkLuaModifier( "m2_direct_heal_modifier_thinker", "player/nocens/modifiers/m2_direct_heal_modifier_thinker", LUA_MODIFIER_MOTION_NONE )

function m2_direct_heal:OnAbilityPhaseStart()
    if IsServer() then

        self.point = nil
        --self.point = Clamp(self:GetCaster():GetOrigin(), Vector(self:GetCaster().mouse.x, self:GetCaster().mouse.y, self:GetCaster().mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)
        self.point = Vector(self:GetCaster().mouse.x, self:GetCaster().mouse.y, self:GetCaster().mouse.z)

        if ( (self:GetCaster():GetAbsOrigin() - self.point):Length2D() ) > self:GetCastRange(Vector(0,0,0), nil) then
            local playerID = self:GetCaster():GetPlayerID()
            local player = PlayerResource:GetPlayer(playerID)
            CustomGameEventManager:Send_ServerToPlayer( player, "out_of_range", { } )
            return false
        end

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.5)
        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        self.caster = self:GetCaster()

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

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

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