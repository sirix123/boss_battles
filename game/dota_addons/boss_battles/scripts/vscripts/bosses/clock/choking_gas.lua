choking_gas = class({})
LinkLuaModifier("choking_gas_timer", "bosses/clock/modifiers/choking_gas_timer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("choking_gas_thinker", "bosses/clock/modifiers/choking_gas_thinker", LUA_MODIFIER_MOTION_NONE)

function choking_gas:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.2)

        return true
    end
end
---------------------------------------------------------------------------

function choking_gas:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- init
		local caster = self:GetCaster()
        local origin = caster:GetAbsOrigin()
        self.duration = self:GetSpecialValueFor( "duration_debuff" )

        local enemies = FindUnitsInRadius(
            DOTA_TEAM_BADGUYS,
            origin,
            nil,
            5000,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false )

        if #enemies == 0 then
            return
        end

        local i = RandomInt(1,#enemies)

        -- create gas modifier
        -- this stays on target and creates a gas cloud every x seconds (handled in modifier with a timer)
        if enemies ~= nil then
            enemies[i]:AddNewModifier(caster, self, "choking_gas_timer",
            {
                duration = self.duration
            })
        end

	end
end
----------------------------------------------------------------------------------------------------------------