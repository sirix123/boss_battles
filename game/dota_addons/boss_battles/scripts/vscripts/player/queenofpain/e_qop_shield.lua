e_qop_shield = class({})
LinkLuaModifier("e_qop_shield_modifier", "player/queenofpain/modifiers/e_qop_shield_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("e_qop_shield_modifier_enemy", "player/queenofpain/modifiers/e_qop_shield_modifier_enemy", LUA_MODIFIER_MOTION_NONE)

function e_qop_shield:OnAbilityPhaseStart()
    if IsServer() then

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
            --FireGameEvent("dota_hud_error_message", { reason = 80, message = "Out of range or no target" })
            return false
        else
            self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1.0)
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

        --local duration = self:GetSpecialValueFor( "duration" )
        local ally_duration = self:GetSpecialValueFor( "ally_duration" )    --1
        local enemy_duration = self:GetSpecialValueFor( "enemy_duration" )  --1

        local ally_cooldown = self:GetSpecialValueFor( "ally_cooldown" )    --1
        local enemy_cooldown = self:GetSpecialValueFor( "enemy_cooldown" )  --2

        local modifier = "m2_qop_stacks"
        local stacks = 0
        if self.caster:HasModifier(modifier) then
            stacks = self.caster:GetModifierStackCount(modifier, self.caster)
        end

        if stacks == 0 then

            ally_duration = ally_duration
            enemy_duration = enemy_duration

            ally_cooldown = ally_cooldown
            enemy_cooldown = enemy_cooldown

        elseif stacks == 1 then

            ally_duration = ally_duration       *   2
            enemy_duration = enemy_duration     *   2

            ally_cooldown = ally_cooldown       *   2
            enemy_cooldown = enemy_cooldown     *   2

        elseif stacks == 2 then

            ally_duration = ally_duration       *   4
            enemy_duration = enemy_duration     *   4

            ally_cooldown = ally_cooldown       *   4
            enemy_cooldown = enemy_cooldown     *   4

        elseif stacks == 3 then

            ally_duration = ally_duration       *   8
            enemy_duration = enemy_duration     *   8

            ally_cooldown = ally_cooldown       *   8
            enemy_cooldown = enemy_cooldown     *   8

        end

        if self.target:GetTeam() == DOTA_TEAM_GOODGUYS then
            self.target:AddNewModifier(
                self.caster, -- player source
                self, -- ability source
                "e_qop_shield_modifier", -- modifier name
                { duration = ally_duration } -- kv
            )

            self:StartCooldown(ally_cooldown)

        elseif self.target:GetTeam() == DOTA_TEAM_BADGUYS then
            self.target:AddNewModifier(
                self.caster, -- player source
                self, -- ability source
                "e_qop_shield_modifier_enemy", -- modifier name
                { duration = enemy_duration } -- kv
            )

            self:StartCooldown(enemy_cooldown)

        end
	end
end
----------------------------------------------------------------------------------------------------------------