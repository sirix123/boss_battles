vortex_grenade = class({})
LinkLuaModifier( "vortex_grenade_thinker", "bosses/clock/modifiers/vortex_grenade_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "vortex_prison_modifier", "bosses/clock/modifiers/vortex_prison_modifier", LUA_MODIFIER_MOTION_NONE )

function vortex_grenade:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_RATTLETRAP_POWERCOGS, 1.0)

        EmitSoundOn("rattletrap_ratt_ability_flare_05", self:GetCaster())

        -- find unit and throw a nade at em
        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            2000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return false
        else
            local randomEnemy = units[RandomInt(1, #units)]

            print("vortex target ",randomEnemy:GetUnitName())

            self.vTargetPos = randomEnemy:GetAbsOrigin()

            local radius = 500
            self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self.vTargetPos )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, Vector( radius, -radius, -radius ) )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, Vector( self:GetCastPoint(), 0, 0 ) );
            ParticleManager:ReleaseParticleIndex( self.nPreviewFXIndex )

            return true

        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function vortex_grenade:OnAbilityPhaseInterrupted()
    if IsServer() then

        self:GetCaster():RemoveGesture(ACT_DOTA_RATTLETRAP_POWERCOGS)

        if self.nPreviewFXIndex ~= nil then
            ParticleManager:DestroyParticle(self.nPreviewFXIndex, true)
        end

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function vortex_grenade:OnSpellStart()
    if IsServer() then
        self:GetCaster():RemoveGesture(ACT_DOTA_RATTLETRAP_POWERCOGS)

        local caster = self:GetCaster()
        local vCaster = caster:GetAbsOrigin()

        -- particles/econ/items/rubick/rubick_arcana/rbck_arc_skeletonking_hellfireblast.vpcf (tracking proj I think)
        -- particles/units/heroes/hero_rubick/rubick_blackhole.vpcf black hole
        -- particles/units/heroes/hero_rubick/rubick_faceless_void_chronosphere.vpcf chrono spehere

        local particle_projectile = "particles/clock/clock_rbck_arc_skeletonking_hellfireblast.vpcf"
        local projectile_speed = 900

        local vDirection = self.vTargetPos - self:GetCaster():GetOrigin()
		vDirection.z = 0.0
        vDirection = vDirection:Normalized()
        
        local distance = (self.vTargetPos - vCaster ):Length2D()

		local info = {
			EffectName = particle_projectile,
			Ability = self,
            vSpawnOrigin = self:GetCaster():GetOrigin(),
            bDeleteOnHit = false,
			fStartRadius = 100,
			fEndRadius = 100,
			vVelocity = vDirection * projectile_speed,
			fDistance = distance,
			Source = self:GetCaster(),
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO,
		}

		ProjectileManager:CreateLinearProjectile( info )

        EmitSoundOn( "Hero_Rubick.FadeBolt.Cast", self:GetCaster() )

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function vortex_grenade:OnProjectileHit( hTarget, vLocation)
    if IsServer() then
        if hTarget ~= nil then return end

        ParticleManager:DestroyParticle(self.nPreviewFXIndex, true)

        -- create the thinker
        CreateModifierThinker(
            self:GetCaster(),
            self,
            "vortex_grenade_thinker",
            {
                duration = 10,
                target_x = vLocation.x,
                target_y = vLocation.y,
                target_z = vLocation.z,
            },
            vLocation,
            self:GetCaster():GetTeamNumber(),
            false
        )

    end
end

