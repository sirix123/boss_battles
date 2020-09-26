oil_leak_modifier_thinker = class({})

--------------------------------------------------------------------------------
function oil_leak_modifier_thinker:IsHidden()
	return false
end

--------------------------------------------------------------------------------
function oil_leak_modifier_thinker:OnCreated(kv)
    if IsServer() then

        self.radius = 200
        self.dmg = 20

        self:PlayEffects()

        self.damage_interval = 1
		self.stopDamageLoop = false
		self.parent = self:GetParent()

		self:DamageLoop()
		self:StartIntervalThink(0.5)
	end
end
--------------------------------------------------------------------------------

function oil_leak_modifier_thinker:DamageLoop()
    if IsServer() then

        Timers:CreateTimer(self.damage_interval, function()
            if self.stopDamageLoop == true then
                return false
            end

            local units = FindUnitsInRadius(
                self.parent:GetTeamNumber(),	-- int, your team number
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
                    attacker = self:GetParent(),
                    damage = self.dmg,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                }

                ApplyDamage(self.dmgTable)
            end

            return self.damage_interval
        end)

    end
end

--------------------------------------------------------------------------------
function oil_leak_modifier_thinker:OnIntervalThink()
    if IsServer() then
        -- check for sticky bomb unit
        -- get unit with sticky bomb
        -- check duration remaining
        -- creat a timer with the duration remaining
        -- when timer runs destroy this puddle
        -- play a fire effect


        --[[
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
        end]]

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
function oil_leak_modifier_thinker:PlayEffects()

	--  raidus that affects players is not linked to particel radisu need to change that as well in particle manager
	local particle_cast = "particles/techies/techies_oil_slick_viper_poison_crimson_debuff_ti7_puddle.vpcf"
	self.nFXIndex_1 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN , self:GetParent()  )
	ParticleManager:SetParticleControl( self.nFXIndex_1, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( self.nFXIndex_1 )

	--[[local particle_cast = "particles/beastmaster/viper_poison_crimson_debuff_ti7_puddle_bubble.vpcf"
	self.nFXIndex_2 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN , self:GetParent()  )
	ParticleManager:SetParticleControl( self.nFXIndex_2, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( self.nFXIndex_2 )]]

	--[[local particle_cast = "particles/techies/oil_click_viper_immortal_ti8_nethertoxin_bubbles.vpcf"
	self.nFXIndex_3 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN , self:GetParent()  )
	ParticleManager:SetParticleControl( self.nFXIndex_3, 0, self:GetParent():GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( self.nFXIndex_3 )]]

end

function oil_leak_modifier_thinker:OnDestroy( kv )
	if IsServer() then
		ParticleManager:DestroyParticle(self.nFXIndex_1,true)
		--ParticleManager:DestroyParticle(self.nFXIndex_2,true)
        --ParticleManager:DestroyParticle(self.nFXIndex_3,true)
        self.stopDamageLoop = true
		self:StartIntervalThink(-1)
        UTIL_Remove( self:GetParent() )
	end
end
