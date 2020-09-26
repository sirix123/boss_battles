sticky_bomb_fire = class({})
LinkLuaModifier( "modifier_sticky_bomb_fire", "bosses/techies/modifiers/modifier_sticky_bomb_fire", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "fire_bomb_ground_modifier", "bosses/techies/modifiers/fire_bomb_ground_modifier", LUA_MODIFIER_MOTION_NONE )

function sticky_bomb_fire:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function sticky_bomb_fire:OnSpellStart()
	-- unit identifier
	self.caster = self:GetCaster()
    self.target = nil
    self.duration = self:GetSpecialValueFor( "duration" )

    self.speed = 900

	-- find targets
    local targets = FindUnitsInRadius(
        self.caster:GetTeamNumber(),	-- int, your team number
        self.caster:GetOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        4000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    if targets ~= nil and targets ~= 0 then

        self.target = targets[RandomInt(1, #targets)]

        local info = {
            EffectName = "particles/techies/firebomb_techies_wd_ti8_immortal_bonkers_cask.vpcf",
            Ability = self,
            iMoveSpeed = self.speed,
            Source = self.caster,
            Target = self.target,
            bDodgeable = false,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bProvidesVision = true,
            iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
            iVisionRadius = 300,
        }

        ProjectileManager:CreateTrackingProjectile( info )

    end
end

function sticky_bomb_fire:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        hTarget:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "modifier_sticky_bomb_fire", -- modifier name
            {
                duration = self.duration,
            } -- kv
        )

    end
end