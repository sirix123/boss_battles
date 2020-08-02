chain_gun_shoot = class({})

function chain_gun_shoot:OnSpellStart()
    if IsServer() then

        -- init
		local caster = self:GetCaster()
        local origin = caster:GetAbsOrigin()
        local delay_between_shots = self:GetSpecialValueFor( "delay_between_shots" ) --0.5

        --[[ particle (bullet casing) (not working with turret model)
        local particle_cast = "particles/econ/items/ursa/ursa_ti10/ursa_ti10_earthshock_electric_arcs.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(effect_cast, 9, caster:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)]]

        -- init projectile params
        local speed = self:GetSpecialValueFor( "speed" ) --500
        local angleIncrement = self:GetSpecialValueFor( "angleIncrement" ) --10
        local currentAngle = 1

        if caster:HasModifier("electric_turret_minion_buff") == true then
            speed = speed * 1.5
            angleIncrement = angleIncrement / 2
            delay_between_shots = delay_between_shots / 2
        end

        -- just keep on spinning and shooting until you die
        Timers:CreateTimer(0.5, function()

            -- if we have run out of proj in the batch end this timer
            if caster:IsAlive() == false then

                return false
            end

            local projectile = {
                EffectName = "particles/clock/chain_gun_vengeful_magic_missle.vpcf",
                vSpawnOrigin = origin + Vector(0,0,80),
                fDistance = self:GetCastRange(Vector(0,0,0), nil),
                fUniqueRadius = self:GetSpecialValueFor( "hit_box" ),--200
                Source = caster,
                vVelocity = ( RotatePosition(Vector(0,0,0), QAngle(0,currentAngle,0), Vector(1,0,0)) )  * speed,
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

                    self:Effect(unit:GetAbsOrigin())
                end,
                OnFinish = function(_self, pos)
                    self:Effect(pos)
                end,
            }

            -- increment the angle
            currentAngle = currentAngle + angleIncrement

            -- create and shoot the proj
            Projectiles:CreateProjectile(projectile)

            return delay_between_shots

        end)
	end
end
------------------------------------------------------------------------------------------------

function chain_gun_shoot:Effect(pos)
    if IsServer() then
        -- add projectile explode particle effect here on the pos it finishes at
        local particle_cast = "particles/clock/clock_vengeful_magic_missle_end.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(effect_cast, 3, pos)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end
end