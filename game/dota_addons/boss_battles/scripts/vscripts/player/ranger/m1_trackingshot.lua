m1_trackingshot = class({})
LinkLuaModifier("r_explosive_tip_modifier_target", "player/ranger/modifiers/r_explosive_tip_modifier_target", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("casting_modifier_thinker_windrunner_focusfire", "player/ranger/modifiers/casting_modifier_thinker_windrunner_focusfire", LUA_MODIFIER_MOTION_NONE)

function m1_trackingshot:GetCastPoint()
	local caster = self:GetCaster()
    local ability_cast_point = self.BaseClass.GetCastPoint(self)

    if caster:HasModifier("e_whirling_winds_modifier") == true and caster:GetUnitName() ~= "npc_dota_hero_hoodwink" then
        return ability_cast_point - ( ability_cast_point * 0.25 ) --flWHIRLING_WINDS_CAST_POINT_REDUCTION = 0.25 -- globals don't work here self:GetCastPoint()
    else
        return ability_cast_point
    end
end

---------------------------------------------------------------------------

function m1_trackingshot:OnAbilityPhaseStart()
    if IsServer() then

        local animation_sequence = nil
        if self:GetCaster():HasModifier("modifier_hero_movement") == true then
            animation_sequence = "focusfire"
            self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_RUN, 1.0)

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

        --print("cast_point ",self:GetCastPoint())

        -- sound effect
        EmitSoundOn( "Hero_Windrunner.Attack", self:GetCaster() )

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

        -- set proj direction to mouse location
        local vTargetPos = nil
        vTargetPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

        local dmg = self:GetSpecialValueFor( "base_dmg" )
        local dmg_dist_multi = self:GetSpecialValueFor( "dmg_dist_multi" ) / 100

        -- init effect
        local enEffect = nil
        if self.caster.arcana_equipped == true then
            enEffect = "particles/ranger/cosmetic_windranger_arcana_base_attack.vpcf"
        else
            enEffect = "particles/ranger/m1_ranger_windrunner_base_attack.vpcf"
        end

        -- check if caster has rain of arrows moidifier
        if self.caster:HasModifier("e_whirling_winds_modifier") then
            projectile_speed = projectile_speed + ( projectile_speed * flWHIRLING_WINDS_PROJ_SPEED_BONUS )
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
                return unit:GetTeamNumber() ~= self.caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and CheckGlobalUnitTableForUnitName(unit) ~= true
            end,
            OnUnitHit = function(_self, unit)

                if unit:IsInvulnerable() ~= true then

                    local distanceFromHero = (unit:GetAbsOrigin() - origin ):Length2D()

                    if self.caster:HasModifier("e_whirling_winds_modifier") then
                        distanceFromHero = self:GetCastRange(Vector(0,0,0), nil)
                        dmg = dmg + ( distanceFromHero * dmg_dist_multi )
                    else
                        dmg = dmg + ( distanceFromHero * dmg_dist_multi )
                    end

                    local dmgTable = {
                        victim = unit,
                        attacker = self.caster,
                        damage = dmg,
                        damage_type = self:GetAbilityDamageType(),
                        ability = self,
                    }

                    -- give mana
                    self.caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_percent"))

                    ApplyDamage(dmgTable)

                    if self.caster:HasModifier("r_explosive_tip_modifier") then
                        local hbuff = self.caster:FindModifierByNameAndCaster("r_explosive_tip_modifier", self.caster)
                        local flBuffTimeRemaining = hbuff:GetRemainingTime()
                        unit:AddNewModifier(self.caster, self, "r_explosive_tip_modifier_target", {duration = flBuffTimeRemaining})
                    end

                end

                -- play sound
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

        Projectiles:CreateProjectile(projectile)

	end
end
----------------------------------------------------------------------------------------------------------------
