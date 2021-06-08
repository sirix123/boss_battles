space_leap_of_grip = class({})
LinkLuaModifier("space_leap_of_grip_modifier", "player/queenofpain/modifiers/space_leap_of_grip_modifier", LUA_MODIFIER_MOTION_HORIZONTAL)

function space_leap_of_grip:OnAbilityPhaseStart()
    if IsServer() then

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            Clamp(self:GetCaster():GetOrigin(), Vector(self:GetCaster().mouse.x, self:GetCaster().mouse.y, self:GetCaster().mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0),
            nil,
            200,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_CLOSEST,
            false)

        if units == nil or #units == 0 then
            local playerID = self:GetCaster():GetPlayerID()
            local player = PlayerResource:GetPlayer(playerID)
            CustomGameEventManager:Send_ServerToPlayer( player, "no_target", { } )
            return false
        else
            self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1.0)
            self.target = units[1]
            return true
        end
    end
end
---------------------------------------------------------------------------

function space_leap_of_grip:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)

    end
end
---------------------------------------------------------------------------

function space_leap_of_grip:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)

        -- init
        self.caster = self:GetCaster()

        local distance = (self.caster:GetAbsOrigin() - self.target:GetAbsOrigin()  ):Length2D()
        local speed = 1500

        local duration = (distance/speed) *2

        local info = {
            EffectName = "particles/qop/qop_necro_sullen_pulse_enemy.vpcf",
            Ability = self,
            iMoveSpeed = 1200,
            Source = self.target,
            Target = self.caster,
            bDodgeable = false,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bProvidesVision = true,
            iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
            iVisionRadius = 300,
        }

        ProjectileManager:CreateTrackingProjectile( info )

        self.target:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "space_leap_of_grip_modifier", -- modifier name
            {
                duration = duration,
                speed = speed,
            } -- kv
        )

	end
end
----------------------------------------------------------------------------------------------------------------