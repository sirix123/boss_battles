e_icefall_modifier_thinker = class({})
LinkLuaModifier("chill_modifier_blizzard", "player/icemage/modifiers/chill_modifier_blizzard", LUA_MODIFIER_MOTION_NONE)

function e_icefall_modifier_thinker:IsHidden()
	return false
end

function e_icefall_modifier_thinker:IsDebuff()
	return false
end

function e_icefall_modifier_thinker:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function e_icefall_modifier_thinker:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.radius = self:GetAbility():GetSpecialValueFor("radius")
        self.dmg = self:GetAbility():GetSpecialValueFor( "dmg" )
        self.bSpawn = true
        self.quartal = -1
        self.stopDamageLoop = false
        self.damage_interval = self:GetAbility():GetSpecialValueFor( "dmg_interval" )

        self.ms_slow = self:GetAbility():GetSpecialValueFor( "ms_slow" )
        self.as_slow = self:GetAbility():GetSpecialValueFor( "as_slow" )

        self.stun_activate = self:GetAbility():GetSpecialValueFor( "stun_activate" )
        self.stun_duration = self:GetAbility():GetSpecialValueFor( "stun_duration" )
        self.stun_targets_table = {}

        -- ref from spell 
        self.currentTarget = Vector( kv.target_x, kv.target_y, kv.target_z )

        self.interval = 0.03
        self:StartApplyDamageLoop()
        self:StartStunLoop()
        self:StartIntervalThink( self.interval )
	end
end
---------------------------------------------------------------------------

function e_icefall_modifier_thinker:OnIntervalThink()
    if IsServer() then
        -- play effects
        self:PlayEffects()
    end
end
---------------------------------------------------------------------------

function e_icefall_modifier_thinker:StartApplyDamageLoop()

    Timers:CreateTimer(self.damage_interval, function()
	    if self.stopDamageLoop == true then
		    return false
        end

        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self.currentTarget,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        for _, enemy in pairs(enemies) do

            if CheckRaidTableForBossName(enemy) == true or enemy:GetUnitName() == "npc_guard" then

                self.dmgTable = {
                    victim = enemy,
                    attacker = self.caster,
                    damage = self.dmg,
                    damage_type = self:GetAbility():GetAbilityDamageType(),
                    ability = self:GetAbility(),
                }

                ApplyDamage(self.dmgTable)
            else
                self.dmgTable = {
                    victim = enemy,
                    attacker = self.caster,
                    damage = self.dmg,
                    damage_type = self:GetAbility():GetAbilityDamageType(),
                    ability = self:GetAbility(),
                }

                ApplyDamage(self.dmgTable)
                enemy:AddNewModifier(self.caster, self, "chill_modifier_blizzard", { duration = self:GetAbility():GetSpecialValueFor( "chill_duration"), ms_slow = self.ms_slow, as_slow = self.as_slow })

            end
        end
        --DebugDrawCircle(self.currentTarget, Vector(0,0,255), 60, self.radius, true, 60)

		return self.damage_interval
	end)
end
--------------------------------------------------------------------------------

