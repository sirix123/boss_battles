
summon_elec_ele = class({})

function summon_elec_ele:OnAbilityPhaseStart()
    if IsServer() then

        -- determine spawn location, ice minions spawn 1 at each location
        local spawn_1 = Entities:FindByName(nil, "tinker_add_spawn_1"):GetAbsOrigin()
        local spawn_2 = Entities:FindByName(nil, "tinker_add_spawn_2"):GetAbsOrigin()
        local spawn_3 = Entities:FindByName(nil, "tinker_add_spawn_3"):GetAbsOrigin()
        local spawn_4 = Entities:FindByName(nil, "tinker_add_spawn_4"):GetAbsOrigin()

        self.tSpawns = {spawn_1, spawn_2, spawn_3, spawn_4}

        self.random_index_1 = RandomInt(1,#self.tSpawns)

        local particle = "particles/tinker/summon_elementals_portal_open_good.vpcf"
        self.effect_cast = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(self.effect_cast, 0, self.tSpawns[self.random_index_1])

        return true
    end
end

function summon_elec_ele:OnSpellStart()
    if IsServer() then

        -- number of cast locations per cast, level up every phase?
        self.run_times = 3
        local delay = 0.1--self:GetSpecialValueFor( "delay" )

        -- init
        local caster = self:GetCaster()

        local j = 1
        Timers:CreateTimer(0.1, function()

            if j == self.run_times then
                return false
            end

            CreateUnitByName( "npc_elec_ele", self.tSpawns[self.random_index_1], true, nil, nil, DOTA_TEAM_BADGUYS)
            CreateUnitByName( "npc_elec_ele", self.tSpawns[self.random_index_1], true, nil, nil, DOTA_TEAM_BADGUYS)
            CreateUnitByName( "npc_elec_ele", self.tSpawns[self.random_index_1], true, nil, nil, DOTA_TEAM_BADGUYS)
            CreateUnitByName( "npc_elec_ele", self.tSpawns[self.random_index_1], true, nil, nil, DOTA_TEAM_BADGUYS)

            j = j + 1
            return delay
        end)

        ParticleManager:DestroyParticle(self.effect_cast,false)

    end
end
