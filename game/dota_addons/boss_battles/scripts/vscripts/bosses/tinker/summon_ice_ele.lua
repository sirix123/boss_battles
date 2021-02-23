
summon_ice_ele = class({})

function summon_ice_ele:OnAbilityPhaseStart()
    if IsServer() then

        local particle = "particles/tinker/summon_elementals_portal_open_good.vpcf"
        self.effect_cast_1 = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(self.effect_cast_1, 0, Entities:FindByName(nil, "tinker_add_spawn_1"):GetAbsOrigin())

        self.effect_cast_2 = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(self.effect_cast_2, 0, Entities:FindByName(nil, "tinker_add_spawn_2"):GetAbsOrigin())

        self.effect_cast_3 = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(self.effect_cast_3, 0, Entities:FindByName(nil, "tinker_add_spawn_3"):GetAbsOrigin())

        self.effect_cast_4 = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(self.effect_cast_4, 0, Entities:FindByName(nil, "tinker_add_spawn_4"):GetAbsOrigin())

        return true
    end
end

function summon_ice_ele:OnSpellStart()
    if IsServer() then
        -- number of cast locations per cast, level up every phase?
        self.numEle = 2
        local delay = 0.1--self:GetSpecialValueFor( "delay" )

        -- init
        local caster = self:GetCaster()

        -- determine spawn location, ice minions spawn 1 at each location
        local spawn_1 = Entities:FindByName(nil, "tinker_add_spawn_1"):GetAbsOrigin()
        local spawn_2 = Entities:FindByName(nil, "tinker_add_spawn_2"):GetAbsOrigin()
        local spawn_3 = Entities:FindByName(nil, "tinker_add_spawn_3"):GetAbsOrigin()
        local spawn_4 = Entities:FindByName(nil, "tinker_add_spawn_4"):GetAbsOrigin()

        self.tSpawns = {spawn_1, spawn_2, spawn_3, spawn_4}
        --print("self.tSpawns ",self.tSpawns[1])

        local j = 1
        Timers:CreateTimer(0.1, function()

            if j > self.numEle then
                return false
            end

            CreateUnitByName( "npc_ice_ele", self.tSpawns[j], true, nil, nil, DOTA_TEAM_BADGUYS)

            j = j  +  1
            return delay
        end)

        ParticleManager:DestroyParticle(self.effect_cast_1,false)
        ParticleManager:DestroyParticle(self.effect_cast_2,false)
        ParticleManager:DestroyParticle(self.effect_cast_3,false)
        ParticleManager:DestroyParticle(self.effect_cast_4,false)

    end
end
