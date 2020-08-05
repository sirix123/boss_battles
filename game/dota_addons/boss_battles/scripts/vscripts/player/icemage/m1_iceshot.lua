m1_iceshot = class({})
LinkLuaModifier("chill_modifier", "player/icemage/modifiers/chill_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shatter_modifier", "player/icemage/modifiers/shatter_modifier", LUA_MODIFIER_MOTION_NONE)

function m1_iceshot:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.2)

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

        -- set proj direction to mouse location
        local vTargetPos = nil
        vTargetPos = GameMode.mouse_positions[self.caster:GetPlayerID()]
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
                return unit:GetTeamNumber() ~= self.caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl"
            end,
            OnUnitHit = function(_self, unit)
                local dmgTable = {
                    victim = unit,
                    attacker = self.caster,
                    damage = self:GetSpecialValueFor( "dmg" ),
                    damage_type = self:GetAbilityDamageType(),
                }
                print(unit)
                print(unit:GetModelName())
                -- give mana
                self.caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_percent"))

                -- adds chill modifier
                if CheckRaidTableForBossName(unit) ~= true then
                    unit:AddNewModifier(self.caster, self, "chill_modifier", { duration = self:GetSpecialValueFor( "chill_duration") })
                end

                -- adds shatter and stack logic
                self.caster:AddNewModifier(self.caster, self, "shatter_modifier", { duration = self:GetSpecialValueFor( "shatter_duration"), max_shatter_stacks = self:GetSpecialValueFor( "max_shatter_stacks") })

                ApplyDamage(dmgTable)
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
