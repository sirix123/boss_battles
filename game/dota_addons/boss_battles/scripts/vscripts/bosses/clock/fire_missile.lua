fire_missile = class({})

function fire_missile:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1.0)

        self.vTargetPos = self:GetCursorPosition()

        if self.vTargetPos == nil then
            return false
        end

        -- for some reason .. volvo... needs a unit for this proj...
        self.dummy = CreateUnitByName("npc_dummy_unit", self.vTargetPos, false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())

        self:GetCaster():SetForwardVector(self.vTargetPos)
        self:GetCaster():FaceTowards(self.vTargetPos)

        self.missile_radius = 150
        self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self.vTargetPos )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, Vector( self.missile_radius, -self.missile_radius, -self.missile_radius ) )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, Vector( 1, 0, 0 ) );
        --ParticleManager:ReleaseParticleIndex( self.nPreviewFXIndex )

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function fire_missile:OnAbilityPhaseInterrupted()
    if IsServer() then
        if self.dummy ~= nil then
            self.dummy:ForceKill(false)
        end
        if self.nPreviewFXIndex ~= nil then
            ParticleManager:DestroyParticle(self.nPreviewFXIndex, true)
        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function fire_missile:OnSpellStart()
    if IsServer() then
        self.caster = self:GetCaster()

        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_3)

        self:GetCaster():SetForwardVector(self.vTargetPos)
        self:GetCaster():FaceTowards(self.vTargetPos)

        -- references
        self.speed = 500 -- special value
        self.damage = 150

        -- create projectile
        local info = {
            EffectName = "particles/ranger/ranger_clockwerk_para_rocket_flare.vpcf",
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

        EmitSoundOn( "Hero_Rattletrap.Rocket_Flare.Fire", self:GetCaster() )

        -- shoot proj
        ProjectileManager:CreateTrackingProjectile( info )

        -- kill dummy unit asap
        self.dummy:ForceKill(false)

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function fire_missile:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        ParticleManager:DestroyParticle(self.nPreviewFXIndex, true)

        local targets = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            vLocation,
            nil,
            self.missile_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0,
            0,
            false
        )

        -- initial hit 
        for _, target in pairs(targets) do
            local dmgTable =
            {
                victim = target,
                attacker = self.caster,
                damage = self.damage,
                damage_type = DAMAGE_TYPE_PHYSICAL,
            }

            ApplyDamage(dmgTable)
        end

    end
end
