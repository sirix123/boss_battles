m1_iceshot = class({})
LinkLuaModifier("chill_modifier", "player/icemage/modifiers/chill_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shatter_modifier", "player/icemage/modifiers/shatter_modifier", LUA_MODIFIER_MOTION_NONE)

function m1_iceshot:GetCastPoint()
	local caster = self:GetCaster()
    local ability_cast_point = self.BaseClass.GetCastPoint(self)

    if caster:HasModifier("e_whirling_winds_modifier") == true and caster:GetUnitName() ~= "npc_dota_hero_hoodwink" then
        return ability_cast_point - ( ability_cast_point * 0.25 ) --flWHIRLING_WINDS_CAST_POINT_REDUCTION = 0.25 -- globals don't work here -- self:GetCastPoint()
    else
        return ability_cast_point
    end
end

function m1_iceshot:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.2)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            bMovementLock = true,
        })

        return true
    end
end
---------------------------------------------------------------------------

function m1_iceshot:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function m1_iceshot:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = self:GetSpecialValueFor( "proj_speed" )

        self.ms_slow = self:GetSpecialValueFor( "ms_slow" )
        self.as_slow = self:GetSpecialValueFor( "as_slow" )

        self.dmg = self:GetSpecialValueFor( "dmg" )

        if self.caster:HasModifier("admin_god_mode") then
            self.dmg = 10000
        end

        if self.caster:HasModifier("e_whirling_winds_modifier") then
            projectile_speed = projectile_speed + ( projectile_speed * flWHIRLING_WINDS_PROJ_SPEED_BONUS )
        end

        -- set proj direction to mouse location
        local vTargetPos = nil
        --vTargetPos = PlayerManager.mouse_positions[self.caster:GetPlayerID()]
        vTargetPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

        local projectile = {
            EffectName = "particles/icemage/icemage_m1_maiden_base_attack.vpcf",
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
                --print("UnitTest ", unit:GetUnitName())
                return unit:GetTeamNumber() ~= self.caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and CheckGlobalUnitTableForUnitName(unit) ~= true
            end,
            OnUnitHit = function(_self, unit)

                if unit:IsInvulnerable() ~= true then

                    local dmgTable = {
                        victim = unit,
                        attacker = self.caster,
                        damage = self.dmg,
                        damage_type = self:GetAbilityDamageType(),
                        ability = self,
                    }

                    -- give mana
                    self.caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_percent"))

                    -- adds chill modifier
                    if CheckRaidTableForBossName(unit) ~= true and unit:GetUnitName() ~= "npc_guard" then
                        unit:AddNewModifier(self.caster, self, "chill_modifier", { duration = self:GetSpecialValueFor( "chill_duration") })
                    end

                    -- adds shatter and stack logic
                    self.caster:AddNewModifier(self.caster, self, "shatter_modifier", { duration = self:GetSpecialValueFor( "shatter_duration"), max_shatter_stacks = self:GetSpecialValueFor( "max_shatter_stacks"), ms_slow = self.ms_slow, as_slow = self.as_slow })

                    ApplyDamage(dmgTable)

                end
                
                EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "hero_Crystal.projectileImpact", self.caster)

            end,
            OnFinish = function(_self, pos)
                -- add projectile explode particle effect here on the pos it finishes at
                local particle_cast = "particles/units/heroes/hero_crystalmaiden/maiden_base_attack_explosion.vpcf"
                local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
                ParticleManager:SetParticleControl(effect_cast, 0, pos)
                ParticleManager:SetParticleControl(effect_cast, 3, pos)
                ParticleManager:ReleaseParticleIndex(effect_cast)
            end,
        }

        Projectiles:CreateProjectile(projectile)

	end
end
----------------------------------------------------------------------------------------------------------------
