rat_m2 = class({})

function rat_m2:GetCastPoint()
	local caster = self:GetCaster()
    local ability_cast_point = self.BaseClass.GetCastPoint(self)

	self.stacks = 0
	if caster:HasModifier("rat_stacks") then
		self.stacks = caster:GetModifierStackCount("rat_stacks", caster)
	end

    local rat_stack_cp_reduction = self:GetCaster():FindAbilityByName("rat_passive"):GetSpecialValueFor( "castpoint_reduction" ) / 100

    if self.stacks > 0 then

        ability_cast_point = ability_cast_point / (( self.stacks * rat_stack_cp_reduction ) + 1 )

        return ability_cast_point
    else
        return ability_cast_point
    end
end
--------------------------------------------------------------------------------

function rat_m2:OnAbilityPhaseStart()
    if IsServer() then

        --[[self.cast_twice = false
        if self.stacks ~= nil then
            if self.stacks >= 5 then
                self.randomNumber = RandomInt(1,2)
                if self.randomNumber > 1 then
                    self.cast_twice = true
                    --print("casitng twice")
                end
            end
        end]]

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 0.4)

        if self:GetCaster():HasModifier("stim_pack_buff") == true then
            -- add casting modifier
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
            {
                duration = self:GetCastPoint(),
                pMovespeedReduction = 0,
            })
        else
            -- add casting modifier
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
            {
                duration = self:GetCastPoint(),
                bMovementLock = true,
                pMovespeedReduction = 0,
            })
        end

        --print("cast_point ",self:GetCastPoint())

        return true
    end
end
---------------------------------------------------------------------------

function rat_m2:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function rat_m2:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        --self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = self:GetSpecialValueFor( "proj_speed" )

        self.dmg = self:GetSpecialValueFor( "dmg" )

        EmitSoundOnLocationWithCaster(self.caster:GetAbsOrigin(), "Hero_Hoodwink.Boomerang.Cast", self.caster)

        -- set proj direction to mouse location
        local vTargetPos = nil
        vTargetPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

        local projectile = {
            EffectName = "particles/rat/rat_hoodwink_boomerang.vpcf",
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

                    ApplyDamage(dmgTable)

                end

                EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "Hero_Hoodwink.Boomerang.Target", self.caster)

                if self.stacks == 5 then

                    local units = FindUnitsInRadius(
                        self:GetCaster():GetTeamNumber(),
                        unit:GetAbsOrigin(),
                        nil,
                        900,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_CLOSEST,
                        false)

                    if #units >= 2 then

                        local info = {
                            EffectName = "particles/units/heroes/hero_hoodwink/hoodwink_boomerang.vpcf",
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
                            EffectName = "particles/units/heroes/hero_hoodwink/hoodwink_boomerang.vpcf",
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
                local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_impact.vpcf"
                local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
                ParticleManager:SetParticleControl(effect_cast, 0, pos)
                ParticleManager:ReleaseParticleIndex(effect_cast)
            end,
        }

        Projectiles:CreateProjectile(projectile)

	end
end
----------------------------------------------------------------------------------------------------------------

function rat_m2:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        if hTarget then

            local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_impact.vpcf"
            local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(effect_cast, 0, hTarget:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(effect_cast)

            local dmgTable = {
                victim = hTarget,
                attacker = self.caster,
                damage = self.dmg,
                damage_type = self:GetAbilityDamageType(),
                ability = self,
            }

            ApplyDamage(dmgTable)

            EmitSoundOnLocationWithCaster(hTarget:GetAbsOrigin(), "Hero_Hoodwink.Boomerang.Target", self.caster)

            return true
        end
    end
end
------------------------------------------------------------------------------------------------
