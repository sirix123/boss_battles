e_qop_shield = class({})
LinkLuaModifier("e_qop_shield_modifier", "player/queenofpain/modifiers/e_qop_shield_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("e_qop_shield_modifier_enemy", "player/queenofpain/modifiers/e_qop_shield_modifier_enemy", LUA_MODIFIER_MOTION_NONE)

function e_qop_shield:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function e_qop_shield:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function e_qop_shield:OnSpellStart()
    if IsServer() then
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

        if self:GetCursorTarget():GetTeam() == DOTA_TEAM_GOODGUYS then
            self:GetCursorTarget():AddNewModifier(
                self.caster, -- player source
                self, -- ability source
                "e_qop_shield_modifier", -- modifier name
                { duration = ally_duration } -- kv
            )

            self:StartCooldown(ally_cooldown)

        elseif self:GetCursorTarget():GetTeam() == DOTA_TEAM_BADGUYS then
            self:GetCursorTarget():AddNewModifier(
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