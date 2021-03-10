q_conq_shout = class({})
LinkLuaModifier( "q_conq_shout_modifier", "player/warlord/modifiers/q_conq_shout_modifier", LUA_MODIFIER_MOTION_NONE )
---------------------------------------------------------------------------

function q_conq_shout:OnAbilityPhaseStart()

	return true
end
---------------------------------------------------------------------------

function q_conq_shout:OnAbilityPhaseInterrupted()

end
---------------------------------------------------------------------------


function q_conq_shout:OnSpellStart()
    if IsServer() then

        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor( "duration" )
        self.radius = self:GetSpecialValueFor( "radius" )

        self.tLocations = {}
        self.tHandleVortex = {}
        self.tFriends = {}

        -- find the vortex thinkers on the map, then add its location to the table
        local i = 0
        local previous_result = nil
        local result = nil
        while i < 2 do

            if previous_result == nil then
                result = Entities:FindByClassnameWithin(nil, "npc_dota_thinker", caster:GetAbsOrigin(), 9000)
            else
                result = Entities:FindByClassnameWithin(previous_result, "npc_dota_thinker", caster:GetAbsOrigin(), 9000)
            end

            if result ~= nil then
                previous_result = result
                local modifier = result:FindModifierByName("r_blade_vortex_thinker")
                if modifier:GetCaster() == self:GetCaster() then
                    table.insert(self.tLocations,modifier.currentTarget)
                    table.insert(self.tHandleVortex,modifier)
                end
            end

            i = i + 1
        end

        -- add caster location t0 the table
        table.insert(self.tLocations,caster:GetAbsOrigin())

        -- for each location find friendlies around it
        if self.tLocations ~= nil and #self.tLocations ~= 0 then
            for _, location in pairs(self.tLocations) do
                self:FindFriends( location )

                --DebugDrawCircle(location,Vector(255,0,0),128,self.radius,true,60)

                -- particle
                local particle = 'particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf'

                local particle_stomp_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
                ParticleManager:SetParticleControl(particle_stomp_fx, 0, location)
                ParticleManager:SetParticleControl(particle_stomp_fx, 1, Vector(self.radius, 1, 1))
                ParticleManager:SetParticleControl(particle_stomp_fx, 2, Vector(250,0,0))
                ParticleManager:ReleaseParticleIndex(particle_stomp_fx)

            end
        end

        --[[ for friendly in the table add the modifier
        if self.tFriends ~= nil and #self.tFriends ~= 0 then
            for _,friend in pairs(self.tFriends) do
                friend:AddNewModifier(
                    caster, -- player source
                    self, -- ability source
                    "q_conq_shout_modifier", -- modifier name
                    { duration = duration} -- kv
                )
            end
        end]]

        -- increase duration of the vortex(s)
        if self.tHandleVortex ~= nil and #self.tHandleVortex ~= 0 then
            for _, vortex in pairs(self.tHandleVortex) do

                -- inc their tick damage
                vortex.dmg = caster:FindAbilityByName("r_blade_vortex"):GetSpecialValueFor( "base_dmg" )

                --PrintTable(vortex)

                -- inc duration
                local remaining_time = vortex:GetRemainingTime()
                local vortex_ability_shout_duration_increase = caster:FindAbilityByName("r_blade_vortex"):GetSpecialValueFor( "shout_duration_increase" )
                local extended_duration = remaining_time + vortex_ability_shout_duration_increase
                vortex:SetDuration(extended_duration, true)

                -- set their obsorigin to caster origin
                vortex.currentTarget = self:GetCaster():GetAbsOrigin()

            end
        end

        -- Create Sound
        EmitSoundOn( "Hero_Axe.Berserkers_Call", self:GetCaster() )

    end
end

function q_conq_shout:FindFriends( location )
    if IsServer() then

        local friendlies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            location,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
	    )

        if friendlies ~= nil and friendlies ~= 0 then
            for _, friend in pairs(friendlies) do
                table.insert(self.tFriends,friend)
            end
        end
    end
end