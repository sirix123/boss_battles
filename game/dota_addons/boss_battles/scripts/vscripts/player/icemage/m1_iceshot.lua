m1_iceshot = class({})

function m1_iceshot:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1)

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
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function m1_iceshot:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = 800

        -- set player forward vector to mouse postion while spell is casting
        local vTargetPos = nil
        vTargetPos = GameMode.mouse_positions[self.caster:GetPlayerID()]

        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

        local hProjectile = {
            Source = self.caster,
            Ability = self,
            vSpawnOrigin = origin + Vector(0, 0, 10),
            bDeleteOnHit = true,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            EffectName = "particles/icemage/icemage_m1_maiden_base_attack.vpcf",
            fDistance = self:GetCastRange(origin, nil),
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

        self.projId = ProjectileManager:CreateLinearProjectile(hProjectile)

	end
end
----------------------------------------------------------------------------------------------------------------

function m1_iceshot:OnProjectileHit(hTarget, vLocation)

    if hTarget ~= nil then

        local dmgTable = {
            victim = hTarget,
            attacker = self.caster,
            damage = self:GetSpecialValueFor( "dmg" ),
            damage_type = self:GetAbilityDamageType(),
        }

        ApplyDamage( dmgTable )
        EmitSoundOn("hero_Crystal.projectileImpact", self.caster)
        ProjectileManager:DestroyLinearProjectile(self.projId)
    end
end