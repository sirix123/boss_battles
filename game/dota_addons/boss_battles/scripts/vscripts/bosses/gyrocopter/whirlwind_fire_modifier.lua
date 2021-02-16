whirlwind_fire_modifier = class({})

function whirlwind_fire_modifier:OnCreated(kv)
	--print("whirlwind_fire_modifier:OnCreated(kv)")

	-- self.radius = self:GetAbility():GetSpecialValueFor("radius")
	-- self.dmg = self:GetAbility():GetSpecialValueFor("damage")
	-- self.tick_rate = self:GetAbility():GetSpecialValueFor("tick_rate")
	self.radius = 150
	self.dmg = 10
	self.tick_rate = 0.01



	if IsServer() then
		self:PlayEffects()
		self:StartIntervalThink(self.tick_rate)
		--DebugDrawCircle(self:GetParent():GetAbsOrigin(),Vector(255,255,255),128,self.radius,true,1)
	end
end

--------------------------------------------------------------------------------
function whirlwind_fire_modifier:OnIntervalThink()
	if IsServer() then
		local units = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
			DOTA_UNIT_TARGET_ALL,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
			FIND_ANY_ORDER,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,unit in pairs(units) do
			--print("unit standing in fire. apply burn debuff")
			-- apply damage
			self.damageTable = {
				victim = unit,
				attacker = self:GetParent(),
				damage = self.dmg,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = self,
			}

			ApplyDamage( self.damageTable )

			--unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "puddle_slow_modifier", {duration = 1})
			--unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "whirlwind_fire_burn_modifier", {duration = 1})

		end

		--Clean up when all players are dead
		local areAllHeroesDead = true --start on true, then set to false if you find one hero alive.
		local heroes = HERO_LIST--HeroList:GetAllHeroes()
		for _, hero in pairs(heroes) do
			if hero.playerLives > 0 then
				areAllHeroesDead = false
				break
			end
		end
		if areAllHeroesDead then
			self:Destroy()
		end

	end
end

--TODO: this code is from quilboar puddle! Replace with fire
function whirlwind_fire_modifier:PlayEffects()

	--bat rider orig particle:
	--local particle_cast = "particles/gyrocopter/items/batrider/batrider_ti8_immortal_mount/batrider_ti8_immortal_firefly_path.vpcf"
	--my particle: 
	local particle_cast = "particles/gyrocopter/fire_patch_b.vpcf"

	-- ORIG: local particle_cast = "particles/beastmaster/viper_poison_crimson_debuff_ti7_puddle.vpcf"
	self.nFXIndex_1 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN , self:GetParent()  )
	ParticleManager:SetParticleControl( self.nFXIndex_1, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( self.nFXIndex_1 )


	-- local particleName = "particles/gyrocopter/macropyre.vpcf"
	-- local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, thisEntity )
	-- ParticleManager:SetParticleControl( pfx, 0, thisEntity:GetAbsOrigin() )
	-- ParticleManager:SetParticleControl( pfx, 1, endPoint )
	-- ParticleManager:SetParticleControl( pfx, 2, Vector( duration, 0, 0 ) )	



end

function whirlwind_fire_modifier:OnDestroy( kv )
	print("whirlwind_fire_modifier:OnDestroy")
	if IsServer() then
		ParticleManager:DestroyParticle(self.nFXIndex_1,true)
		self:StartIntervalThink(-1)
        UTIL_Remove( self:GetParent() )
	end
end
