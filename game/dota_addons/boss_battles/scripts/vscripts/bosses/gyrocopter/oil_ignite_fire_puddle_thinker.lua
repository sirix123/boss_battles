oil_ignite_fire_puddle_thinker = class({})
LinkLuaModifier( "fire_puddle_modifier", "bosses/gyrocopter/fire_puddle_modifier", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function oil_ignite_fire_puddle_thinker:IsHidden()
	return false
end

function oil_ignite_fire_puddle_thinker:GetTexture()
	return "batrider_sticky_napalm"
end

--------------------------------------------------------------------------------
function oil_ignite_fire_puddle_thinker:OnCreated(kv)
	self.radius = 150
	self.tick_rate = 0.2
	self.dmg = 10

	if IsServer() then
        self:PlayEffects()
        self:StartIntervalThink(self.tick_rate)
	end
end

--------------------------------------------------------------------------------
function oil_ignite_fire_puddle_thinker:OnIntervalThink()
	if IsServer() then

		if self:GetParent() == nil then self:Destroy() end

		local units = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_ALL,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
			FIND_ANY_ORDER,	-- int, order filter
			false	-- bool, can grow cache
		)

		if units ~= nil and #units ~= 0 then
			for _,unit in pairs(units) do
				unit:AddNewModifier( self:GetCaster(), self:GetAbility(), "fire_puddle_modifier", { duration = 3 } )
			end
		end


		local areAllHeroesDead = true --start on true, then set to false if you find one hero alive.
		local heroes = HERO_LIST--HeroList:GetAllHeroes()
		for _, hero in pairs(heroes) do
			if hero.playerLives > 0 then
				areAllHeroesDead = false
				break
			end
		end

		if areAllHeroesDead or IsValidEntity(self:GetCaster()) == false then
			--Timers:CreateTimer(1.0, function()
				self:Destroy()
			--end)
		end

	end
end

--------------------------------------------------------------------------------
function oil_ignite_fire_puddle_thinker:PlayEffects()
	if IsServer() then
		-- at each oil thinker location, create a fire puddle
		local particle = "particles/gyrocopter/gyro_jakiro_ti10_macropyre_line_flames.vpcf"
		self.nFXIndex_1 = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN , self:GetParent())
		ParticleManager:SetParticleControl(self.nFXIndex_1, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.nFXIndex_1, 1, self:GetParent():GetAbsOrigin())
	end
end

function oil_ignite_fire_puddle_thinker:OnDestroy( kv )
	if IsServer() then
		ParticleManager:DestroyParticle(self.nFXIndex_1,true)

		local particle = "particles/units/heroes/hero_phoenix/phoenix_supernova_death_steam.vpcf"
		local effect_cast = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, self:GetParent() )
		ParticleManager:SetParticleControl( effect_cast, 1, self:GetParent():GetAbsOrigin() )
		ParticleManager:ReleaseParticleIndex( effect_cast )


		self:StartIntervalThink(-1)
        UTIL_Remove( self:GetParent() )
	end
end
