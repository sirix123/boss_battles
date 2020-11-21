
blast_wave = class({})

LinkLuaModifier( "blast_wave_modifier", "bosses/timber/blast_wave_modifier", LUA_MODIFIER_MOTION_NONE )

local tProjectileData = {}

function blast_wave:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_TELEPORT_END, 1.0)

        local units = FindUnitsInRadius(
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
            --ParticleManager:ReleaseParticleIndex( self.nPreviewFXIndex )]]

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
        end
    end
end


function blast_wave:OnSpellStart()
    if IsServer() then

        ParticleManager:DestroyParticle(self.nPreviewFXIndex, true)

        self:GetCaster():RemoveGesture(ACT_DOTA_TELEPORT_END)

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
        self.radius = self:GetSpecialValueFor( "radius" )
        self.destroy_tree_radius = self:GetSpecialValueFor( "destroy_tree_radius" )
        self.duration = self:GetSpecialValueFor( "duration" )
        self.damage_1 = self:GetSpecialValueFor( "damage_1" )
        self.damage_2 = self:GetSpecialValueFor( "damage_2" )
        local offset = 150

        self:GetCaster():SetForwardVector(self.vTargetPos)
        self:GetCaster():FaceTowards(self.vTargetPos)

        local projectile_direction = self.vTargetPos-self.caster:GetAbsOrigin()
        projectile_direction.z = 0
        projectile_direction = projectile_direction:Normalized()

        self.damageTable = {
            attacker = self.caster,
            damage = self.damage_1,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self,
        }

        local hProjectile = {
            Source = self.caster,
            Ability = self,
            vSpawnOrigin = origin + self.caster:GetForwardVector() * offset,
            bDeleteOnHit = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            EffectName = "particles/timber/blast_wave.vpcf",
            fDistance = 5000,
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

        local projectileId = ProjectileManager:CreateLinearProjectile(hProjectile)

        local projectileInfo  = {
            projectile = projectileId,
            position = origin,
            velocity = self.caster:GetForwardVector() * projectile_speed,
            handleProjectile = hProjectile
        }

        table.insert(tProjectileData, projectileInfo)

        self:StartThinkLoop()

	end
end
------------------------------------------------------------------------------------------------

function blast_wave:OnProjectileThink(vLocation)
	GridNav:DestroyTreesAroundPoint( vLocation, self.destroy_tree_radius, true )

end
------------------------------------------------------------------------------------------------

function blast_wave:OnProjectileHit(hTarget, vLocation)

    if hTarget ~= nil then
        self.damageTable.damage = self.damage_1
        self.damageTable.victim = hTarget
        ApplyDamage( self.damageTable )

        EmitSoundOn("shredder_timb_kill_08", self.caster)

        return true
    end
end
------------------------------------------------------------------------------------------------

function blast_wave:StartThinkLoop()
	Timers:CreateTimer(1, function()
    if not tProjectileData or #tProjectileData == 0 then
		return false
    end

	for k, projectileInfo in pairs(tProjectileData) do
        projectileInfo.position = projectileInfo.position + projectileInfo.velocity

        --DebugDrawCircle(projectileInfo.position, Vector(0,0,255), 128, 50, true, 60)

        if GetGroundPosition(projectileInfo.position, handleProjectile).z > 256 then
			ProjectileManager:DestroyLinearProjectile(projectileInfo.projectile)
			table.remove(tProjectileData, k)
		end

	end

		return 1.5
	end)
end