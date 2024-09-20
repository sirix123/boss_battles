q_healing_arrow_v2 = class({})

function q_healing_arrow_v2:Precache( context )
    PrecacheResource( "particle", "particles/ranger/ranger_windrunner_spell_powershot_ti6.vpcf", context )
    PrecacheResource( "particle", "particles/ranger/ranger_windrunner_spell_powershot_channel_ti6.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_windrunner/windrunner_base_attack_explosion_flash.vpcf", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_windrunner.vsndevts", context )
end

function q_healing_arrow_v2:OnAbilityPhaseStart()
    if IsServer() then

        self.caster = self:GetCaster()

        EmitSoundOnLocationForAllies(self:GetCaster():GetAbsOrigin(), "Ability.PowershotPull", self:GetCaster())

        self.nfx = ParticleManager:CreateParticle("particles/ranger/ranger_windrunner_spell_powershot_channel_ti6.vpcf", PATTACH_POINT, self.caster)
        -- ParticleManager:SetParticleControlEnt(self.nfx, 0, self.caster, PATTACH_POINT_FOLLOW, "bow_1", self.caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(self.nfx, 0, self.caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(self.nfx, 1, self.caster:GetAbsOrigin())
        ParticleManager:SetParticleControlForward(self.nfx, 1, self.caster:GetForwardVector())

        return true
    end
end
---------------------------------------------------------------------------

function q_healing_arrow_v2:OnAbilityPhaseInterrupted()
    if IsServer() then
        -- destroy channel particle
        ParticleManager:DestroyParticle( self.nfx, true )

    end
end
---------------------------------------------------------------------------

function q_healing_arrow_v2:OnSpellStart()
    if IsServer() then

        -- destroy channel particle
        ParticleManager:DestroyParticle( self.nfx, true )

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = self:GetSpecialValueFor( "proj_speed" )
        local heal = self:GetSpecialValueFor( "heal" )
        local heal_dist_multi = self:GetSpecialValueFor( "heal_dist_multi" ) / 100

        -- play sound
        EmitSoundOn("Ability.Powershot", self.caster)

        -- set proj direction to mouse location
        local vTargetPos = nil
        vTargetPos = Vector(self:GetCursorPosition().x, self:GetCursorPosition().y, self:GetCursorPosition().z)
        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()
        -- init effect
        local enEffect = "particles/ranger/ranger_windrunner_spell_powershot_ti6.vpcf"

        -- ensure to heal self on cast
        self.caster:Heal(heal + 100, self.caster)


        local projectile = {
            EffectName = enEffect,
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
                return unit:GetTeamNumber() == self.caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl"
            end,
            OnUnitHit = function(_self, unit)

                print("unitname,", unit:GetUnitName())

                local distanceFromHero = (unit:GetAbsOrigin() - origin ):Length2D()

                heal = heal + ( distanceFromHero * heal_dist_multi )

                unit:Heal(heal, self.caster)

                -- give mana
                self.caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_per_hit"))

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