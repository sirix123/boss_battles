quick_strike = class({})

function quick_strike:OnAbilityPhaseStart()
    if IsServer() then

        -- animation should be like a channel looking thing cast point should be large like 2-3seconds
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.4)

        self.vTargetPos = self:GetCursorPosition()

        if self.vTargetPos == nil then
            return false
        end

        self.speed = 1200

        -- create dummy target
        self.dummy = CreateUnitByName("npc_dummy_unit", self.vTargetPos, false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())

        self.distance = ( self.vTargetPos - self:GetCaster():GetAbsOrigin() ):Length2D()
        local time = self.distance / self.speed

        self.radius = 100
        self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self.vTargetPos )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, Vector( self.radius, -self.radius, -self.radius ) )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, Vector( time, 0, 0 ) );
        ParticleManager:ReleaseParticleIndex( self.nPreviewFXIndex )

        return true

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function quick_strike:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)

        if self.dummy ~= nil then
            self.dummy:RemoveSelf()
        end
        if self.nPreviewFXIndex ~= nil then
            ParticleManager:DestroyParticle(self.nPreviewFXIndex, true)
        end

    end
end
---------------------------------------------------------------------------

function quick_strike:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)
    self.caster = self:GetCaster()

    EmitSoundOnLocationWithCaster(self.caster:GetAbsOrigin(), "Hero_WitchDoctor.Attack", self.caster)

    -- create and do these for a while

    -- tracking proj

    -- create projectile
    local info = {
        EffectName = "particles/tinker/charge_bot_rattletrap_rocket_flare.vpcf",
        Ability = self,
        iMoveSpeed = self.speed,
        Source = self.caster,
        Target = self.dummy,
        bDodgeable = false,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
        bProvidesVision = true,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
        iVisionRadius = 300,
    }

    ProjectileManager:CreateTrackingProjectile( info )

    self.dummy:RemoveSelf()

end
---------------------------------------------------------------------------------------------------------------------------------------

function quick_strike:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        ParticleManager:DestroyParticle(self.nPreviewFXIndex, true)

        local particle = "particles/units/heroes/hero_rubick/rubick_chaos_meteor_cubes.vpcf"
        local nfx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(nfx , 3, vLocation)
        ParticleManager:ReleaseParticleIndex(nfx)

        EmitSoundOnLocationWithCaster(vLocation, "Hero_WitchDoctor.ProjectileImpact", self.caster)

        local targets = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            vLocation,
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0,
            0,
            false
        )

        for _, target in pairs(targets) do
            local dmgTable =
            {
                victim = target,
                attacker = self.caster,
                damage = 50,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability = self,
            }

            ApplyDamage(dmgTable)
        end

    end
end