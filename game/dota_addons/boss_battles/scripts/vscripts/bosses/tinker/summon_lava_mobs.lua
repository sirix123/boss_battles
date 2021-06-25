
summon_lava_mobs = class({})

function summon_lava_mobs:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end

function summon_lava_mobs:OnSpellStart()
    if IsServer() then

        if FirePuddles ~= nil and FirePuddles ~= 0 then
            for _, v in pairs(FirePuddles) do
                local particle = "particles/units/heroes/hero_invoker_kid/invoker_kid_forge_spirit_death.vpcf"
                self.effect_cast_1 = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self:GetCaster())
                ParticleManager:SetParticleControl(self.effect_cast_1, 0, v)
                ParticleManager:ReleaseParticleIndex(self.effect_cast_1)
            end
        end

        if FirePuddles ~= nil and FirePuddles ~= 0 then
            for _, v in pairs(self.tLocations) do
                CreateUnitByName( "npc_fire_puddle_summon", v, true, nil, nil, DOTA_TEAM_BADGUYS)
            end
        end

    end
end
