e_qop_shield = class({})
LinkLuaModifier("e_qop_shield_modifier", "player/queenofpain/modifiers/e_qop_shield_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("e_qop_shield_modifier_enemy", "player/queenofpain/modifiers/e_qop_shield_modifier_enemy", LUA_MODIFIER_MOTION_NONE)

function e_qop_shield:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1.0)

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            Clamp(self:GetCaster():GetOrigin(), Vector(self:GetCaster().mouse.x, self:GetCaster().mouse.y, self:GetCaster().mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0),
            nil,
            200,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_CLOSEST,
            false)

        if units == nil or #units == 0 then
            return false
        else

            self.target = units[1]

            return true
        end
    end
end
---------------------------------------------------------------------------

function e_qop_shield:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)

    end
end
---------------------------------------------------------------------------

function e_qop_shield:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)

        -- init
        self.caster = self:GetCaster()

        local duration = self:GetSpecialValueFor( "duration" )

        if self.target:GetTeam() == DOTA_TEAM_GOODGUYS then
            self.target:AddNewModifier(
                self.caster, -- player source
                self, -- ability source
                "e_qop_shield_modifier", -- modifier name
                { duration = duration } -- kv
            )

        elseif self.target:GetTeam() == DOTA_TEAM_BADGUYS then
            self.target:AddNewModifier(
                self.caster, -- player source
                self, -- ability source
                "e_qop_shield_modifier_enemy", -- modifier name
                { duration = duration } -- kv
            )

            self:StartCooldown(self:GetSpecialValueFor( "enemy_cooldown" ))

        end
	end
end
----------------------------------------------------------------------------------------------------------------