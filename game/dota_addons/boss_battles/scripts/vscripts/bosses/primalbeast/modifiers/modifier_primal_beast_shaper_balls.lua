modifier_primal_beast_shaper_balls = class({})

function modifier_primal_beast_shaper_balls:Precache( context )
	PrecacheResource( "particle", "particles/primalbeast/primal_warlock_upheaval.vpcf", context )
	PrecacheResource( "particle", "particles/primalbeast/primal_underlord_2021_immortal_portal.vpcf", context )
	--PrecacheResource( "particle", "particles/beastmaster/boar_viper_immortal_ti8_nethertoxin_bubbles.vpcf", context )
end

--------------------------------------------------------------------------------
function modifier_primal_beast_shaper_balls:IsHidden()
	return false
end

function modifier_primal_beast_shaper_balls:GetTexture()
	return "alchemist_acid_spray"
end

--------------------------------------------------------------------------------
function modifier_primal_beast_shaper_balls:OnCreated(kv)
	if IsServer() then
		self.radius = kv.radius
		self.dmg = kv.damage
		self.tick_rate = kv.tick_rate

		self.currentTarget = Vector( kv.target_x, kv.target_y, kv.target_z )

		self.stopDamageLoop = false

		self:PlayEffects1()
		self.timer_1 = Timers:CreateTimer(kv.delay, function()
            if self.nFXIndex_4 then
                ParticleManager:DestroyParticle(self.nFXIndex_4,true)
            end
            self:PlayEffects2()
			self:StartIntervalThink(self.tick_rate)
			return false
		end)

		self.timer = Timers:CreateTimer(function()

			if self.stopDamageLoop == true then
				return false
			end

			local areAllHeroesDead = true --start on true, then set to false if you find one hero alive.
			local heroes = HERO_LIST--HeroList:GetAllHeroes()
			for _, hero in pairs(heroes) do
				if hero.playerLives > 0 then
					areAllHeroesDead = false
					break
				end
			end
			if areAllHeroesDead then
				--Timers:CreateTimer(1.0, function()
					self:Destroy()
				--end)
			end


			return 0.1
		end)
	end
end

--------------------------------------------------------------------------------
function modifier_primal_beast_shaper_balls:OnIntervalThink()
	if IsServer() then
		local units = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
			FIND_ANY_ORDER,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,unit in pairs(units) do
			-- apply damage
			self.damageTable = {
				victim = unit,
				attacker = self:GetCaster(),
				damage = self.dmg,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = self:GetAbility(),
			}

			ApplyDamage( self.damageTable )

			-- unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "puddle_slow_modifier", {duration = 3})

		end
	end
end

--------------------------------------------------------------------------------
function modifier_primal_beast_shaper_balls:PlayEffects2()
	if IsServer() then
		--  raidus that affects players is not linked to particel radisu need to change that as well in particle manager
		local ground_pos = GetGroundPosition(self:GetParent():GetAbsOrigin(), nil)

		local particle_cast = "particles/primalbeast/primal_warlock_upheaval.vpcf"
		self.nFXIndex_1 = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN , self:GetParent()  )
		ParticleManager:SetParticleControl( self.nFXIndex_1, 0, ground_pos )
        ParticleManager:SetParticleControl( self.nFXIndex_1, 1, Vector(self.radius,0,0) )
		--ParticleManager:ReleaseParticleIndex( self.nFXIndex_1 )

		-- local particle_cast = "particles/beastmaster/boar_viper_immortal_ti8_nethertoxin_bubbles.vpcf"
		-- self.nFXIndex_3 = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN , self:GetParent()  )
		-- ParticleManager:SetParticleControl( self.nFXIndex_3, 0, ground_pos )
		-- --ParticleManager:ReleaseParticleIndex( self.nFXIndex_3 )
	end
end

function modifier_primal_beast_shaper_balls:PlayEffects1()
	if IsServer() then
        local particle_cast = "particles/primalbeast/primal_underlord_2021_immortal_portal.vpcf"
        self.nFXIndex_4 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN , self:GetParent()  )
		ParticleManager:SetParticleControl( self.nFXIndex_4, 0, Vector (self.currentTarget.x, self.currentTarget.y, self.currentTarget.z + 150))
	end
end

function modifier_primal_beast_shaper_balls:OnDestroy( kv )
	if IsServer() then

		self.stopDamageLoop = true
		if self.nFXIndex_1 then
			ParticleManager:DestroyParticle(self.nFXIndex_1,true)
		end

		if self.nFXIndex_2 then
			ParticleManager:DestroyParticle(self.nFXIndex_2,true)
		end

		if self.nFXIndex_3 then
			ParticleManager:DestroyParticle(self.nFXIndex_3,true)
		end
		self:StartIntervalThink(-1)
		Timers:RemoveTimer(self.timer)
		Timers:RemoveTimer(self.timer_1)
        UTIL_Remove( self:GetParent() )
	end
end
