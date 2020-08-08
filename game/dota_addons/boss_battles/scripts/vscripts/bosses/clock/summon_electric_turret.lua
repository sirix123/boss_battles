summon_electric_turret = class({})

function summon_electric_turret:OnSpellStart()
    if IsServer() then
        -- number of cast locations per cast, level up every phase?
        self.numberOfTurretsToSpawn = self:GetSpecialValueFor( "number_of_turrets_to_spawn" )
        local delay = self:GetSpecialValueFor( "delay_between_turrets_spawning" )

        -- init
        local caster = self:GetCaster()

        -- logic to do the map magic
        -- point 1 top left, point 2 top right, point 3 bot left, point 4 bot right
        local point_1 = Vector(6617,8497,256)
        local point_2 = Vector(10028,8497,256)
        local point_3 = Vector(6617,5575,256)
        local point_4 = Vector(10028,5575,256)

        local tSpawns =
        {
            Vector(7211,7089,256),
            Vector(8305,6165,256),
            Vector(9193,7089,256),
            Vector(8305,7885,256)
        }


        local j = 0
        Timers:CreateTimer(0.5, function()

            if j == self.numberOfTurretsToSpawn then
                return false
            end

            -- get spawn vector
            local randomSpawn = RandomInt(1,#tSpawns)

            --particle effect start
            local particle_cast = "particles/units/heroes/hero_rattletrap/rattletrap_cog_deploy.vpcf"
            local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(effect_cast, 0, tSpawns[randomSpawn])
            ParticleManager:ReleaseParticleIndex(effect_cast)

            --particle effect end

            CreateUnitByName( "electric_turret", tSpawns[randomSpawn], true, nil, nil, DOTA_TEAM_BADGUYS)

            j = j  +  1
            table.remove(tSpawns,randomSpawn)
            return delay
        end)
    end
end

