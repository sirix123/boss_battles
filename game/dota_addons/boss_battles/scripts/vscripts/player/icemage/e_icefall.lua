e_icefall = class({})
LinkLuaModifier( "e_icefall_modifier_thinker", "player/icemage/modifiers/e_icefall_modifier_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icefall_freeze_modifier", "player/icemage/modifiers/icefall_freeze_modifier", LUA_MODIFIER_MOTION_NONE )

function e_icefall:OnAbilityPhaseStart()
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

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.0)
        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function e_icefall:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function e_icefall:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function e_icefall:OnSpellStart()

    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

    self.caster = self:GetCaster()

    self.modifier = CreateModifierThinker(
        self.caster,
        self,
        "e_icefall_modifier_thinker",
        {
            duration = self:GetSpecialValueFor( "duration" ),
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