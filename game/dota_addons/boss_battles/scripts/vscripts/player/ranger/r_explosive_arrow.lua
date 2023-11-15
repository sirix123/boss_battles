r_explosive_arrow = class({})
LinkLuaModifier( "r_explosive_arrow_thinker_indicator", "player/ranger/modifiers/r_explosive_arrow_thinker_indicator", LUA_MODIFIER_MOTION_NONE )


function r_explosive_arrow:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------
function r_explosive_arrow:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

---------------------------------------------------------------------------

function r_explosive_arrow:OnChannelFinish(bInterrupted)
	if IsServer() then
	end
end

function r_explosive_arrow:OnSpellStart()
    if IsServer() then
        

	end
end
---------------------------------------------------------------------------

function r_explosive_arrow:OnChannelThink( flinterval )
    if IsServer() then

        self.time = (self.time or 0) + flinterval
        if self.time < self:GetSpecialValueFor( "tick_rate" ) then
            return false
        else
            self.point = Vector(self:GetCursorPosition().x, self:GetCursorPosition().y, self:GetCursorPosition().z)

            local distance = (self.point - self:GetCaster():GetOrigin()):Length2D()
            local travel_time = distance / self:GetSpecialValueFor( "projectile_speed" )

            local thinker = CreateModifierThinker(
                self:GetCaster(), -- player source
                self, -- ability source
                "r_explosive_arrow_thinker_indicator", -- modifier name
                { travel_time = travel_time }, -- kv
                self.point,
                self:GetCaster():GetTeamNumber(),
                false
            )

            -- fire trakcing at thinker
            local info = {
                Target = thinker,
                Source = self:GetCaster(),
                Ability = self,	
                iMoveSpeed = self:GetSpecialValueFor( "projectile_speed" ),
                EffectName = "particles/units/heroes/hero_snapfire/snapfire_lizard_blobs_arced.vpcf",
                bDodgeable = false,                           -- Optional

                vSourceLoc = self.point,                -- Optional (HOW)

                bDrawsOnMinimap = false,                          -- Optional
                bVisibleToEnemies = true,                         -- Optional
                bProvidesVision = true,                           -- Optional
                iVisionRadius = self:GetSpecialValueFor( "projectile_vision" ),                              -- Optional
                iVisionTeamNumber = self:GetCaster():GetTeamNumber()        -- Optional
            }

            ProjectileManager:CreateTrackingProjectile( info )

            local sound_cast = "Hero_Snapfire.MortimerBlob.Launch"
            EmitSoundOn( sound_cast, self:GetCaster() )
            self.time = 0
        end
	end
end
----------------------------------------------------------------------------------------------------------------

function r_explosive_arrow:OnProjectileHit( target, location )
	if not target then return end

	local damage = self:GetSpecialValueFor( "damage" )
	local radius = self:GetSpecialValueFor( "radius" )

	local damageTable = {
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self,
	}

	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		location,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage(damageTable)
	end

	self:PlayEffects( target:GetOrigin() )
end

--------------------------------------------------------------------------------
function r_explosive_arrow:PlayEffects( loc )
	local particle_cast2 = "particles/units/heroes/hero_snapfire/snapfire_lizard_blobs_arced_explosion.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, loc )
	ParticleManager:SetParticleControl( effect_cast, 3, loc )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	local sound_location = "Hero_Snapfire.MortimerBlob.Impact"
	EmitSoundOnLocationWithCaster( loc, sound_location, self:GetCaster() )
end