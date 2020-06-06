m1_iceshot = class({})

function m1_iceshot:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function m1_iceshot:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function m1_iceshot:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = 500

        -- set player forward vector to mouse postion while spell is casting
        local vTargetPos = nil
        vTargetPos = GameMode.mouse_positions[self.caster:GetPlayerID()]

        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

        local hProjectile = {
            Source = self.caster,
            Ability = self,
            vSpawnOrigin = origin + Vector(0, 0, 100),
            bDeleteOnHit = true,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            EffectName = "particles/econ/items/mars/mars_ti9_immortal/mars_ti9_immortal_crimson_spear.vpcf",
            fDistance = 1500,
            fStartRadius = 50,
            fEndRadius = 50,
            vVelocity = projectile_direction * projectile_speed,
            bHasFrontalCone = false,
            bReplaceExisting = false,
            fExpireTime = GameRules:GetGameTime() + 30.0,
            bProvidesVision = true,
            iVisionRadius = 200,
            iVisionTeamNumber = self.caster:GetTeamNumber(),
        }

        ProjectileManager:CreateLinearProjectile(hProjectile)

	end
end