
fire_cross_grenade_thinker = class({})
-----------------------------------------------------------------------------

function fire_cross_grenade_thinker:IsHidden()
	return false
end
-----------------------------------------------------------------------------

function fire_cross_grenade_thinker:OnCreated( kv )
    if IsServer() then

        -- on spawn of the thinker create a particle thing on the ground
        --DebugDrawCircle(self:GetParent():GetAbsOrigin(),Vector(255,0,0),128,60,true,60)

        local particle = "particles/gyrocopter/gyro_rubick_blackhole.vpcf"
        self.effect_cast = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetParent():GetAbsOrigin())

        self.max_waves = 6
        self.current_waves = 0
        self.destroy_count = 0

        self.destroy_flag = false

        self.start_delay = 2
        --self:StartIntervalThink(self.start_delay)
        self:StartTimer()
    end
end

function fire_cross_grenade_thinker:StartTimer(  )
    if IsServer() then

        local effect = "particles/gyrocopter/gyro_invoker_chaos_meteor.vpcf"-- "particles/techies/techies_lion_spell_impale.vpcf"

        local distance = 5000

        local tDirection =
        {
            Vector(0,1,0),
            Vector(1,0,0),
            Vector(0,-1,0),
            Vector(-1,0,0),
        }

        Timers:CreateTimer(self.start_delay, function()
            if IsValidEntity(self:GetParent()) == false then
                return false
            end

            if self.destroy_flag == true then
                self:Destroy()
            end

            if self.current_waves == self.max_waves then
                self.destroy_flag = true
                return 5
            end

            -- projectile
            for i = 1, #tDirection, 1 do
                local projectile = {
                    EffectName = effect,
                    vSpawnOrigin = self:GetParent():GetAbsOrigin() + tDirection[i] ,
                    fDistance = distance,
                    fUniqueRadius = 100,
                    Source = self:GetParent(),
                    vVelocity = tDirection[i] * 600,
                    UnitBehavior = PROJECTILES_NOTHING,
                    TreeBehavior = PROJECTILES_DESTROY,
                    WallBehavior = PROJECTILES_DESTROY,
                    GroundBehavior = PROJECTILES_NOTHING,
                    fGroundOffset = 80,
                    UnitTest = function(_self, unit)
                        return unit:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl"
                    end,
                    OnUnitHit = function(_self, unit)

                        --[[unit:AddNewModifier(
                            self:GetParent(), -- player source
                            self, -- ability source
                            "modifier_generic_stunned", -- modifier name
                            { duration = 3 } -- kv
                        )]]

                        ApplyDamage({
                            victim = unit,
                            attacker = self:GetCaster(),
                            damage = 400,
                            damage_type = DAMAGE_TYPE_PHYSICAL
                        })

                        -- play sound
                        EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "Hero_Lion.ImpaleHitTarget", self:GetParent())

                    end,
                    OnFinish = function(_self, pos)
                        -- add projectile explode particle effect here on the pos it finishes at
                        local particle_cast = "particles/units/heroes/hero_earth_spirit/earth_dust_hit.vpcf"
                        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
                        ParticleManager:SetParticleControl(effect_cast, 0, pos)
                        ParticleManager:ReleaseParticleIndex(effect_cast)
                    end,
                }

                Projectiles:CreateProjectile(projectile)
            end

            self.current_waves = self.current_waves + 1

            return 2
        end)
    end
end

function fire_cross_grenade_thinker:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle(self.effect_cast,false)
        --UTIL_Remove( self:GetParent() )
    end
end

-----------------------------------------------------------------------------