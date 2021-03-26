oil_drop_thinker = class({})

--------------------------------------------------------------------------------
function oil_drop_thinker:IsHidden()
	return false
end

function oil_drop_thinker:GetTexture()
	return "alchemist_acid_spray"
end

--------------------------------------------------------------------------------
function oil_drop_thinker:OnCreated(kv)
	self.radius = 150
	self.tick_rate = 0.2

	if IsServer() then
        self:PlayEffects()
        self:StartIntervalThink(self.tick_rate)
	end
end

--------------------------------------------------------------------------------
function oil_drop_thinker:OnIntervalThink()
	if IsServer() then
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

		for _,unit in pairs(units) do
            -- apply slow
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

	end
end

--------------------------------------------------------------------------------
function oil_drop_thinker:PlayEffects()

	--  raidus that affects players is not linked to particel radisu need to change that as well in particle manager
	local particle_cast = "particles/beastmaster/viper_poison_crimson_debuff_ti7_puddle.vpcf"
	self.nFXIndex_1 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN , self:GetParent()  )
	ParticleManager:SetParticleControl( self.nFXIndex_1, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( self.nFXIndex_1 )

	local particle_cast = "particles/beastmaster/viper_poison_crimson_debuff_ti7_puddle_bubble.vpcf"
	self.nFXIndex_2 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN , self:GetParent()  )
	ParticleManager:SetParticleControl( self.nFXIndex_2, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( self.nFXIndex_2 )

	local particle_cast = "particles/beastmaster/boar_viper_immortal_ti8_nethertoxin_bubbles.vpcf"
	self.nFXIndex_3 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN , self:GetParent()  )
	ParticleManager:SetParticleControl( self.nFXIndex_3, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( self.nFXIndex_3 )

end

function oil_drop_thinker:OnDestroy( kv )
	if IsServer() then
		ParticleManager:DestroyParticle(self.nFXIndex_1,true)
		ParticleManager:DestroyParticle(self.nFXIndex_2,true)
		ParticleManager:DestroyParticle(self.nFXIndex_3,true)
		self:StartIntervalThink(-1)
        UTIL_Remove( self:GetParent() )
	end
end
