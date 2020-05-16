
blast_wave = class({})

LinkLuaModifier( "blast_wave_modifier", "bosses/timber/blast_wave_modifier", LUA_MODIFIER_MOTION_NONE )

local tProjectileData = {}

function blast_wave:OnSpellStart()
	if IsServer() then

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
        self.radius = self:GetSpecialValueFor( "radius" )
        self.destroy_tree_radius = self:GetSpecialValueFor( "destroy_tree_radius" )
        self.duration = self:GetSpecialValueFor( "duration" )
        self.damage_1 = self:GetSpecialValueFor( "damage_1" )
        self.damage_2 = self:GetSpecialValueFor( "damage_2" )

        local vTargetPos = nil
		if self:GetCursorTarget() then
			vTargetPos = self:GetCursorTarget():GetOrigin()
		else
			vTargetPos = self:GetCursorPosition()
		end

        self.damageTable = {
            attacker = self.caster,
            damage = self.damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
        }

        local hProjectile = {
            Source = self.caster,
            Ability = self,
            vSpawnOrigin = origin,
            bDeleteOnHit = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            EffectName = "particles/timber/blast_wave.vpcf",
            fDistance = 2000,
            fStartRadius = self.radius,
            fEndRadius = self.radius,
            vVelocity = self.caster:GetForwardVector() * projectile_speed,
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
        if hTarget:FindModifierByName( "blast_wave_modifier" ) then

            hTarget:AddNewModifier( self.caster, self, "blast_wave_modifier", { duration = self.duration } )

            self.damageTable.damage = self.damage_2
            self.damageTable.victim = hTarget
            ApplyDamage( self.damageTable )

            EmitSoundOn("shredder_timb_kill_08", self.caster)

        else

            hTarget:AddNewModifier( self.caster, self, "blast_wave_modifier", { duration = self.duration } )

            self.damageTable.damage = self.damage_1
            self.damageTable.victim = hTarget
            ApplyDamage( self.damageTable )

            EmitSoundOn("shredder_timb_happy_01", self.caster)

        end
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