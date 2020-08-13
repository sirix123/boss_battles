m2_icefall_modifier_thinker = class({})

function m2_icefall_modifier_thinker:IsHidden()
	return false
end

function m2_icefall_modifier_thinker:IsDebuff()
	return false
end

function m2_icefall_modifier_thinker:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function m2_icefall_modifier_thinker:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.trackingSpeed = self:GetAbility():GetSpecialValueFor("speed")
        self.radius = self:GetAbility():GetSpecialValueFor("radius")
        self.dmg = self:GetAbility():GetSpecialValueFor( "dmg" )
        self.bSpawn = true
        self.currentIceFallLocation = 0
        self.quartal = -1
        self.counter = 0
        self.stopDamageLoop = false

        -- ref from spell 
        self.currentTarget = Vector( kv.target_x, kv.target_y, kv.target_z )
        self.interval = FrameTime()

        self:StartIntervalThink( self.interval )
	end
end
---------------------------------------------------------------------------

function m2_icefall_modifier_thinker:OnIntervalThink()
    if IsServer() then
        if self.bSpawn == true then
            self:StartApplyDamageLoop()
            self.currentIceFallLocation = self.currentTarget
        else
            local mouseLoc = PlayerManager.mouse_positions[self.caster:GetPlayerID()]
            self.currentTarget = Vector(mouseLoc.x, mouseLoc.y, self.parent:GetForwardVector().z )
        end

        -- play effects
        self:PlayEffects()

        self:MoveLogic( self.currentIceFallLocation )

    end
end
---------------------------------------------------------------------------

function m2_icefall_modifier_thinker:MoveLogic(previousIcefall)
    --DebugDrawCircle(previousIcefall, Vector(0,0,255), 60, self.radius, true, 60)

	local direction = (self.currentTarget - previousIcefall):Normalized()
	self.currentIceFallLocation = previousIcefall + direction * self.trackingSpeed * self.interval

	self.parent:SetAbsOrigin( self.currentIceFallLocation )
    self.bSpawn = false

end
--------------------------------------------------------------------------------

function m2_icefall_modifier_thinker:StartApplyDamageLoop()

    Timers:CreateTimer(0.5, function()

	    if self.stopDamageLoop == true or _G.stopApplyDamageTimer == true then
		    return false
        end

        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self.parent:GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        for _, enemy in pairs(enemies) do
            self.dmgTable = {
                victim = enemy,
                attacker = self.caster,
                damage = self.dmg,
                damage_type = self:GetAbility():GetAbilityDamageType(),
            }

            ApplyDamage(self.dmgTable)
        end

        --DebugDrawCircle(self.parent:GetAbsOrigin(), Vector(0,0,255), 60, self.radius, true, 60)

		return 0.5
	end)
end
--------------------------------------------------------------------------------

function m2_icefall_modifier_thinker:PlayEffects()
    if IsServer() then
        if self.bSpawn == true then
            -- create particple effect (particle 1)
            local particle_cast_1 = "particles/icemage/m2_icefall_maiden_freezing_field_snow.vpcf"
            self.effect_cast_1 = ParticleManager:CreateParticle( particle_cast_1, PATTACH_ABSORIGIN_FOLLOW, self.parent )

            -- Play sound 1
            self.sound_cast_1 = "hero_Crystal.freezingField.wind"
            EmitSoundOn( self.sound_cast_1, self.parent )

        end

        local direction = ( self.currentTarget - self.parent:GetOrigin() )
        direction.z = 0
        direction = direction:Normalized()

        -- effect 1
        ParticleManager:SetParticleControl( self.effect_cast_1, 1, Vector( self.radius, self.radius, 1 ) )
        ParticleManager:SetParticleControl( self.effect_cast_1, 2, direction * self.trackingSpeed )

        -- effect 2
        local particle_cast_2 = "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf"

        -- Set explosion quartal
        self.quartal = self.quartal+1
        if self.quartal>3 then self.quartal = 0 end

        -- determine explosion relative position
        local a = RandomInt(0,90) + self.quartal*90
        local r = self.radius
        local point = Vector( math.cos(a), math.sin(a), 0 ):Normalized() * r

        -- actual position
        point = self.parent:GetOrigin() + point

        self.effect_cast_2 = ParticleManager:CreateParticle( particle_cast_2, PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( self.effect_cast_2, 0, point )

        -- play sound for effect 2
        self.sound_cast_2 = "hero_Crystal.freezingField.explosion"
        EmitSoundOn( self.sound_cast_2, self.parent )
	end
end
---------------------------------------------------------------------------

function m2_icefall_modifier_thinker:StopEffects()
    if IsServer() then
        StopSoundOn( self.sound_cast_1, self.parent )
        StopSoundOn( self.sound_cast_2, self.parent )
	end
end
---------------------------------------------------------------------------

function m2_icefall_modifier_thinker:OnDestroy( kv )
    if IsServer() then
        self.stopDamageLoop = true
        self:StopEffects()
        self:StartIntervalThink( -1 )
        UTIL_Remove( self.parent )
	end
end
---------------------------------------------------------------------------