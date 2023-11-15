space_burrow_v2 = class({})
LinkLuaModifier( "space_burrow_v2_modifier_thinker_first", "player/rat/modifier/space_burrow_v2_modifier_thinker_first", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "space_burrow_v2_modifier_thinker_second", "player/rat/modifier/space_burrow_v2_modifier_thinker_second", LUA_MODIFIER_MOTION_NONE )

function space_burrow_v2:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function space_burrow_v2:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function space_burrow_v2:OnSpellStart()

    self.caster = self:GetCaster()
    self.caster_location_offset = self:GetCaster():GetAbsOrigin() + Vector(1,0,0) * ( self:GetSpecialValueFor( "radius" ) + 80 ) --origin + projectile_direction * offset,
    self.point = self:GetCursorPosition()

    CreateModifierThinker(
        self.caster,
        self,
        "space_burrow_v2_modifier_thinker_first",
        {
            duration = self:GetSpecialValueFor( "duration" ),
            target_x = self.caster_location_offset.x,
            target_y = self.caster_location_offset.y,
            target_z = self.caster_location_offset.z,
            radius = self:GetSpecialValueFor( "radius" ),
            target_x_second = self.point.x,
            target_y_second = self.point.y,
            target_z_second = self.point.z,
            duration_cooldown = self:GetSpecialValueFor( "duration" ),
        },
        self.caster:GetOrigin(),
        self.caster:GetTeamNumber(),
        false
    )

    CreateModifierThinker(
        self.caster,
        self,
        "space_burrow_v2_modifier_thinker_second",
        {
            duration = self:GetSpecialValueFor( "duration" ),
            target_x = self.point.x,
            target_y = self.point.y,
            target_z = self.point.z,
            radius = self:GetSpecialValueFor( "radius" ),
            target_x_first = self.caster_location_offset.x,
            target_y_first = self.caster_location_offset.y,
            target_z_first = self.caster_location_offset.z,
            duration_cooldown = self:GetSpecialValueFor( "duration" ),
        },
        self.caster:GetOrigin(),
        self.caster:GetTeamNumber(),
        false
    )

end
---------------------------------------------------------------------------