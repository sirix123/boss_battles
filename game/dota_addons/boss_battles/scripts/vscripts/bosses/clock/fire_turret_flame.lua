fire_turret_flame = class({})

function fire_turret_flame:OnSpellStart()
    if IsServer() then

        -- animtion 
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.5)

        -- init
		local caster = self:GetCaster()
        local origin = caster:GetAbsOrigin()

        -- init projectile params
        local speed = self:GetSpecialValueFor( "speed" ) --500
        local direction = caster:GetForwardVector()

        local projectile = {
            EffectName = "particles/clock/clock_flame_turret_invoker_chaos_meteor.vpcf",
            vSpawnOrigin = origin,
            fDistance = self:GetCastRange(Vector(0,0,0), nil),
            fUniqueRadius = self:GetSpecialValueFor( "hit_box" ),--200
            Source = caster,
            vVelocity = direction * speed,
            UnitBehavior = PROJECTILES_DESTROY,
            TreeBehavior = PROJECTILES_NOTHING,
            WallBehavior = PROJECTILES_DESTROY,
            GroundBehavior = PROJECTILES_NOTHING,
            fGroundOffset = 80,
            UnitTest = function(_self, unit)
                return unit:GetTeamNumber() ~= caster:GetTeamNumber()
            end,
            OnUnitHit = function(_self, unit)
                local dmgTable = {
                    victim = unit,
                    attacker = caster,
                    damage = self:GetSpecialValueFor( "dmg" ), -- 100
                    damage_type = self:GetAbilityDamageType(),
                }

                ApplyDamage(dmgTable)
                --EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "hero_Crystal.projectileImpact", caster)
                self:Effect(unit:GetAbsOrigin())
            end,
            OnFinish = function(_self, pos)
                self:Effect(pos)
            end,
        }

        Projectiles:CreateProjectile(projectile)
        --self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK, 1.0)

	end
end
------------------------------------------------------------------------------------------------

function fire_turret_flame:Effect(pos)
    if IsServer() then
        -- add projectile explode particle effect here on the pos it finishes at
        local particle_cast = "particles/units/heroes/hero_invoker/invoker_chaos_meteor_crumble.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(effect_cast, 3, pos)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end
end