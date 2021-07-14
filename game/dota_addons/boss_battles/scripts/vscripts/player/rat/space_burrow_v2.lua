space_burrow_v2 = class({})
LinkLuaModifier( "space_burrow_v2_modifier_thinker_first", "player/rat/modifier/space_burrow_v2_modifier_thinker_first", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "space_burrow_v2_modifier_thinker_second", "player/rat/modifier/space_burrow_v2_modifier_thinker_second", LUA_MODIFIER_MOTION_NONE )

function space_burrow_v2:OnAbilityPhaseStart()
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

function space_burrow_v2:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function space_burrow_v2:OnSpellStart()

    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

    self.caster = self:GetCaster()
    self.caster_location_offset = self:GetCaster():GetAbsOrigin() + Vector(1,0,0) * ( self:GetSpecialValueFor( "radius" ) + 80 ) --origin + projectile_direction * offset,

    --DebugDrawCircle(center: Vector, rgb: Vector, a: float, rad: float, ztest: bool, duration: float): nil

    --DebugDrawCircle(self.caster_location_offset,Vector(255,0,0),128,self:GetSpecialValueFor( "radius" ),true,60)

    --DebugDrawCircle(self.point,Vector(255,0,0),128,self:GetSpecialValueFor( "radius" ),true,60)

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
            duration_cooldown = self:GetSpecialValueFor( "duration_cooldown" ),
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
            duration_cooldown = self:GetSpecialValueFor( "duration_cooldown" ),
        },
        self.caster:GetOrigin(),
        self.caster:GetTeamNumber(),
        false
    )

end
---------------------------------------------------------------------------