-- radar_scan_modifier

-- radar_scan_modifier = class({})


-- --should potentially define this in the AbilitySpecial section of the spell declaration in gyrocopter.txt
-- radius = 150
-- dmg = 100
-- tickDmg = 10
-- tickInterval = 0.2




-- --------------------------------------------------------------------------------
-- function radar_scan_modifier:IsHidden()
-- 	return true
-- end

-- --------------------------------------------------------------------------------
-- function radar_scan_modifier:OnCreated(kv)
-- 	local radius = 150
-- 	local dmg = 100 --TODO: scale this off the lvl of ability. 
-- 	--e.g 
-- 	--self.radius = self:GetAbility():GetSpecialValueFor("radius") --define these in the AbilitySpecial section of radar_scan in gyrocopter.txt

-- 	local tickInterval = 0.2

-- 	--Particle effect:
-- 	--self.nPreviewFX = ParticleManager:CreateParticle( "particles/beastmaster/viper_poison_crimson_debuff_ti7_puddle.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )

-- 	--DebugDrawCircle(summonLocs[i], Vector(0,255,0),128,DEBUG_DRAW_RAD,true,DEBUG_DRAW_DURATION)
	
-- 	if IsServer() then
-- 		self.damageTable = {
-- 			victim = self:GetParent(),
-- 			attacker = self:GetCaster(),
-- 			damage = self.dmg ,
-- 			damage_type = DAMAGE_TYPE_MAGICAL,
-- 			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
-- 			ability = self, --Optional.
-- 		}

-- 		self:PlayEffects()

-- 		self:StartIntervalThink(self.tick_rate)

-- 	end
-- end

-- --------------------------------------------------------------------------------
-- function radar_scan_modifier:OnIntervalThink()

-- 	local enemies = FindUnitsInRadius(
-- 		DOTA_TEAM_BADGUYS,	-- int, your team number
-- 		self:GetParent():GetOrigin(),	-- point, center point
-- 		nil,	-- handle, cacheUnit. (not known)
-- 		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
-- 		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
-- 		DOTA_UNIT_TARGET_ALL,	-- int, type filter
-- 		DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
-- 		FIND_ANY_ORDER,	-- int, order filter
-- 		false	-- bool, can grow cache
-- 	)

-- 	for _,enemy in pairs(enemies) do
-- 		-- apply damage
-- 		self.damageTable.victim = enemy
-- 		ApplyDamage( self.damageTable )
-- 	end
-- end

-- --------------------------------------------------------------------------------
-- function radar_scan_modifier:PlayEffects()
-- 	ParticleManager:DestroyParticle( self.nPreviewFX, false )

-- 	-- right now ned to manually tell this particle in the editor its duration 
-- 	-- https://i.imgur.com/5fnGBzy.png
-- 	-- also raidus that affects players is not linked to particel radisu need to change that as well in particle manager
-- 	local particle_cast = "particles/beastmaster/viper_poison_crimson_debuff_ti7_puddle.vpcf"
-- 	local nFXIndex = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN , self:GetParent()  )
-- 	ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
-- 	ParticleManager:ReleaseParticleIndex( nFXIndex )

-- 	local particle_cast = "particles/beastmaster/viper_poison_crimson_debuff_ti7_puddle_bubble.vpcf"
-- 	local nFXIndex = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN , self:GetParent()  )
-- 	ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
-- 	ParticleManager:ReleaseParticleIndex( nFXIndex )
-- end
