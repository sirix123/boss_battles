
summon_quillboar = class({})

--------------------------------------------------------------------------------

function summon_quillboar:OnSpellStart()
    if IsServer() then

        EmitSoundOn("lone_druid_lone_druid_kill_13", self:GetCaster())

        -- number of cast locations per cast, level up every phase?
        self.number_of_boars = self:GetSpecialValueFor( "number_of_boars" )
        local delay = self:GetSpecialValueFor( "delay_between_boars" )

        -- init
        local caster = self:GetCaster()

        local j = 0
        Timers:CreateTimer(0.5, function()

            if j == self.number_of_boars then
                return false
            end

            -- get spawn vector
            local spawnVector = Vector(RandomInt(-2923,-379),RandomInt(-11142,-8300),256)

            --particle effect start
            local particle_cast = "particles/units/heroes/hero_rattletrap/rattletrap_cog_deploy.vpcf"
            local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(effect_cast, 0, spawnVector)
            ParticleManager:ReleaseParticleIndex(effect_cast)

            CreateUnitByName( "npc_quilboar", spawnVector, true, nil, nil, DOTA_TEAM_BADGUYS)

            j = j  +  1
            return delay
        end)
	end
end

