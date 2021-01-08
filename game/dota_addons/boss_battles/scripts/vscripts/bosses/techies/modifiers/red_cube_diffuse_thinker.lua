red_cube_diffuse_thinker = class({})

--------------------------------------------------------------------------------
function red_cube_diffuse_thinker:IsHidden()
	return true
end

--------------------------------------------------------------------------------
function red_cube_diffuse_thinker:OnCreated(kv)
    if IsServer() then

        self.parent = self:GetParent()

        self.radius = 400

        self.player = kv.player
        print("red cube diffuser player = ", self.player:GetUnitName())

        self:PlayEffects()
        self:StartIntervalThink(0.01)

	end
end
--------------------------------------------------------------------------------

function red_cube_diffuse_thinker:OnIntervalThink()
    if IsServer() then

        local units = FindUnitsInRadius(
			self:GetParent():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_ALL,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
        )

        for _, unit in pairs(units) do
            if unit:HasModifier("red_cube_modifier") then

                local all_units = FindUnitsInRadius(
                    self:GetParent():GetTeamNumber(),	-- int, your team number
                    self:GetParent():GetAbsOrigin(),	-- point, center point
                    nil,	-- handle, cacheUnit. (not known)
                    8000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_DEAD,	-- int, flag filter
                    0,	-- int, order filter
                    false	-- bool, can grow cache
                )

                for _, unit_all in pairs(all_units) do
                    unit_all:AddNewModifier(self:GetParent(), nil,  "red_cube_diffuse_modifier", {duration = (self:GetRemainingTime() + 1) }) -- applies protection from bombs exploding
                end

                unit:RemoveModifierByName("red_cube_modifier")

                self:Destroy()
            end
        end


		local areAllHeroesDead = true --start on true, then set to false if you find one hero alive.
		local heroes = HERO_LIST
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

--------------------------------------------------------------------------------
function red_cube_diffuse_thinker:PlayEffects()
    if IsServer() then
        local particleName_1 = "particles/clock/red_clock_npx_moveto_arrow.vpcf"
        self.pfx_1 = ParticleManager:CreateParticleForPlayer( particleName_1, PATTACH_WORLDORIGIN, self.parent, self.player )
        ParticleManager:SetParticleControl( self.pfx_1, 0, self.parent:GetAbsOrigin() )
    end
end

function red_cube_diffuse_thinker:OnDestroy( kv )
	if IsServer() then
		ParticleManager:DestroyParticle(self.pfx_1,true)
		self:StartIntervalThink(-1)
        UTIL_Remove( self:GetParent() )
	end
end
