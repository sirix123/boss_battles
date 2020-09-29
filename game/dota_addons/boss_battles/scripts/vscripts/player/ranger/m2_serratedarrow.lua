m2_serratedarrow = class({})
LinkLuaModifier("r_explosive_tip_modifier_target", "player/ranger/modifiers/r_explosive_tip_modifier_target", LUA_MODIFIER_MOTION_NONE)

function m2_serratedarrow:OnAbilityPhaseStart()
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

function m2_serratedarrow:OnAbilityPhaseInterrupted()
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

function m2_serratedarrow:OnSpellStart()
    if IsServer() then

        -- destroy channel particle
        ParticleManager:DestroyParticle( self.nfx, true )

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = self:GetSpecialValueFor( "proj_speed" )
        local dmg = self:GetSpecialValueFor( "dmg" )
        local dmg_dist_multi = self:GetSpecialValueFor( "dmg_dist_multi" )

        -- play sound
        EmitSoundOn("Ability.Powershot", self.caster)

        -- set proj direction to mouse location
        local vTargetPos = nil
        vTargetPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()
        -- init effect
        local enEffect = "particles/ranger/ranger_windrunner_spell_powershot_ti6.vpcf"

        -- check for explosive tip modifier and if we have it change arrow effect and apply explosive stack
        if self.caster:HasModifier("r_explosive_tip_modifier") then
            enEffect = "particles/ranger/ranger_windrunner_spell_powershot_ti6.vpcf"
        end

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
                return unit:GetTeamNumber() ~= self.caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl"
            end,
            OnUnitHit = function(_self, unit)

                local distanceFromHero = (unit:GetAbsOrigin() - origin ):Length2D()

                dmg = dmg + ( distanceFromHero * dmg_dist_multi )

                -- init icelance dmg table
                local dmgTable = {
                    victim = unit,
                    attacker = self.caster,
                    damage = dmg,
                    damage_type = self:GetAbilityDamageType(),
                    ability = self,
                }

                -- give mana
                self.caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_percent"))

                if self.caster:HasModifier("r_explosive_tip_modifier") then
                    local hbuff = self.caster:FindModifierByNameAndCaster("r_explosive_tip_modifier", self.caster)
                    local flBuffTimeRemaining = hbuff:GetRemainingTime()
                    unit:AddNewModifier(self.caster, self, "r_explosive_tip_modifier_target", {duration = flBuffTimeRemaining})
                end

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