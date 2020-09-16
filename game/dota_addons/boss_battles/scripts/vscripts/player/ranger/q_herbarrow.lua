q_herbarrow = class({})
LinkLuaModifier("q_herbarrow_modifier", "player/ranger/modifiers/q_herbarrow_modifier", LUA_MODIFIER_MOTION_NONE)

function q_herbarrow:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.0)

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
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function q_herbarrow:OnSpellStart()
    if IsServer() then
        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- init
        self.caster = self:GetCaster()
        self.duration = self:GetSpecialValueFor( "duration" )
		self.target = self:GetCursorTarget()
        self.bounce_range = self:GetSpecialValueFor( "bounce_range" )
        self.speed = self:GetSpecialValueFor( "speed" )
		self.max_bounces = self:GetSpecialValueFor( "max_bounces" )
		self.heal_amount = self:GetSpecialValueFor( "heal_amount" )
		self.dmg = self:GetSpecialValueFor( "dmg" )
		self.nbounceCount = 0
		self.hitEnts ={}

        -- create projectile
        local info = {
            EffectName = "particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile.vpcf",
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
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_bow_mid", self:GetCaster():GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_bow_mid", self:GetCaster():GetOrigin(), true )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		-- add hit target to table
		table.insert(self.hitEnts, self.target)

	end
end
---------------------------------------------------------------------------

function q_herbarrow:OnProjectileHit( hTarget, vLocation)
	if IsServer() then

		local impact_particle = "particles/ranger/q_herbaroow_medusa_mystic_snake_impact.vpcf"
		local particle_friendly = ParticleManager:CreateParticle(impact_particle, PATTACH_ABSORIGIN_FOLLOW, hTarget)
		ParticleManager:SetParticleControl(particle_friendly, 0, hTarget:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_friendly, 1, hTarget:GetAbsOrigin())

		hTarget:EmitSound("Hero_Medusa.MysticSnake.Target")

		-- get unit hits team
		local hTargetsTeam = hTarget:GetTeam()

		-- target = casters team then heal
		if hTargetsTeam == self.caster:GetTeam() then
			-- heal target
			hTarget:Heal(self.heal_amount, self.caster)

		-- damage target
		else
			local dmgTable = {
				victim = hTarget,
				attacker = self.caster,
				damage = self.dmg,
				damage_type = self:GetAbilityDamageType(),
			}

			ApplyDamage(dmgTable)

			if self.caster:HasModifier("r_explosive_tip_modifier") then
				local hbuff = self.caster:FindModifierByNameAndCaster("r_explosive_tip_modifier", self.caster)
				local flBuffTimeRemaining = hbuff:GetRemainingTime()
				hTarget:AddNewModifier(self.caster, self, "r_explosive_tip_modifier_target", {duration = flBuffTimeRemaining})
			end

		end

		-- if we have bounces
		if self.nbounceCount < self.max_bounces then
			local target_team = hTargetsTeam -- only bounce between intial targets team
			local target_type = self:GetAbilityTargetType()
			local target_flags = DOTA_UNIT_TARGET_FLAG_NONE --DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
			local bounce_targets = FindUnitsInRadius(hTargetsTeam, hTarget:GetAbsOrigin(), nil, self.bounce_range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, target_type, target_flags, FIND_CLOSEST, false) 
			local hit_helper

			if #bounce_targets > 1 then
				for _, v in ipairs(bounce_targets) do
					hit_helper = true
					local hit_check = false -- has the target been hit before?

					-- check if target is on the targets team or not
					if v:GetTeam() ~= target_team then
						break
					end

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
							EffectName = "particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile.vpcf",
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