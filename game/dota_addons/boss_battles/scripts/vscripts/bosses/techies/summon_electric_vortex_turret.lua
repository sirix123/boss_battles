
summon_electric_vortex_turret = class({})

--[[function summon_electric_vortex_turret:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        return true
    end
end]]
---------------------------------------------------------------------------------------------------------------------------------------

function summon_electric_vortex_turret:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()

        local delay = 0.1
        local point = Vector(0,0,0)
        local max_turrets = 1

        -- find a random point inside the map arena
        local vTargetPos = Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z) -- for testing
        --local vTargetPos = Vector(Rand)

        local i = 0
        Timers:CreateTimer(delay, function()

            if i == max_turrets then
                return false
            end

            CreateUnitByName("npc_electric_vortex_turret", vTargetPos, true, self:GetCaster(), self:GetCaster():GetOwner(), caster:GetTeamNumber())

            i = i  +  1
            return delay
        end)
    end
end