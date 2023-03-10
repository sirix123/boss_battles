
summon_electric_vortex_turret = class({})

--[[function summon_electric_vortex_turret:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        return true
    end
end]]
---------------------------------------------------------------------------------------------------------------------------------------

function summon_electric_vortex_turret:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()

        local delay = 0.1
        local point = Vector(0,0,0)
        local max_turrets = self:GetSpecialValueFor( "max_turrets" )

        -- if SOLO_MODE == true then
        --     max_turrets = 2
        -- end

        -- find a random point inside the map arena
        --local vTargetPos = Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z) -- for testing
        --local vTargetPos = Vector(Rand)

        -- there are 4 lines cause square
        -- they are..
        local left_side = Vector(8862,RandomInt(497,2929),130)
        local right_side = Vector(11320,RandomInt(497,2929),130)
        local top_side = Vector(RandomInt(1132,8862),2929,130)
        local bottom_side = Vector(RandomInt(1132,8862),497,130)

        -- center of techies arena DEBUG VECTOR LOCATION:     Vector 000000000223ECF0 [10058.650391 1505.785156 130.121094]

        local tSides = {left_side, right_side, top_side, bottom_side}

        local vTargetPos = tSides[RandomInt(1,#tSides)]
        --local vTargetPos = Vector(RandomInt(9126,11000),RandomInt(1500,1800),0)
        --DebugDrawCircle(vTargetPos, Vector(0,255,0), 128, 500, true, 60)
        
        -- self.centreOfTechiesArena = Vector(10058,1505,130)

        local i = 0
        Timers:CreateTimer(delay, function()

            if i == max_turrets then
                return false
            end

            local particle_cast = "particles/units/heroes/hero_rattletrap/rattletrap_cog_deploy.vpcf"
            local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(effect_cast, 0, vTargetPos)
            ParticleManager:ReleaseParticleIndex(effect_cast)

            -- sound effect
            local sound_cast = "Hero_Rattletrap.Power_Cogs"
            EmitSoundOn(sound_cast,self:GetCaster())

            CreateUnitByName("npc_electric_vortex_turret", vTargetPos, true, self:GetCaster(), self:GetCaster():GetOwner(), caster:GetTeamNumber())

            i = i  +  1
            return delay
        end)
    end
end