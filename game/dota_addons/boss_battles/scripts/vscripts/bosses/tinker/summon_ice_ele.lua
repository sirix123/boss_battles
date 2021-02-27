
summon_ice_ele = class({})

function summon_ice_ele:OnAbilityPhaseStart()
    if IsServer() then
        self.numEle = 2
        self.tLocations = {}

        local particle = "particles/tinker/summon_elementals_portal_open_good.vpcf"

        local spawn_1 = Entities:FindByName(nil, "tinker_add_spawn_1"):GetAbsOrigin()
        local spawn_2 = Entities:FindByName(nil, "tinker_add_spawn_2"):GetAbsOrigin()
        local spawn_3 = Entities:FindByName(nil, "tinker_add_spawn_3"):GetAbsOrigin()
        local spawn_4 = Entities:FindByName(nil, "tinker_add_spawn_4"):GetAbsOrigin()

        self.tLocations = {
            spawn_1,
            spawn_2,
            spawn_3,
            spawn_4,
        }

        local remove_spawns = 2

        while remove_spawns > 0 do
            local i = RandomInt(1,#self.tLocations)
            self.tLocations[i] = nil
            remove_spawns = remove_spawns - 1
        end

        for _, v in pairs(self.tLocations) do
            self.effect_cast_1 = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self:GetCaster())
            ParticleManager:SetParticleControl(self.effect_cast_1, 0, v)
            ParticleManager:ReleaseParticleIndex(self.effect_cast_1)
        end

        return true
    end
end

function summon_ice_ele:OnSpellStart()
    if IsServer() then

        for _, v in pairs(self.tLocations) do
            --print("v ",v)
            CreateUnitByName( "npc_ice_ele", v, true, nil, nil, DOTA_TEAM_BADGUYS)
        end

    end
end
