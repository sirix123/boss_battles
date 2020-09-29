fire_bomb_ground_modifier = class({})

--------------------------------------------------------------------------------
function fire_bomb_ground_modifier:IsHidden()
	return false
end

--------------------------------------------------------------------------------
function fire_bomb_ground_modifier:OnCreated(kv)
    if IsServer() then

        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        self.radius = kv.radius
        self.dmg = kv.dmg

        --self.locationVector = Vector(kv.x,kv.y,kv.z)

        self:PlayEffects()

        self.damage_interval = 1
		self.stopDamageLoop = false

		self:DamageLoop()
		self:StartIntervalThink(0.5)
	end
end
--------------------------------------------------------------------------------

function fire_bomb_ground_modifier:DamageLoop()
    if IsServer() then

        Timers:CreateTimer(self.damage_interval, function()
            if self.stopDamageLoop == true then
                return false
            end

            local units = FindUnitsInRadius(
                self.caster:GetTeamNumber(),	-- int, your team number
                self.parent:GetAbsOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
                0,	-- int, order filter
                false	-- bool, can grow cache
            )

            for _, unit in pairs(units) do
                self.dmgTable = {
                    victim = unit,
                    attacker = self.caster,
                    damage = self.dmg,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    ability = self,
                }

                ApplyDamage(self.dmgTable)
            end

            return self.damage_interval
        end)

    end
end

--------------------------------------------------------------------------------
function fire_bomb_ground_modifier:OnIntervalThink()
    if IsServer() then


		local areAllHeroesDead = true --start on true, then set to false if you find one hero alive.
		local heroes = HeroList:GetAllHeroes()
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
function fire_bomb_ground_modifier:PlayEffects()

	--  raidus that affects players is not linked to particel radisu need to change that as well in particle manager
	local particle_cast = "particles/techies/jakiro_ti10_macropyre_line_flames.vpcf"
	self.nFXIndex_1 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN , self:GetParent()  )
    ParticleManager:SetParticleControl( self.nFXIndex_1, 0, self:GetParent():GetAbsOrigin() )
    ParticleManager:SetParticleControl( self.nFXIndex_1, 1, self:GetParent():GetAbsOrigin() )
    ParticleManager:ReleaseParticleIndex( self.nFXIndex_1 )

    local particle_cast = "particles/techies/techies_firebomb_viper_poison_crimson_debuff_ti7_puddle.vpcf"
	self.nFXIndex_2 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN , self:GetParent()  )
	ParticleManager:SetParticleControl( self.nFXIndex_2, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( self.nFXIndex_2 )

end

function fire_bomb_ground_modifier:OnDestroy( kv )
	if IsServer() then
        ParticleManager:DestroyParticle(self.nFXIndex_1,true)
        ParticleManager:DestroyParticle(self.nFXIndex_2,true)
        self.stopDamageLoop = true
		self:StartIntervalThink(-1)
        UTIL_Remove( self:GetParent() )
	end
end
