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
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.dmg = self:GetAbility():GetSpecialValueFor("damage")
	self.tick_rate = self:GetAbility():GetSpecialValueFor("tick_rate")

	if IsServer() then

		self:PlayEffects()
		Timers:CreateTimer(1.0, function()
			self:StartIntervalThink(self.tick_rate)
		--DebugDrawCircle(self:GetParent():GetAbsOrigin(),Vector(255,255,255),128,self.radius,true,1)
			return false
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
			DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
			DOTA_UNIT_TARGET_ALL,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
			FIND_ANY_ORDER,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,unit in pairs(units) do

			if unit:GetUnitName() ~= "npc_beastmaster" and unit:GetUnitName() ~= "npc_beastmaster_bear" and unit:GetUnitName() ~= "npc_quilboar"then

				-- apply damage
				self.damageTable = {
					victim = unit,
					attacker = self:GetParent(),
					damage = self.dmg,
					damage_type = DAMAGE_TYPE_PHYSICAL,
					ability = self,
				}

				ApplyDamage( self.damageTable )

			end

			if unit:GetUnitName() ~= "npc_beastmaster" then

				unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "puddle_slow_modifier", {duration = 5})

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

	end
end

--------------------------------------------------------------------------------
function quillboar_puddle_modifier:PlayEffects()

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

function quillboar_puddle_modifier:OnDestroy( kv )
	if IsServer() then
		ParticleManager:DestroyParticle(self.nFXIndex_1,true)
		ParticleManager:DestroyParticle(self.nFXIndex_2,true)
		ParticleManager:DestroyParticle(self.nFXIndex_3,true)
		self:StartIntervalThink(-1)
        UTIL_Remove( self:GetParent() )
	end
end
