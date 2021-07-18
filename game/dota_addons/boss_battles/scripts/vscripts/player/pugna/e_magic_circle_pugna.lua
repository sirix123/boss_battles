e_magic_circle_pugna = class({})
LinkLuaModifier("e_magic_circle_modifier", "player/pugna/modifiers/e_magic_circle_modifier", LUA_MODIFIER_MOTION_NONE)

function e_magic_circle_pugna:OnAbilityPhaseStart()
    if IsServer() then

        self.point = nil
        self.point = Clamp(self:GetCaster():GetOrigin(), Vector(self:GetCaster().mouse.x, self:GetCaster().mouse.y, self:GetCaster().mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)
        --self.point = Vector(self:GetCaster().mouse.x, self:GetCaster().mouse.y, self:GetCaster().mouse.z)

        if ( (self:GetCaster():GetAbsOrigin() - self.point):Length2D() ) > self:GetCastRange(Vector(0,0,0), nil) then
            local playerID = self:GetCaster():GetPlayerID()
            local player = PlayerResource:GetPlayer(playerID)
            CustomGameEventManager:Send_ServerToPlayer( player, "out_of_range", { } )
            return false
        end

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1.0)

        return true
    end
end
---------------------------------------------------------------------------

function e_magic_circle_pugna:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_3)

    end
end
---------------------------------------------------------------------------

function e_magic_circle_pugna:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_3)

        -- init
        self.caster = self:GetCaster()

        CreateModifierThinker(
            self.caster,
            self,
            "e_magic_circle_modifier",
            {
                duration = self:GetSpecialValueFor( "duration" ),
                target_x = self.point.x,
                target_y = self.point.y,
                target_z = self.point.z,
            },
            self.point,
            self.caster:GetTeamNumber(),
            false
        )

        EmitSoundOnLocationWithCaster(self.point, "Hero_Pugna.NetherBlastPreCast", self.caster)

	end
end
----------------------------------------------------------------------------------------------------------------