function e_icefall_modifier_thinker:StartStunLoop()

    Timers:CreateTimer(function()
	    if self.stopDamageLoop == true then
		    return false
        end

        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self.currentTarget,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        --[[for _, enemy in pairs(enemies) do
            enemy:AddNewModifier(self.caster, self, "icefall_freeze_modifier", { duration = self.stun_duration })
		end]]

        --first, loop through stun_targets_table and remove any enemy not in enemies
        for _, enemy in pairs(self.stun_targets_table) do
            local enemyInBothTables = false
            for _, enemyHit in pairs(enemies) do
                if enemyHit == enemy then
                    enemyInBothTables = true
                end
            end
            --if still false, if an enemy in stun_targets_table wasn't hit this tick, then remove from stun_targets_table
            if not enemyInBothTables then
                self.stun_targets_table[enemy] = nil
            end
        end
        --then loop through enemies hit, and either add them to tracking list or if already present increment them
        for _, enemy in pairs(enemies) do
            -- if enemy already in stun_targets_table then increment
            if self.stun_targets_table[enemy] ~= nil then
                self.stun_targets_table[enemy] = self.stun_targets_table[enemy] +1
                --check if the enemy has been in there for x number of ticks
                --print("enemy count ",self.stun_targets_table[enemy])
                if self.stun_targets_table[enemy] > 20 then
                    if CheckRaidTableForBossName(enemy) ~= true and enemy:GetUnitName() ~= "npc_guard" then
                        enemy:AddNewModifier(self.caster, self, "icefall_freeze_modifier", { duration = self.stun_duration })
                        self.stun_targets_table[enemy] = 1
                    end
                end
            end
            -- if enemy not in stun_targets_table, then add it
            if self.stun_targets_table[enemy] == nil then
                self.stun_targets_table[enemy] = 1
            end
        end

		return 0.1
	end)
end
--------------------------------------------------------------------------------

function e_icefall_modifier_thinker:PlayEffects()
    if IsServer() then
        if self.bSpawn == true then
            -- create particple effect (particle 1)
            --local particle_cast_1 = "particles/icemage/m2_icefall_maiden_freezing_field_snow.vpcf"
            --self.effect_cast_1 = ParticleManager:CreateParticle( particle_cast_1, PATTACH_WORLDORIGIN, self.parent )

            -- Play sound 1
            --self.sound_cast_1 = "hero_Crystal.freezingField.wind"
            --EmitSoundOnLocationWithCaster(self.parent:GetAbsOrigin(), self.sound_cast_1, self.caster)
            self.bSpawn = false
        end

        -- effect 1
        --ParticleManager:SetParticleControl( self.effect_cast_1, 1, Vector( self.radius, self.radius, 1 ) )
        --ParticleManager:SetParticleControl( self.effect_cast_1, 2, self.currentTarget )

        -- effect 2
        local enEffect = nil
        if self.caster.arcana_equipped == true then
            enEffect = "particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_freezing_field_explosion_arcana1.vpcf"
        else
            enEffect = "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf"
        end
        local particle_cast_2 = enEffect

        --[[ Set explosion quartal
        self.quartal = self.quartal+1
        if self.quartal>3 then self.quartal = 0 end

        -- determine explosion relative position
        local a = RandomInt(0,90) + self.quartal*90
        local r = self.radius - 100
        local point = Vector( math.cos(a), math.sin(a), 0 ):Normalized() * r


        -- actual position
        point = self.currentTarget + point]]

        local rVector = RandomVector( RandomFloat( 0, self.radius )) + self.currentTarget

        --DebugDrawCircle(rVector,Vector(255,255,255),128,10,true,60)

        self.effect_cast_2 = ParticleManager:CreateParticle( particle_cast_2, PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( self.effect_cast_2, 0, rVector )

        -- play sound for effect 2
        self.sound_cast_2 = "hero_Crystal.freezingField.explosion"
        EmitSoundOnLocationWithCaster(self.parent:GetAbsOrigin(), self.sound_cast_2, self.caster)
	end
end
---------------------------------------------------------------------------

function e_icefall_modifier_thinker:StopEffects()
    if IsServer() then
        --StopSoundOn( self.sound_cast_1, self.parent )
        StopSoundOn( self.sound_cast_2, self.parent )
	end
end
---------------------------------------------------------------------------

function e_icefall_modifier_thinker:OnDestroy( kv )
    if IsServer() then
        self.stopDamageLoop = true
        self:StopEffects()
        self:StartIntervalThink( -1 )
        UTIL_Remove( self.parent )
	end
end
---------------------------------------------------------------------------

function e_icefall_modifier_thinker:GetOverrideAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function e_icefall_modifier_thinker:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return funcs
end