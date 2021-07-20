pugna_m2 = class({})
LinkLuaModifier("m2_dot_pugna", "player/pugna/modifiers/m2_dot_pugna", LUA_MODIFIER_MOTION_NONE)

function pugna_m2:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 0.4)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            bMovementLock = true,
            pMovespeedReduction = 0,
        })


        return true
    end
end
---------------------------------------------------------------------------

function pugna_m2:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function pugna_m2:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        --self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = self:GetSpecialValueFor( "proj_speed" )

        self.dmg = self:GetSpecialValueFor( "dmg" )

        EmitSoundOnLocationWithCaster(self.caster:GetAbsOrigin(), "Hero_Necrolyte.DeathPulse", self.caster)

        -- set proj direction to mouse location
        local vTargetPos = nil
        vTargetPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

        self.stacks = 0
        if self.caster:HasModifier("soul_crystals") then
            self.stacks = self.caster:GetModifierStackCount("soul_crystals", self.caster)
        end

        local projectile = {
            EffectName = "particles/pugna/pugna_necrolyte_pulse_ka_enemy.vpcf",
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

                    local dmgTable = {
                        victim = unit,
                        attacker = self.caster,
                        damage = self.dmg,
                        damage_type = self:GetAbilityDamageType(),
                        ability = self,
                    }

                    local particle_cast = "particles/econ/items/necrolyte/necronub_death_pulse/necrolyte_pulse_ka_enemy_explosion.vpcf"
                    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
                    ParticleManager:SetParticleControl(effect_cast, 0, unit:GetAbsOrigin())
                    ParticleManager:SetParticleControl(effect_cast, 3, unit:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(effect_cast)

                    ApplyDamage(dmgTable)

                    unit:AddNewModifier(
                        self.caster, -- player source
                        self, -- ability source
                        "m2_dot_pugna", -- modifier name
                        {
                            duration = self:GetSpecialValueFor( "dot_duration" ),
                        } -- kv
                    )

                end

                EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "Hero_Necrolyte.ProjectileImpact", self.caster)

                if self.stacks == 3 then

                    local units = FindUnitsInRadius(
                        self:GetCaster():GetTeamNumber(),
                        unit:GetAbsOrigin(),
                        nil,
                        1500,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_CLOSEST,
                        false)

                    if units ~= nil or #units ~= 0 then

                        local info = {
                            EffectName = "particles/econ/items/necrolyte/necronub_death_pulse/necrolyte_pulse_ka_enemy.vpcf",
                            Ability = self,
                            iMoveSpeed = 1500,
                            Source = units[1],
                            Target = units[2],
                            bDodgeable = false,
                            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                            bProvidesVision = true,
                            iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                            iVisionRadius = 300,
                        }

                        ProjectileManager:CreateTrackingProjectile( info )

                    else

                        local info = {
                            EffectName = "particles/econ/items/necrolyte/necronub_death_pulse/necrolyte_pulse_ka_enemy.vpcf",
                            Ability = self,
                            iMoveSpeed = 1500,
                            Source = self.caster,
                            Target = units[1],
                            bDodgeable = false,
                            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                            bProvidesVision = true,
                            iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                            iVisionRadius = 300,
                        }

                        ProjectileManager:CreateTrackingProjectile( info )

                    end
                end

            end,
            OnFinish = function(_self, pos)
                -- add projectile explode particle effect here on the pos it finishes at
                local particle_cast = "particles/econ/items/necrolyte/necronub_death_pulse/necrolyte_pulse_ka_enemy_explosion.vpcf"
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

function pugna_m2:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        if hTarget then

            local particle_cast = "particles/econ/items/necrolyte/necronub_death_pulse/necrolyte_pulse_ka_enemy_explosion.vpcf"
            local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(effect_cast, 0, hTarget:GetAbsOrigin())
            ParticleManager:SetParticleControl(effect_cast, 3, hTarget:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(effect_cast)

            local dmgTable = {
                victim = hTarget,
                attacker = self.caster,
                damage = self.dmg,
                damage_type = self:GetAbilityDamageType(),
                ability = self,
            }

            ApplyDamage(dmgTable)

            EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Hero_Necrolyte.ProjectileImpact", self.caster)

            hTarget:AddNewModifier(
                self.caster, -- player source
                self, -- ability source
                "m2_dot_pugna", -- modifier name
                {
                    duration = self:GetSpecialValueFor( "dot_duration" ),
                } -- kv
            )

            return true
        end
    end
end
------------------------------------------------------------------------------------------------
