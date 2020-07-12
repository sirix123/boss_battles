m1_trackingshot = class({})
LinkLuaModifier("m1_trackingshot_charges", "player/ranger/modifiers/m1_trackingshot_charges", LUA_MODIFIER_MOTION_NONE)

local nAtkCount = 1

function m1_trackingshot:OnAbilityPhaseStart()
    if IsServer() then

        -- check if we have charges
        if self:GetCaster():HasModifier("m1_trackingshot_charges") == true then
            if self:GetCaster():GetModifierStackCount("m1_trackingshot_charges", nil) == 0 then
                -- surface message to player?
                return false
            end
        end

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            pMovespeedReduction = -80,
        })

        return true
    end
end
---------------------------------------------------------------------------

function m1_trackingshot:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function m1_trackingshot:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = self:GetSpecialValueFor( "proj_speed" )
        local dmg = 0

        self.caster:FindModifierByName("m1_trackingshot_charges"):DecrementStackCount()

        -- set proj direction to mouse location
        local vTargetPos = nil
        vTargetPos = GameMode.mouse_positions[self.caster:GetPlayerID()]
        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

        -- attack 3 no bleed debuff
        local enEffect = "particles/ranger/m1_ranger_windrunner_base_attack.vpcf"

        -- attack 3
        if nAtkCount == 3 then
            dmg = self:GetSpecialValueFor( "base_dmg_3" )
            enEffect = "particles/ranger/m1_ranger_atk3_windrunner_base_attack.vpcf"

        -- attack 1 and 2
        else
            dmg = self:GetSpecialValueFor( "base_dmg_1_2" )
            enEffect = "particles/ranger/m1_ranger_windrunner_base_attack.vpcf"

        end

        local projectile = {
            EffectName = enEffect,
            vSpawnOrigin = origin + Vector(0, 0, 100),
            fDistance = self:GetCastRange(Vector(0,0,0), nil),
            fUniqueRadius = self:GetSpecialValueFor( "hit_box" ),
            Source = self.caster,
            vVelocity = projectile_direction * projectile_speed,
            UnitBehavior = PROJECTILES_DESTROY,
            TreeBehavior = PROJECTILES_DESTROY,
            WallBehavior = PROJECTILES_DESTROY,
            GroundBehavior = PROJECTILES_NOTHING,
            fGroundOffset = 80,
            UnitTest = function(_self, unit)
                return unit:GetTeamNumber() ~= self.caster:GetTeamNumber()
            end,
            OnUnitHit = function(_self, unit)

                if nAtkCount == 3 and unit:FindModifierByNameAndCaster("m2_serratedarrow_modifier", self.caster) == true then
                    dmg = dmg + self:GetSpecialValueFor( "addtional_dmg_3_serrated_debuff" )
                elseif nAtkCount < 3 and unit:FindModifierByNameAndCaster("m2_serratedarrow_modifier", self.caster) == true then
                    dmg = dmg + self:GetSpecialValueFor( "addtional_dmg_1_2_serrated_debuff" )
                end

                --print("dmg = ",dmg)

                local dmgTable = {
                    victim = unit,
                    attacker = self.caster,
                    damage = dmg,
                    damage_type = self:GetAbilityDamageType(),
                }

                -- give mana
                self.caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_percent"))

                -- lower cd of m2 serrated arrow
                --self.caster:AddNewModifier(self.caster, self, "shatter_modifier", { duration = self:GetSpecialValueFor( "shatter_duration"), max_shatter_stacks = self:GetSpecialValueFor( "max_shatter_stacks") })

                ApplyDamage(dmgTable)
                EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "hero_WindRunner.projectileImpact", self.caster)

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

        nAtkCount = nAtkCount + 1
        if nAtkCount > 3 then
            nAtkCount = 1
        end

        Projectiles:CreateProjectile(projectile)

	end
end
----------------------------------------------------------------------------------------------------------------
