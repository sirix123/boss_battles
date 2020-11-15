prisonbeam = class({})

LinkLuaModifier("prison_modifier", "bosses/tinker/modifiers/prison_modifier", LUA_MODIFIER_MOTION_NONE)

function prisonbeam:OnAbilityPhaseStart()
	if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1.0)

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            4000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return false
        else

            for _, unit in pairs(units) do
                if unit:GetUnitName() == "npc_phase2_crystal" then
                    self.vTargetPos = unit:GetAbsOrigin()
                    self.target = unit
                end
            end

            -- play voice line
			EmitSoundOn("tinker_tink_cast_01", self:GetCaster())

            return true
        end
    end
end
---------------------------------------------------------------------------

function prisonbeam:OnSpellStart()
    if IsServer() then
        -- when spell starts fade gesture
		self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- init
        self.caster = self:GetCaster()
        self.duration = 1--self:GetSpecialValueFor( "duration" )
        self.bounce_range = 3000--self:GetSpecialValueFor( "bounce_range" )
        self.speed = 4000--self:GetSpecialValueFor( "speed" )
		self.max_bounces = 10--self:GetSpecialValueFor( "max_bounces" )
		self.nbounceCount = 0
		self.hitEnts ={}

        -- create projectile
        local info = {
            EffectName = "particles/econ/items/rubick/rubick_ti8_immortal/rubick_ti8_immortal_fade_bolt.vpcf",
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

        EmitSoundOn( "Hero_Rubick.FadeBolt.Cast", self:GetCaster() )

        local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/rubick/rubick_ti8_immortal/rubick_ti8_immortal_fade_bolt.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		-- add hit target to table
		table.insert(self.hitEnts, self.target)

	end
end
---------------------------------------------------------------------------

function prisonbeam:OnProjectileHit( hTarget, vLocation)
	if IsServer() then
		if hTarget == nil then return end

        EmitSoundOn("Hero_Rubick.FadeBolt.Target", hTarget)

        local prison_targets = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            hTarget:GetAbsOrigin(),
            nil,
            250, --self.prison_radius
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            0,	-- int, flag filter
            FIND_CLOSEST,	-- int, order filter
            false	-- bool, can grow cache
        )

        -- particle effect on ground
        local particle_cast = "particles/econ/items/rubick/rubick_arcana/rbck_arc_sandking_epicenter.vpcf"

        -- Create Particle
        local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, hTarget )
        ParticleManager:SetParticleControl( effect_cast, 0, hTarget:GetAbsOrigin() )
        ParticleManager:SetParticleControl( effect_cast, 1, Vector( 250, 250, 250 ) )
        ParticleManager:ReleaseParticleIndex( effect_cast )

        for _, enemy in pairs(prison_targets) do
            if enemy:HasModifier("prison_modifier") ~= true and enemy:HasModifier("modifier_rooted") ~= true then
                local vSpawn = Vector(enemy:GetAbsOrigin().x, enemy:GetAbsOrigin().y, enemy:GetAbsOrigin().z + 300)
                CreateUnitByName( "npc_prison", vSpawn, false, nil, nil, self:GetCaster():GetTeamNumber() )
                enemy:AddNewModifier(self.caster, self, "prison_modifier", {duration = -1})
                enemy:AddNewModifier(self.caster, self, "modifier_rooted", {duration = -1})
            end
        end

        -- if we have bounces
            if self.nbounceCount < self.max_bounces then
                local target_team = hTargetsTeam -- only bounce between intial targets team
                local hit_helper

                local bounce_targets = FindUnitsInRadius(
                    self:GetCaster():GetTeamNumber(),
                    hTarget:GetAbsOrigin(),
                    nil,
                    self.bounce_range,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
                    FIND_CLOSEST,	-- int, order filter
                    false	-- bool, can grow cache
                )

                if #bounce_targets > 1 then
                    for _, v in ipairs(bounce_targets) do
                        if v:GetUnitName() ~= "" and v:GetUnitName() == "npc_phase2_crystal" then
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
                                    EffectName = "particles/econ/items/rubick/rubick_ti8_immortal/rubick_ti8_immortal_fade_bolt.vpcf",
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