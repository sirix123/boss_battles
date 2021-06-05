quillboar_puddle_modifier = class({})

--------------------------------------------------------------------------------
function quillboar_puddle_modifier:IsHidden()
	return false
end

function quillboar_puddle_modifier:GetTexture()
	return "alchemist_acid_spray"
end

--------------------------------------------------------------------------------
function quillboar_puddle_modifier:OnCreated(kv)
	if IsServer() then
		self.radius = self:GetAbility():GetSpecialValueFor("radius")
		self.dmg = self:GetAbility():GetSpecialValueFor("damage")
		self.tick_rate = self:GetAbility():GetSpecialValueFor("tick_rate")

		self:PlayEffects()
		self.timer_1 = Timers:CreateTimer(1.5, function()
			self:StartIntervalThink(self.tick_rate)
			return false
		end)

		self.timer = Timers:CreateTimer(function()

			local units = FindUnitsInRadius(
				self:GetParent():GetTeamNumber(),	-- int, your team number
				self:GetParent():GetOrigin(),	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
				DOTA_UNIT_TARGET_ALL,	-- int, type filter
				DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
				FIND_ANY_ORDER,	-- int, order filter
				false	-- bool, can grow cache
			)

			for _,unit in pairs(units) do
				if unit:GetUnitName() ~= "npc_beastmaster" then
					unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "puddle_slow_modifier", {duration = 8})
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
function quillboar_puddle_modifier:OnIntervalThink()
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
			-- apply damage
			self.damageTable = {
				victim = unit,
				attacker = self:GetParent(),
				damage = self.dmg,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = self,
			}

			ApplyDamage( self.damageTable )

			unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "puddle_slow_modifier", {duration = 3})

		end
	end
end

--------------------------------------------------------------------------------
function quillboar_puddle_modifier:PlayEffects()

	--  raidus that affects players is not linked to particel radisu need to change that as well in particle manager
	local ground_pos = GetGroundPosition(self:GetParent():GetAbsOrigin(), nil)

	local particle_cast = "particles/beastmaster/viper_poison_crimson_debuff_ti7_puddle.vpcf"
	self.nFXIndex_1 = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN , self:GetParent()  )
	ParticleManager:SetParticleControl( self.nFXIndex_1, 0, ground_pos )
	--ParticleManager:ReleaseParticleIndex( self.nFXIndex_1 )

	local particle_cast = "particles/beastmaster/viper_poison_crimson_debuff_ti7_puddle_bubble.vpcf"
	self.nFXIndex_2 = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN , self:GetParent()  )
	ParticleManager:SetParticleControl( self.nFXIndex_2, 0, ground_pos )
	--ParticleManager:ReleaseParticleIndex( self.nFXIndex_2 )

	local particle_cast = "particles/beastmaster/boar_viper_immortal_ti8_nethertoxin_bubbles.vpcf"
	self.nFXIndex_3 = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN , self:GetParent()  )
	ParticleManager:SetParticleControl( self.nFXIndex_3, 0, ground_pos )
	--ParticleManager:ReleaseParticleIndex( self.nFXIndex_3 )

end

function quillboar_puddle_modifier:OnDestroy( kv )
	if IsServer() then
		ParticleManager:DestroyParticle(self.nFXIndex_1,true)
		ParticleManager:DestroyParticle(self.nFXIndex_2,true)
		ParticleManager:DestroyParticle(self.nFXIndex_3,true)
		self:StartIntervalThink(-1)
		Timers:RemoveTimer(self.timer)
		Timers:RemoveTimer(self.timer_1)
        UTIL_Remove( self:GetParent() )
	end
end
