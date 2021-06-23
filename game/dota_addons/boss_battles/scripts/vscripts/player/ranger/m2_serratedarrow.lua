m2_serratedarrow = class({})
LinkLuaModifier("r_explosive_tip_modifier_target", "player/ranger/modifiers/r_explosive_tip_modifier_target", LUA_MODIFIER_MOTION_NONE)

function m2_serratedarrow:OnAbilityPhaseStart()
    if IsServer() then

        self.caster = self:GetCaster()

        EmitSoundOnLocationForAllies(self:GetCaster():GetAbsOrigin(), "Ability.PowershotPull", self:GetCaster())

        local enEffect = nil
        if self.caster.arcana_equipped == true then
            enEffect = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_powershot_channel.vpcf"
        else
            enEffect = "particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_channel_ti6.vpcf"
        end

        self.nfx = ParticleManager:CreateParticle(enEffect, PATTACH_ABSORIGIN_FOLLOW, self.caster)
        ParticleManager:SetParticleControlEnt(self.nfx, 0, self.caster, PATTACH_POINT_FOLLOW, "bow_mid1", self.caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(self.nfx, 1, self.caster:GetAbsOrigin())
        ParticleManager:SetParticleControlForward(self.nfx, 1, self.caster:GetForwardVector())

        local animation_sequence = nil
        if self:GetCaster():HasModifier("modifier_hero_movement") == true then
            animation_sequence = "focusfire"

            self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker_windrunner_focusfire",
            {
                duration = self:GetCastPoint(),
            })
        else
            self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.3)
        end

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            pMovespeedReduction = -50,
            animation_sequence = animation_sequence,
        })

        return true
    end
end
---------------------------------------------------------------------------

function m2_serratedarrow:OnAbilityPhaseInterrupted()
    if IsServer() then


        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

        -- destroy channel particle
        ParticleManager:DestroyParticle( self.nfx, true )

    end
end
---------------------------------------------------------------------------

function m2_serratedarrow:OnSpellStart()
    if IsServer() then

        -- destroy channel particle
        ParticleManager:DestroyParticle( self.nfx, true )

        -- remove casting animation
        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = self:GetSpecialValueFor( "proj_speed" )
        local dmg = self:GetSpecialValueFor( "dmg" )
        local dmg_dist_multi = self:GetSpecialValueFor( "dmg_dist_multi" ) / 100

        -- play sound
        EmitSoundOn("Ability.Powershot", self.caster)

        -- set proj direction to mouse location
        local vTargetPos = nil
        vTargetPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()
        -- init effect

        local enEffect = nil
        if self.caster.arcana_equipped == true then
            enEffect = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_spell_powershot.vpcf"
        else
            enEffect = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf"
        end

        local units_hit = 0

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
                return unit:GetTeamNumber() ~= self.caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and CheckGlobalUnitTableForUnitName(unit) ~= true
            end,
            OnUnitHit = function(_self, unit)

                local distanceFromHero = (unit:GetAbsOrigin() - origin ):Length2D()

                if self.caster:HasModifier("e_whirling_winds_modifier") then
                    distanceFromHero = self:GetCastRange(Vector(0,0,0), nil)
                    dmg = ( dmg + ( distanceFromHero * dmg_dist_multi ) )
                else
                    dmg = ( dmg + ( distanceFromHero * dmg_dist_multi ) )
                end

                local dmgTable = {
                    victim = unit,
                    attacker = self.caster,
                    damage = dmg,
                    damage_type = self:GetAbilityDamageType(),
                    ability = self,
                }

                dmg = self:GetSpecialValueFor( "dmg" )

                -- play hit sound
                StartSoundEvent( "Hero_Windrunner.PowershotDamage", unit )

                -- applys base dmg icelance regardles of stacks
                ApplyDamage(dmgTable)

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