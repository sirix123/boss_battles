chain_light_v2 = class({})

LinkLuaModifier("stunned_modifier", "player/generic/stunned_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("cast_electric_field", "bosses/tinker/modifiers/cast_electric_field", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier("electric_encase_rocks", "bosses/tinker/modifiers/electric_encase_rocks", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier("chain_light_buff_elec", "bosses/tinker/modifiers/chain_light_buff_elec", LUA_MODIFIER_MOTION_NONE  )

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

            local particle = "particles/tinker/elec_overhead_icon.vpcf"
            self.head_particle = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self.target)
            ParticleManager:SetParticleControl(self.head_particle, 0, self.target:GetAbsOrigin())

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

		ParticleManager:DestroyParticle(self.head_particle,true)

        -- init
        self.caster = self:GetCaster()
        self.duration = self:GetSpecialValueFor( "duration" )
        self.bounce_range = self:GetSpecialValueFor( "bounce_range" )
        self.speed = self:GetSpecialValueFor( "speed" )
		self.max_bounces = self:GetSpecialValueFor( "max_bounces" )
		self.dmg = self:GetSpecialValueFor( "dmg" )
		self.nbounceCount = 0
		self.hitEnts ={}

        -- create projectile
        local info = {
            EffectName = "particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf",
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

        EmitSoundOn( "Hero_Zuus.ArcLightning.Cast", self:GetCaster() )

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		-- add hit target to table
		table.insert(self.hitEnts, self.target)

	end
end
---------------------------------------------------------------------------

function chain_light_v2:OnProjectileHit( hTarget, vLocation)
	if IsServer() then
		if hTarget == nil then return end

		EmitSoundOn("Hero_Zuus.ArcLightning.Target", hTarget)

		-- get unit hits team
		local hTargetsTeam = hTarget:GetTeam()

		--print("hTarget:GetUnitName() ",hTarget:GetUnitName())

		-- target ~= casters team
		if hTargetsTeam == self.caster:GetTeam() then
			--print("this is working")
			if hTarget:GetUnitName() == "npc_crystal" then
				--print("npc_crystal")
				hTarget:GiveMana(10)
				hTarget:AddNewModifier( self.caster, self, "cast_electric_field", { duration = -1 } )
			elseif hTarget:GetUnitName() == "npc_ice_ele" then
				--print("npc_ice_ele")
				hTarget:AddNewModifier( self.caster, self, "stunned_modifier", { duration = 5 } )
			elseif hTarget:GetUnitName() == "npc_fire_ele" then
				hTarget:AddNewModifier( self.caster, self, "stunned_modifier", { duration = 5 } )
			elseif hTarget:GetUnitName() == "npc_elec_ele" then
				hTarget:AddNewModifier( self.caster, self, "chain_light_buff_elec", { duration = 1 } )
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

		end

		-- if we have bounces
		if self.nbounceCount < self.max_bounces then
			local target_team = hTargetsTeam -- only bounce between intial targets team
			local hit_helper

			--print("we boucning>?")

			local bounce_targets = FindUnitsInRadius(
				self:GetCaster():GetTeamNumber(),
				hTarget:GetAbsOrigin(),
				nil,
				self.bounce_range,
				DOTA_UNIT_TARGET_TEAM_BOTH,
				DOTA_UNIT_TARGET_ALL,
				DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
				FIND_CLOSEST,	-- int, order filter
				false	-- bool, can grow cache
			)

			if #bounce_targets > 1 then
				for _, v in ipairs(bounce_targets) do
					if v:GetUnitName() ~= "" and v:GetUnitName() ~= "npc_tinker" then
						hit_helper = true
						local hit_check = false -- has the target been hit before?

						--print("vunitname ", v:GetUnitName())

						--[[check if target is on the targets team or not
						if v:GetTeam() ~= target_team then
							break
						end]]

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
								EffectName = "particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf",
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
end
---------------------------------------------------------------------------