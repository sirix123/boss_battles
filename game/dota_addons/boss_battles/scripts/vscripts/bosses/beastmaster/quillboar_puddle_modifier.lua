quillboar_puddle_modifier = class({})

--------------------------------------------------------------------------------
function quillboar_puddle_modifier:IsHidden()
	return false
end

--------------------------------------------------------------------------------
function quillboar_puddle_modifier:OnCreated(kv)
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.dmg = self:GetAbility():GetSpecialValueFor("damage")
	self.tick_rate = self:GetAbility():GetSpecialValueFor("tick_rate")

	if IsServer() then

		self:PlayEffects()

		self:StartIntervalThink(self.tick_rate)

	end
end

--------------------------------------------------------------------------------
function quillboar_puddle_modifier:OnIntervalThink()
	if IsServer() then
		local enemies = FindUnitsInRadius(
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

		for _,enemy in pairs(enemies) do
			-- apply damage
			self.damageTable = {
				victim = enemy,
				attacker = self:GetParent(),
				damage = self.dmg,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}

			ApplyDamage( self.damageTable )
		end

		local units = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			3500,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_ALL,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
			FIND_ANY_ORDER,	-- int, order filter
			false	-- bool, can grow cache
		)

		if units == nil or #units == 0 then
			self:Destroy()
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
end

function quillboar_puddle_modifier:OnDestroy( kv )
	if IsServer() then
		ParticleManager:DestroyParticle(self.nFXIndex_1,true)
		ParticleManager:DestroyParticle(self.nFXIndex_2,true)
		self:StartIntervalThink(-1)
        UTIL_Remove( self:GetParent() )
	end
end
