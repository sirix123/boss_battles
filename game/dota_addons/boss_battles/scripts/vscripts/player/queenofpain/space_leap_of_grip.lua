space_leap_of_grip = class({})
LinkLuaModifier("space_leap_of_grip_modifier", "player/queenofpain/modifiers/space_leap_of_grip_modifier", LUA_MODIFIER_MOTION_HORIZONTAL)

function space_leap_of_grip:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function space_leap_of_grip:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function space_leap_of_grip:OnSpellStart()
    if IsServer() then
        -- init
        self.caster = self:GetCaster()

        local distance = (self.caster:GetAbsOrigin() - self:GetCursorTarget():GetAbsOrigin()  ):Length2D()
        local speed = 1500

        local duration = (distance/speed) *2

        local info = {
            EffectName = "particles/qop/qop_necro_sullen_pulse_enemy.vpcf",
            Ability = self,
            iMoveSpeed = 1200,
            Source = self:GetCursorTarget(),
            Target = self.caster,
            bDodgeable = false,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bProvidesVision = true,
            iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
            iVisionRadius = 300,
        }

        ProjectileManager:CreateTrackingProjectile( info )

        self:GetCursorTarget():AddNewModifier(
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