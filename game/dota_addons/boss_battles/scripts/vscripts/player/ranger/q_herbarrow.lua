q_herbarrow = class({})
LinkLuaModifier("q_herbarrow_modifier", "player/ranger/modifiers/q_herbarrow_modifier", LUA_MODIFIER_MOTION_NONE)

function q_herbarrow:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function q_herbarrow:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function q_herbarrow:OnSpellStart()
    if IsServer() then
        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- init
        self.caster = self:GetCaster()
        self.duration = self:GetSpecialValueFor( "duration" )
		self.target = self:GetCursorTarget()
        self.bounce_range = 3000
        self.speed = 800
        self.max_bounces = 5
		self.nbounceCount = 0
		self.hitEnts ={}

        -- create projectile
        local info = {
            EffectName = "particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile_initial.vpcf",
            Ability = self,
            iMoveSpeed = self.speed,
            Source = self:GetCaster(),
            Target = self.target,
            bDodgeable = false,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
            bProvidesVision = true,
            iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
			iVisionRadius = 300,
		}

        ProjectileManager:CreateTrackingProjectile( info )

        EmitSoundOn( "Hero_Medusa.MysticSnake.Cast", self:GetCaster() )

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_medusa/medusa_mystic_snake_cast.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "bow_mid1", self:GetCaster():GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "bow_mid1", self:GetCaster():GetOrigin(), true )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		-- add hit target to table
		table.insert(self.hitEnts, self.target)

	end
end
---------------------------------------------------------------------------

function q_herbarrow:OnProjectileHit( hTarget, vLocation)
	if IsServer() then

		-- if we have bounces
		if self.nbounceCount < self.max_bounces then
			local target_team = self:GetAbilityTargetTeam()
			local target_type = self:GetAbilityTargetType() 
			local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
			local bounce_targets = FindUnitsInRadius(self.caster:GetTeam(), hTarget:GetAbsOrigin(), nil, self.bounce_range, target_team, target_type, target_flags, FIND_CLOSEST, false) 
			local hit_helper

			if #bounce_targets > 1 then
				for _, v in ipairs(bounce_targets) do
					hit_helper = true
					local hit_check = false -- has the target been hit before?

					-- check if target has been hit before
					for _, k in ipairs(self.hitEnts) do
						if v == k then
							hit_check = true
							break
						end
					end

					-- if it wasnt hit shoot another snake
					if not hit_check then
						local projectile_info =
						{
							EffectName = "particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile_initial.vpcf",
							Ability = self,
							vSpawnOrigin = hTarget:GetAbsOrigin(),
							Target = v,
							Source = hTarget,
							bHasFrontalCone = false,
							iMoveSpeed = self.speed,
							bReplaceExisting = false,
							bProvidesVision = true,
							iVisionRadius = 300,
							iVisionTeamNumber = self:GetCaster():GetTeamNumber()
							
						}

						ProjectileManager:CreateTrackingProjectile(projectile_info)
						table.insert(self.hitEnts, v)
						-- Increase the jump count and update the helper variable
						self.nbounceCount = self.nbounceCount + 1
						hit_helper = false
						break
					end
				end
			end
		end
	end
end
---------------------------------------------------------------------------

-- TODO 
-- add function here to add modifier when it hits a target and play effect when it hits a target