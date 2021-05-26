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
        self.radius = self:GetSpecialValueFor("radius")

        --[[caster:AddNewModifier(caster, self, "q_conq_shout_modifier",
        {
            duration = 0.1, --self:GetSpecialValueFor( "duration" ) 0.1
        })]]

        -- Create Sound
        EmitSoundOn( "Hero_Axe.Berserkers_Call", caster )

        -- particle
        local particle = 'particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf'

        local particle_stomp_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_stomp_fx, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_stomp_fx, 1, Vector(self.radius, 1, 1))
        ParticleManager:SetParticleControl(particle_stomp_fx, 2, Vector(250,0,0))
        ParticleManager:ReleaseParticleIndex(particle_stomp_fx)

        -- find the vortex thinkers on the map, then add its location to the table
        --local i = 0
        --[[local previous_result = nil
        local result = nil
        while i < 2 do

            if previous_result == nil then
                result = Entities:FindByClassname(nil, "npc_dota_thinker")
            else
                result = Entities:FindByClassname(previous_result, "npc_dota_thinker")
            end

            print("result ",result)

            if result ~= nil then
                previous_result = result
                local modifier = result:FindModifierByName("r_blade_vortex_thinker")
                if modifier then
                    print("modifier ",modifier)
                    if modifier:GetCaster() == self:GetCaster() then
                        table.insert(self.tLocations,modifier.currentTarget)
                        table.insert(self.tHandleVortex,modifier)
                    end
                end
            end

            if result == nil then break end

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

        -- increase duration of the vortex(s)
        if self.tHandleVortex ~= nil and #self.tHandleVortex ~= 0 then
            for _, vortex in pairs(self.tHandleVortex) do

                -- inc their tick damage
                vortex.dmg = caster:FindAbilityByName("r_blade_vortex"):GetSpecialValueFor( "base_dmg" ) + ( self:GetSpecialValueFor( "vortex_dmg_inc" ) * caster:FindAbilityByName("r_blade_vortex"):GetSpecialValueFor( "base_dmg" ) )

                --PrintTable(vortex)
                Timers:CreateTimer(caster:FindAbilityByName("q_conq_shout"):GetSpecialValueFor( "duration" ), function()
                    vortex.dmg = caster:FindAbilityByName("r_blade_vortex"):GetSpecialValueFor( "base_dmg" )
                    return false
                end)

                -- inc duration
                local remaining_time = vortex:GetRemainingTime()
                local vortex_ability_shout_duration_increase = caster:FindAbilityByName("r_blade_vortex"):GetSpecialValueFor( "shout_duration_increase" )
                local extended_duration = remaining_time + vortex_ability_shout_duration_increase
                vortex:SetDuration(extended_duration, true)

                -- set their obsorigin to caster origin
                vortex.currentTarget = self:GetCaster():GetAbsOrigin()

                print("moving vortex")
                print("--------------")

            end
        end]]

    end
end