summon_bird = class({})

function summon_bird:OnSpellStart()
    if IsServer() then
        -- number of cast locations per cast, level up every phase?
        self.numBirds = 3
        local delay = 0.1--self:GetSpecialValueFor( "delay" )

        -- init
        local caster = self:GetCaster()
        local origin = caster:GetAbsOrigin()

        local j = 0
        Timers:CreateTimer(0.1, function()

            if j == self.numBirds then
                return false
            end

            -- get spawn vector
            local spawnVector = origin

            CreateUnitByName( "npc_bird", spawnVector, true, nil, nil, DOTA_TEAM_BADGUYS)

            j = j  +  1
            return delay
        end)
    end
end
