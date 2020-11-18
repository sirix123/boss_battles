q_healing_arrow_v2 = class({})

function q_healing_arrow_v2:OnAbilityPhaseStart()
    if IsServer() then

        self.caster = self:GetCaster()

        EmitSoundOnLocationForAllies(self:GetCaster():GetAbsOrigin(), "Ability.PowershotPull", self:GetCaster())

        self.nfx = ParticleManager:CreateParticle("particles/ranger/ranger_windrunner_spell_powershot_channel_ti6.vpcf", PATTACH_POINT, self.caster)
        ParticleManager:SetParticleControlEnt(self.nfx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_bow_mid", self.caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(self.nfx, 1, self.caster:GetAbsOrigin())
        ParticleManager:SetParticleControlForward(self.nfx, 1, self.caster:GetForwardVector())

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.3)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            pMovespeedReduction = -50,
        })

        return true
    end
end
---------------------------------------------------------------------------

function q_healing_arrow_v2:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

        -- destroy channel particle
        ParticleManager:DestroyParticle( self.nfx, true )

    end
end
---------------------------------------------------------------------------

function q_healing_arrow_v2:OnSpellStart()
    if IsServer() then

        -- destroy channel particle
        ParticleManager:DestroyParticle( self.nfx, true )

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = self:GetSpecialValueFor( "proj_speed" )
        local heal = self:GetSpecialValueFor( "heal" )
        local heal_dist_multi = self:GetSpecialValueFor( "heal_dist_multi" )

        -- play sound
        EmitSoundOn("Ability.Powershot", self.caster)

        -- set proj direction to mouse location
        local vTargetPos = nil
        vTargetPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()
        -- init effect
        local enEffect = "particles/ranger/ranger_windrunner_spell_powershot_ti6.vpcf"

        -- ensure to heal self on cast
        self.caster:Heal(heal, self.caster)

        local projectile = {
            EffectName = enEffect,
            vSpawnOrigin = origin + Vector(0, 0, 100),
            fDistance = self:GetCastRange(Vector(0,0,0), nil),
            fUniqueRadius = self:GetSpecialValueFor( "hit_box" ),
            Source = self.caster,
            vVelocity = projectile_direction * projectile_speed,
            UnitBehavior = PROJECTILES_NOTHING,
            TreeBehavior = PROJECTILES_DESTROY,
            WallBehavior = PROJECTILES_DESTROY,
            GroundBehavior = PROJECTILES_NOTHING,
            fGroundOffset = 80,
            UnitTest = function(_self, unit)
                return unit:GetTeamNumber() == self.caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl"
            end,
            OnUnitHit = function(_self, unit)

                local distanceFromHero = (unit:GetAbsOrigin() - origin ):Length2D()

                heal = heal + ( distanceFromHero * heal_dist_multi )

                unit:Heal(heal, self.caster)

                -- play hit sound
                StartSoundEvent( "Hero_Windrunner.PowershotDamage", unit )

            end,
            OnFinish = function(_self, pos)
                -- add projectile explode particle effect here on the pos it finishes at
                local particle_cast = "particles/units/heroes/hero_windrunner/windrunner_base_attack_explosion_flash.vpcf"
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