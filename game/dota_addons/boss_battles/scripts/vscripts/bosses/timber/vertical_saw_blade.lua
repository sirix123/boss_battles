
vertical_saw_blade = class({})

local tProjectileData = {}

function vertical_saw_blade:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_TELEPORT_END, 1.0)

        --[[local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            2500,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            FIND_CLOSEST,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return false
        else
            self.vTargetPos = units[1]:GetAbsOrigin()

            self:GetCaster():SetForwardVector(self.vTargetPos)
            self:GetCaster():FaceTowards(self.vTargetPos)

            local radius = 350
            --[[self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self.vTargetPos )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, Vector( radius, -radius, -radius ) )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, Vector( self:GetCastPoint(), 0, 0 ) );
            --ParticleManager:ReleaseParticleIndex( self.nPreviewFXIndex )

            local direction = (self.vTargetPos - self:GetCaster():GetAbsOrigin() ):Normalized()

            local particle = "particles/custom/ui_mouseactions/range_finder_cone_body_only.vpcf"
            self.nPreviewFXIndex = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, nil )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self:GetCaster():GetAbsOrigin() )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, self:GetCaster():GetAbsOrigin() + (direction * 1600))
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, self:GetCaster():GetAbsOrigin() );
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 3, Vector( radius, radius, 0 ) );
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 4, Vector( 255, 0, 0 ) );
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 6, Vector( 1, 0, 0 ) );

            -- play voice line
            EmitSoundOn("shredder_timb_cast_03", self:GetCaster())

            return true
        end]]

        return true
    end
end
------------------------------------------------------------------------------------------------

function vertical_saw_blade:OnSpellStart()
    if IsServer() then

        --ParticleManager:DestroyParticle(self.nPreviewFXIndex, true)

        self:GetCaster():RemoveGesture(ACT_DOTA_TELEPORT_END)

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = 500--self:GetSpecialValueFor("projectile_speed")
        self.radius = 100--self:GetSpecialValueFor( "radius" )
        self.damage = 100--self:GetSpecialValueFor( "damage" )

        --self:GetCaster():SetForwardVector(self.vTargetPos)
        --self:GetCaster():FaceTowards(self.vTargetPos)

        --[[local projectile_direction = self.vTargetPos-self.caster:GetAbsOrigin()
        projectile_direction.z = 0
        projectile_direction = projectile_direction:Normalized()]]

        local vTargetPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

        self.damageTable = {
            attacker = self.caster,
            damage = self.damage_1,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self,
        }

        local hProjectile = {
            Source = self.caster,
            Ability = self,
            vSpawnOrigin = origin,
            bDeleteOnHit = true,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            EffectName = "particles/timber/custom_vertical_timbersaw_ti9_chakram.vpcf",
            fDistance = 9000,
            fStartRadius = self.radius,
            fEndRadius = self.radius,
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
------------------------------------------------------------------------------------------------

function vertical_saw_blade:OnProjectileHit(hTarget, vLocation)

    if hTarget ~= nil then

        return true
    end
end
------------------------------------------------------------------------------------------------