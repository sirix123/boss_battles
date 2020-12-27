summon_furnace_droid = class({})

function summon_furnace_droid:OnSpellStart()
    if IsServer() then
        -- number of cast locations per cast, level up every phase?
        self.numberOfDroidsToSpawn = self:GetSpecialValueFor( "numberOfDroidsToSpawn" )
        local delay = self:GetSpecialValueFor( "delay" )

        -- init
        local caster = self:GetCaster()
        local origin = caster:GetAbsOrigin()

        local j = 0
        Timers:CreateTimer(0.5, function()

            if j == self.numberOfDroidsToSpawn then
                return false
            end

            -- get spawn vector
            local spawnVector = origin

            -- sound and particel effect for spawn
            local particle = "particles/econ/items/zeus/arcana_chariot/zeus_arcana_electricimage_ring.vpcf"
            local nfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
            ParticleManager:SetParticleControl(nfx, 0, origin)
            ParticleManager:ReleaseParticleIndex(nfx)

            EmitSoundOn("Hero_Rattletrap.Battery_Assault_Launch", caster)


            CreateUnitByName( "furnace_droid", spawnVector, true, nil, nil, DOTA_TEAM_BADGUYS)

            j = j  +  1
            return delay
        end)
    end
end

