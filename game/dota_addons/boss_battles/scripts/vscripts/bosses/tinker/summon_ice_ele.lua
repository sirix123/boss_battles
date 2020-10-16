
summon_ice_ele = class({})

function summon_ice_ele:OnSpellStart()
    if IsServer() then
        -- number of cast locations per cast, level up every phase?
        self.numEle = 4
        local delay = 0.1--self:GetSpecialValueFor( "delay" )

        -- init
        local caster = self:GetCaster()

        -- determine spawn location, ice minions spawn 1 at each location
        local spawn_1 = Entities:FindByName(nil, "tinker_add_spawn_1"):GetAbsOrigin()
        local spawn_2 = Entities:FindByName(nil, "tinker_add_spawn_2"):GetAbsOrigin()
        local spawn_3 = Entities:FindByName(nil, "tinker_add_spawn_3"):GetAbsOrigin()
        local spawn_4 = Entities:FindByName(nil, "tinker_add_spawn_4"):GetAbsOrigin()

        local tSpawns = {spawn_1, spawn_2, spawn_3, spawn_4}

        local j = 0
        Timers:CreateTimer(0.1, function()

            if j == self.numEle then
                return false
            end

            CreateUnitByName( "npc_ice_ele", tSpawns[i], true, nil, nil, DOTA_TEAM_BADGUYS)

            j = j  +  1
            return delay
        end)
    end
end
