
bird_puddle_thinker = class({})
LinkLuaModifier( "biting_frost_modifier_buff_fire", "bosses/tinker/modifiers/biting_frost_modifier_buff_fire", LUA_MODIFIER_MOTION_NONE  )

function bird_puddle_thinker:IsHidden()
	return false
end

function bird_puddle_thinker:IsDebuff()
	return true
end

function bird_puddle_thinker:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function bird_puddle_thinker:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.radius = 200
        self.dmg_dot = 50
        self.stopDamageLoop = false
        self.damage_interval = 1

        -- ref from spell 
        self.currentTarget = Vector( kv.target_x, kv.target_y, kv.target_z )
        self.summoned_lava_npc = false

        --DebugDrawCircle(self.parent:GetAbsOrigin(), Vector(0,0,255), 128, self.radius, true, 60)

        -- particle effect lava puddle
        local particle_cast2 = "particles/clock/tinker_hero_snapfire_ultimate_linger.vpcf"
        self.effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_WORLDORIGIN, self.parent )
        ParticleManager:SetParticleControl( self.effect_cast, 0, self.parent:GetAbsOrigin() )
        ParticleManager:SetParticleControl( self.effect_cast, 2, Vector(-1,0,0) )
        ParticleManager:SetParticleControl( self.effect_cast, 1, self.parent:GetAbsOrigin() )
        --ParticleManager:ReleaseParticleIndex( effect_cast )

        self:StartEnemyDebuffChecker()
        self:StartApplyDamageLoop()
	end
end
---------------------------------------------------------------------------

function bird_puddle_thinker:StartApplyDamageLoop()

    Timers:CreateTimer(self.damage_interval, function()
	    if self.stopDamageLoop == true then
		    return false
        end

        local friendlies_tinker = FindUnitsInRadius(
            self.parent:GetTeamNumber(),	-- int, your team number
            self.currentTarget,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if self.summoned_lava_npc == false then
            if friendlies_tinker ~= nil and #friendlies_tinker ~= 0 then
                for _, friend in pairs(friendlies_tinker) do
                    if friend:GetUnitName() == "npc_tinker" then
                        if friend:HasModifier("summon_lava_puddle") then
                            self.summoned_lava_npc = true

                            local particle = "particles/units/heroes/hero_invoker_kid/invoker_kid_forge_spirit_death.vpcf"
                            self.effect_cast_1 = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self.parent)
                            ParticleManager:SetParticleControl(self.effect_cast_1, 0, self.currentTarget)
                            ParticleManager:ReleaseParticleIndex(self.effect_cast_1)

                            Timers:CreateTimer(2, function()
                                CreateUnitByName( "npc_fire_puddle_summon", self.currentTarget, true, nil, nil, DOTA_TEAM_BADGUYS)

                                return false
                            end)
                        end
                    end
                end
            end
        end

        local enemies = FindUnitsInRadius(
            self.parent:GetTeamNumber(),	-- int, your team number
            self.currentTarget,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        local friendlies = FindUnitsInRadius(
            self.parent:GetTeamNumber(),	-- int, your team number
            self.currentTarget,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

       if friendlies ~= nil and #friendlies ~= 0 then
            for _, friend in pairs(friendlies) do
                if friend:GetUnitName() == "npc_charge_bot" then
                    friend:AddNewModifier(self:GetCaster(), self, "biting_frost_modifier_buff_fire", {duration = 5})
                end
            end
        end

        if enemies ~= nil and #enemies ~= 0 then
            for _, enemy in pairs(enemies) do

                self.dmgTable = {
                    victim = enemy,
                    attacker = self.caster,
                    damage = self.dmg_dot,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                }

                if enemy:HasModifier("biting_frost_modifier_debuff") then
                    -- little steam particle effect here?
                    local particle = "particles/units/heroes/hero_phoenix/phoenix_supernova_death_steam.vpcf"
                    local effect_cast = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, self.parent )
                    ParticleManager:SetParticleControl( effect_cast, 1, self.parent:GetAbsOrigin() )
                    ParticleManager:ReleaseParticleIndex( effect_cast )

                    enemy:RemoveModifierByName("biting_frost_modifier_debuff")
                    self:Destroy()
                end

                ApplyDamage(self.dmgTable)
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

		return self.damage_interval
	end)
end
--------------------------------------------------------------------------------

function bird_puddle_thinker:StartEnemyDebuffChecker()

    Timers:CreateTimer(self.damage_interval, function()
	    if self.stopDamageLoop == true then
		    return false
        end

        local enemies = FindUnitsInRadius(
            self.parent:GetTeamNumber(),	-- int, your team number
            self.currentTarget,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if enemies ~= nil and #enemies ~= 0 then
            for _, enemy in pairs(enemies) do

                if enemy:HasModifier("biting_frost_modifier_debuff") then
                    -- little steam particle effect here?
                    local particle = "particles/units/heroes/hero_phoenix/phoenix_supernova_death_steam.vpcf"
                    local effect_cast = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, self.parent )
                    ParticleManager:SetParticleControl( effect_cast, 1, self.parent:GetAbsOrigin() )
                    ParticleManager:ReleaseParticleIndex( effect_cast )

                    enemy:RemoveModifierByName("biting_frost_modifier_debuff")
                    self:Destroy()
                end
            end
        end


		return 0.01
	end)
end
--------------------------------------------------------------------------------

function bird_puddle_thinker:OnDestroy( kv )
    if IsServer() then
        ParticleManager:DestroyParticle(self.effect_cast,true)
        self.stopDamageLoop = true
        self:StartIntervalThink( -1 )
        UTIL_Remove( self.parent )
	end
end
---------------------------------------------------------------------------