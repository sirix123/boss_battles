e_icefall_modifier_thinker = class({})
LinkLuaModifier("chill_modifier", "player/icemage/modifiers/chill_modifier", LUA_MODIFIER_MOTION_NONE)

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

        -- ref from spell 
        self.currentTarget = Vector( kv.target_x, kv.target_y, kv.target_z )

        self.interval = 0.03
        self:StartApplyDamageLoop()
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

            if CheckRaidTableForBossName(enemy) == true then

                self.dmgTable = {
                    victim = enemy,
                    attacker = self.caster,
                    damage = self.dmg,
                    damage_type = self:GetAbility():GetAbilityDamageType(),
                }

                ApplyDamage(self.dmgTable)
            else
                self.dmgTable = {
                    victim = enemy,
                    attacker = self.caster,
                    damage = self.dmg,
                    damage_type = self:GetAbility():GetAbilityDamageType(),
                }

                ApplyDamage(self.dmgTable)
                enemy:AddNewModifier(self.caster, self, "chill_modifier", { duration = self:GetAbility():GetSpecialValueFor( "chill_duration") })
            end
        end
        --DebugDrawCircle(self.currentTarget, Vector(0,0,255), 60, self.radius, true, 60)

		return self.damage_interval
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
        local particle_cast_2 = "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf"

        -- Set explosion quartal
        self.quartal = self.quartal+1
        if self.quartal>3 then self.quartal = 0 end

        -- determine explosion relative position
        local a = RandomInt(0,90) + self.quartal*90
        local r = self.radius - 100
        local point = Vector( math.cos(a), math.sin(a), 0 ):Normalized() * r

        -- actual position
        point = self.currentTarget + point

        self.effect_cast_2 = ParticleManager:CreateParticle( particle_cast_2, PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( self.effect_cast_2, 0, point )

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