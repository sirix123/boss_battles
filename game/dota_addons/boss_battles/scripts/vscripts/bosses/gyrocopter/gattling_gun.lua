gattling_gun = class({})

function gattling_gun:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        self.caster = self:GetCaster()
        self.origin = self.caster:GetAbsOrigin()
        self.projectile_speed = 2500
        self.radius = 120
        self.damage = 15

        local particle =  "particles/gyrocopter/higher_gyro_flak_cannon_overhead.vpcf"
        self.gat_particle = ParticleManager:CreateParticle( particle, PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
        ParticleManager:SetParticleControl( self.gat_particle, 0, self.origin)

        self:GetCaster():EmitSound("gyrocopter_gyro_attack_06")

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function gattling_gun:OnAbilityPhaseInterrupted()
    if IsServer() then

        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)

        if self.gat_particle then
            ParticleManager:DestroyParticle(self.gat_particle,true)
        end

    end
end

function gattling_gun:OnChannelFinish(bInterrupted)
    if IsServer() then

        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)

        self:StartCooldown(self:GetCooldown(self:GetLevel()))

        if self.gat_particle then
            ParticleManager:DestroyParticle(self.gat_particle,true)
        end

    end
end

function gattling_gun:OnSpellStart()
    if not IsServer() then return end
    if not self:IsChanneling() then return end

end
---------------------------------------------------------------------------------------------------------------------------------------

function gattling_gun:OnChannelThink( interval )
    if not IsServer() then return end

    if IsValidEntity(self:GetCaster()) == false then
        return false
    end

    self.time = (self.time or 0) + interval
    local myInterval = 0.1

    local units = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),	-- int, your team number
        self:GetCaster():GetAbsOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        6000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
        FIND_CLOSEST,	-- int, order filter
        false	-- bool, can grow cache
    )

    if units ~= nil and #units ~= 0 then
        self:GetCaster():SetForwardVector(units[1]:GetAbsOrigin())
		self:GetCaster():FaceTowards(units[1]:GetAbsOrigin())
    end

    if self.time >= myInterval then

        self:GetCaster():EmitSound("Hero_Gyrocopter.Attack")

        if units ~= nil and #units ~= 0 then

            self:GetCaster():SetForwardVector(units[1]:GetAbsOrigin())
            self:GetCaster():FaceTowards(units[1]:GetAbsOrigin())

            local projectile_direction = (Vector( units[1]:GetAbsOrigin().x - self:GetCaster():GetAbsOrigin().x, units[1]:GetAbsOrigin().y - self:GetCaster():GetAbsOrigin().y, 0 )):Normalized()

            local projectile = {
                EffectName = "particles/gyrocopter/gyro_fountain_attack.vpcf", --particles/tinker/iceshot__invoker_chaos_meteor.vpcf particles/tinker/blue_tinker_missile.vpcf
                vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
                fDistance = 2500,
                fStartRadius = self.radius,
                fEndRadius = self.radius,
                Source = self:GetCaster(),
                vVelocity = projectile_direction * self.projectile_speed,
                UnitBehavior = PROJECTILES_DESTROY,
                TreeBehavior = PROJECTILES_NOTHING,
                WallBehavior = PROJECTILES_DESTROY,
                GroundBehavior = PROJECTILES_NOTHING,
                fGroundOffset = 80,
                draw = false,
                UnitTest = function(_self, unit)
                    return unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and CheckGlobalUnitTableForUnitName(unit) ~= true and unit:GetTeamNumber() ~= self:GetCaster():GetTeamNumber()
                end,
                OnUnitHit = function(_self, unit)

                    -- init dmg table
                    local damageTable = {
                        victim = unit,
                        attacker = self:GetCaster(),
                        damage = self.damage,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                        ability = self,
                    }

                    ApplyDamage( damageTable )

                    local particle_cast = "particles/base_attacks/fountain_attack_attack_explosion.vpcf"
                    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, nil)
                    ParticleManager:SetParticleControl(effect_cast, 0, unit:GetAbsOrigin())
                    ParticleManager:SetParticleControl(effect_cast, 3, unit:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(effect_cast)

                    unit:EmitSound("Hero_Gyrocopter.ProjectileImpact")

                end,
                OnFinish = function(_self, pos)

                    local particle_cast = "particles/base_attacks/fountain_attack_attack_explosion.vpcf"
                    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
                    ParticleManager:SetParticleControl(effect_cast, 0, pos)
                    ParticleManager:SetParticleControl(effect_cast, 3, pos)
                    ParticleManager:ReleaseParticleIndex(effect_cast)

                end,
            }

            Projectiles:CreateProjectile(projectile)

        end
        self.time = self.time - myInterval
    end
end
---------------------------------------------------------------------------------------------------------------------------------------