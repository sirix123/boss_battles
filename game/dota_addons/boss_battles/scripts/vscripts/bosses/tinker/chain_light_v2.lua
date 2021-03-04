chain_light_v2 = class({})

LinkLuaModifier("modifier_generic_silenced", "core/modifier_generic_silenced", LUA_MODIFIER_MOTION_NONE)

function chain_light_v2:OnAbilityPhaseStart()
	if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1.0)

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            3000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return false
        else

            local random_unit = RandomInt(1, #units)

            self.vTargetPos = units[random_unit]:GetAbsOrigin()
            self.target = units[random_unit]

            self:GetCaster():SetForwardVector(self.vTargetPos)
            self:GetCaster():FaceTowards(self.vTargetPos)

            -- play voice line
            --EmitSoundOn("techies_tech_suicidesquad_01", self:GetCaster())

            return true
        end
    end
end
---------------------------------------------------------------------------

function chain_light_v2:OnSpellStart()
    if IsServer() then
        -- when spell starts fade gesture
		self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- init
        self.caster = self:GetCaster()
        self.duration = self:GetSpecialValueFor( "duration" )
        self.bounce_range = self:GetSpecialValueFor( "bounce_range" )
        self.speed = self:GetSpecialValueFor( "speed" )
		self.max_bounces = self:GetSpecialValueFor( "max_bounces" )
		self.dmg = self:GetSpecialValueFor( "dmg" )
		self.nbounceCount = 0
		self.hitEnts ={}
		self.crystal_been_hit = false

		EmitSoundOn("Hero_Zuus.ArcLightning.Target", hTarget)

        -- create projectile
        local info = {
            EffectName = "particles/tinker/green_tinker_missile.vpcf",
            Ability = self,
            iMoveSpeed = self.speed,
            Source = self:GetCaster(),
            Target = self.target,
            bDodgeable = true,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bProvidesVision = true,
            iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
			iVisionRadius = 300,
		}

        ProjectileManager:CreateTrackingProjectile( info )

		-- add hit target to table
		table.insert(self.hitEnts, self.target)

	end
end
---------------------------------------------------------------------------

function chain_light_v2:OnProjectileHit( hTarget, vLocation)
	if IsServer() then
		if hTarget == nil then return end

		EmitSoundOn("Hero_Zuus.ArcLightning.Target", hTarget)

		self.hit_target = hTarget

		if hTarget:GetUnitName() == "npc_crystal" or unit:GetUnitName() == "npc_rubick" and self.crystal_been_hit == false then

			self.crystal_been_hit = true

			hTarget:GiveMana(10)

			BossNumbersOnTarget(hTarget, 10, Vector(75,75,255))

			-- fire a green rocket at everyone
			local targets = FindUnitsInRadius(
				self:GetCaster():GetTeamNumber(),
				hTarget:GetAbsOrigin(),
				nil,
				4000,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO,
				DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
				FIND_CLOSEST,	-- int, order filter
				false	-- bool, can grow cache
			)

			for _, enemy in pairs(targets) do

				local projectile_info =
				{
					EffectName = "particles/tinker/green_tinker_missile.vpcf",
					Ability = self,
					vSpawnOrigin = hTarget:GetAbsOrigin(),
					Target = enemy,
					bDodgeable = true,
					Source = hTarget,
					bHasFrontalCone = false,
					iMoveSpeed = self.speed,
					bReplaceExisting = false,
					bProvidesVision = true,
					iVisionRadius = 300,
					iVisionTeamNumber = self:GetCaster():GetTeamNumber()
				}

				ProjectileManager:CreateTrackingProjectile(projectile_info)

			end

		-- damage target
		else

			local dmgTable = {
				victim = hTarget,
				attacker = self.caster,
				damage = self.dmg,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = self,
			}

			ApplyDamage(dmgTable)

			-- silence
			hTarget:AddNewModifier(self.caster, self, "modifier_generic_silenced", {duration = 5})

		end

		-- if we have bounces
		if self.nbounceCount < self.max_bounces then

			local bounce_targets = FindUnitsInRadius(
				self:GetCaster():GetTeamNumber(),
				hTarget:GetAbsOrigin(),
				nil,
				self.bounce_range,
				DOTA_UNIT_TARGET_TEAM_BOTH,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
				DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
				FIND_CLOSEST,	-- int, order filter
				false	-- bool, can grow cache
			)

			if #bounce_targets > 1 then
				for _, v in ipairs(bounce_targets) do
					if v:GetUnitName() ~= "" and v:GetUnitName() ~= "npc_tinker" and self.hit_target:GetUnitName() ~= v:GetUnitName() and v ~= "npc_rock" and unit:GetUnitName() ~= "npc_rubick" then
						--local hit_check = false -- has the target been hit before?

						--[[ check if target has been hit before
						for _, k in ipairs(self.hitEnts) do
							if v == k then
								hit_check = true
								break
							end
						end]]

						-- if it wasnt hit shoot another snake
						--if not hit_check then
							local projectile_info =
							{
								EffectName = "particles/tinker/green_tinker_missile.vpcf",
								Ability = self,
								vSpawnOrigin = hTarget:GetAbsOrigin(),
								Target = v,
								bDodgeable = true,
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
							self.nbounceCount = self.nbounceCount + 1
							break
						--end
					end
				end
			end
		end
	end
end
---------------------------------------------------------------------------