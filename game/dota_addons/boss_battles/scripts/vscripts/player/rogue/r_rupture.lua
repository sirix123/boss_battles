r_rupture = class({})
LinkLuaModifier("r_rupture_modifier", "player/rogue/modifiers/r_rupture_modifier", LUA_MODIFIER_MOTION_NONE)

function r_rupture:OnAbilityPhaseStart()
    if IsServer() then

        self.caster = self:GetCaster()

        return true
    end
end
---------------------------------------------------------------------------

function r_rupture:OnAbilityPhaseInterrupted()
    if IsServer() then

    end
end
---------------------------------------------------------------------------

function r_rupture:OnSpellStart()
    if IsServer() then

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = self:GetSpecialValueFor( "proj_speed" )

        -- play sound
        EmitSoundOn("Hero_PhantomAssassin.Dagger.Cast", self.caster)

        -- set proj direction to mouse location
        local vTargetPos = nil
        vTargetPos = self:GetCursorPosition()
        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

        local particle = nil
        if self.caster.arcana_equipped == true then
            particle = "particles/rogue/cosmetic_phantom_assassin_stifling_dagger_arcana.vpcf"
        else
            particle = "particles/rogue/rogue_phantom_assassin_stifling_dagger.vpcf"
        end

        local projectile = {
            EffectName = particle,
            vSpawnOrigin = origin + Vector(0, 0, 100),
            fDistance = self:GetCastRange(Vector(0,0,0), nil),
            fStartRadius = self:GetSpecialValueFor( "hit_box" ),
			fEndRadius = self:GetSpecialValueFor( "hit_box" ),
            Source = self.caster,
            vVelocity = projectile_direction * projectile_speed,
            UnitBehavior = PROJECTILES_NOTHING,
            TreeBehavior = PROJECTILES_DESTROY,
            WallBehavior = PROJECTILES_DESTROY,
            GroundBehavior = PROJECTILES_NOTHING,
            fGroundOffset = 80,
            UnitTest = function(_self, unit)
                return unit:GetTeamNumber() ~= self.caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl"
            end,
            OnUnitHit = function(_self, unit)

                local dmgTable = {
                    victim = unit,
                    attacker = self.caster,
                    damage = self:GetSpecialValueFor( "dmg" ),
                    damage_type = self:GetAbilityDamageType(),
                    ability = self,
                }

                -- play hit sound
                StartSoundEvent( "Hero_PhantomAssassin.Dagger.Target", unit )

                -- applys base dmg icelance regardles of stacks
                ApplyDamage(dmgTable)

                -- apply bleed/serrated arrow to target
                unit:AddNewModifier(self.caster, self, "r_rupture_modifier", { duration = self:GetSpecialValueFor( "duration") })

            end,
            OnFinish = function(_self, pos)
                -- add projectile explode particle effect here on the pos it finishes at
                local particle_cast = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger_explosion.vpcf"
                local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
                ParticleManager:SetParticleControl(effect_cast, 0, pos)
                ParticleManager:SetParticleControl(effect_cast, 1, pos)
                ParticleManager:SetParticleControl(effect_cast, 3, pos)
                ParticleManager:ReleaseParticleIndex(effect_cast)
            end,
        }

        -- create projectile and launch it
        Projectiles:CreateProjectile(projectile)
	end
end
----------------------------------------------------------------------------------------------------------------