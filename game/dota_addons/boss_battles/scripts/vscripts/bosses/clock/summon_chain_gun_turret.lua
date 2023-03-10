summon_chain_gun_turret = class({})

function summon_chain_gun_turret:OnSpellStart()
    if IsServer() then
        -- number of cast locations per cast, level up every phase?
        self.numberOfTurretsToSpawn = self:GetSpecialValueFor( "number_of_turrets_to_spawn" )
        local delay = self:GetSpecialValueFor( "delay_between_turrets_spawning" )

        -- init
        local caster = self:GetCaster()

        -- logic to do the map magic
        -- point 1 top left, point 2 top right, point 3 bot left, point 4 bot right
        local point_1 = Vector(-3717,3010,162)
        local point_2 = Vector(-810,3010,256)
        local point_3 = Vector(-3717,212,256)
        local point_4 = Vector(-810,212,256)

        local j = 0
        Timers:CreateTimer(0.5, function()

            if j == self.numberOfTurretsToSpawn then
                return false
            end

            -- get spawn vector
            local spawnVector = Vector(RandomInt(-3717,-810),RandomInt(212,3010),256)

            --particle effect start
            local particle_cast = "particles/units/heroes/hero_rattletrap/rattletrap_cog_deploy.vpcf"
            local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(effect_cast, 0, spawnVector)
            ParticleManager:ReleaseParticleIndex(effect_cast)

            -- sound effect
            local sound_cast = "Hero_Rattletrap.Power_Cogs"
            EmitSoundOn(sound_cast,self:GetCaster())

            CreateUnitByName( "npc_chain_gun_turret", spawnVector, true, nil, nil, DOTA_TEAM_BADGUYS)

            j = j  +  1
            return delay
        end)
    end
end

