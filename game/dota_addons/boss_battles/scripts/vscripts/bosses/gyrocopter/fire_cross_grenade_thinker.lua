
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
        AddFOWViewer(DOTA_TEAM_GOODGUYS, self:GetParent():GetAbsOrigin(), 8000, 9999, true)

        local particle = "particles/gyrocopter/gyro_rubick_blackhole.vpcf"
        self.effect_cast = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetParent():GetAbsOrigin())

        local particleName_3 = "particles/clock/green_clock_npx_moveto_arrow.vpcf"
        self.pfx_3 = ParticleManager:CreateParticle( particleName_3, PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( self.pfx_3, 0, self:GetParent():GetAbsOrigin() )

        self.max_waves = 6
        self.current_waves = 0
        self.destroy_count = 0

        self.destroy_flag = false

        self.start_delay = 2
        --self:StartIntervalThink(self.start_delay)
        self:StartTimer()
        self:DetectPlayerTimer()
    end
end

function fire_cross_grenade_thinker:DetectPlayerTimer()
    if IsServer() then
        self.detect_player_timer = Timers:CreateTimer(self.start_delay, function()
            --[[if IsValidEntity(self:GetParent()) == false then
                self:OnDestroy()
                return false
            end]]

            if self.destroy_flag == true then
                self:OnDestroy()
                return false
            end

            local enemies = FindUnitsInRadius(
                self:GetCaster():GetTeamNumber(),	-- int, your team number
                self:GetParent():GetAbsOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                200,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
                DOTA_UNIT_TARGET_HERO,	-- int, type filter
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
                0,	-- int, order filter
                false	-- bool, can grow cache
            )

            if enemies ~= nil and #enemies ~= 0 then
                for _,enemy in pairs(enemies) do
                    enemy:AddNewModifier( self:GetCaster(), self, "fire_cross_grenade_debuff", { duration = -1 } )
                    ParticleManager:DestroyParticle(self.pfx_3,true)
                    self.destroy_flag = true
                end
            end

            if self.current_waves == self.max_waves then
                ParticleManager:DestroyParticle(self.pfx_3,true)
                self.destroy_flag = true
                return 8
            end

            return 0.03
        end)
    end
end

function fire_cross_grenade_thinker:StartTimer(  )
    if IsServer() then

        local effect = "particles/gyrocopter/gyro_invoker_chaos_meteor.vpcf"-- "particles/techies/techies_lion_spell_impale.vpcf"

        local distance = 2000
        local parent_origin = self:GetParent():GetAbsOrigin()
        local parent = self:GetParent()
        local caster = self:GetCaster()
        local ability = self:GetAbility()

        local tDirection =
        {
            Vector(0,1,0),
            Vector(1,0,0),
            Vector(0,-1,0),
            Vector(-1,0,0),
        }

        self.proj_timer = Timers:CreateTimer(self.start_delay, function()
            if self.destroy_flag == true then
                self:OnDestroy()
                return false
            end

            if self.current_waves == self.max_waves then
                self.destroy_flag = true
                return 8
            end

            -- projectile
            for i = 1, #tDirection, 1 do
                local projectile = {
                    EffectName = effect,
                    vSpawnOrigin = parent_origin + tDirection[i] * 210 ,
                    fDistance = distance,
                    fUniqueRadius = 100,
                    Source = parent,
                    vVelocity = tDirection[i] * 600,
                    UnitBehavior = PROJECTILES_NOTHING,
                    TreeBehavior = PROJECTILES_DESTROY,
                    WallBehavior = PROJECTILES_DESTROY,
                    GroundBehavior = PROJECTILES_NOTHING,
                    fGroundOffset = 80,
                    --draw = true,
                    UnitTest = function(_self, unit)
                        return unit:GetTeamNumber() ~= caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl"
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
                            attacker = caster,
                            damage = 400,
                            damage_type = DAMAGE_TYPE_PHYSICAL,
                            ability = ability,
                        })

                        -- play sound
                        EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "Hero_Lion.ImpaleHitTarget", parent)

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

        --self.detect_player_timer =
        -- self.proj_timer =

        if self.effect_cast then
            ParticleManager:DestroyParticle(self.effect_cast,true)
        end

        if self.pfx_3 then
            ParticleManager:DestroyParticle(self.pfx_3,true)
        end
    end
end

-----------------------------------------------------------------------------