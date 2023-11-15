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

        return true
    end
end
---------------------------------------------------------------------------

function rat_m2:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function rat_m2:OnSpellStart()
    if IsServer() then

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local hTarget = self:GetCursorTarget()

        self.dmg = self:GetSpecialValueFor( "dmg" )

        EmitSoundOnLocationWithCaster(self.caster:GetAbsOrigin(), "Hero_Hoodwink.Boomerang.Cast", self.caster)

        local info = {
            Target = hTarget,
            Source = self:GetCaster(),
            Ability = self,	
            iMoveSpeed = self:GetSpecialValueFor( "proj_speed" ),
            EffectName = "particles/units/heroes/hero_hoodwink/hoodwink_boomerang.vpcf",
            bDodgeable = false,                           -- Optional
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            vSourceLoc = origin,                -- Optional (HOW)
            bDrawsOnMinimap = false,                          -- Optional
            bVisibleToEnemies = true,                         -- Optional
            bProvidesVision = true,                           -- Optional
            iVisionRadius = self:GetSpecialValueFor( "projectile_vision" ),                              -- Optional
            iVisionTeamNumber = self:GetCaster():GetTeamNumber(),        -- Optional
            ExtraData =
            {
                bFirstCast = 1
            }
        }

        ProjectileManager:CreateTrackingProjectile( info )

	end
end
----------------------------------------------------------------------------------------------------------------

function rat_m2:OnProjectileHit_ExtraData( hTarget, vLocation, ExtraData)
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

            if self.stacks == 5 and ExtraData.bFirstCast == 1 then

                local units = FindUnitsInRadius(
                    self:GetCaster():GetTeamNumber(),
                    hTarget:GetAbsOrigin(),
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
                        ExtraData =
                        {
                            bFirstCast = 0
                        }
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
                        ExtraData =
                        {
                            bFirstCast = 0
                        }
                    }

                    ProjectileManager:CreateTrackingProjectile( info )

                end
            end

            return true
        end
    end
end
------------------------------------------------------------------------------------------------
