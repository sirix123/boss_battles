green_beam = class({})

--LinkLuaModifier( "green_beam_modifier", "bosses/techies/modifiers/green_beam_modifier", LUA_MODIFIER_MOTION_BOTH  )

function green_beam:OnAbilityPhaseStart()
    if IsServer() then

        -- play voice line
        EmitSoundOn("techies_tech_suicidesquad_01", self:GetCaster())

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function green_beam:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local beam_length = 2000
        local radius = 50

        local angleIncrement = 0.5
        local currentAngle = 1

        self.stopFireWave = false

        -- start a timer that fires the blast wave projectile every x seconds, look at the endpos var every timer run
        Timers:CreateTimer(3, function()
            if self.stopFireWave == true then
                return false
            end

            if self.end_pos ~= nil and self.end_pos ~= 0 then
                --print("self.end_pos ",self.end_pos)
                local blastwaveDirection = -( self:GetCaster():GetAbsOrigin() - self.end_pos ):Normalized()
                self:FireBlastWave(blastwaveDirection)
            end

            return 3
        end)

        -- find tinker and get the direction from tinker to the crystral, use this as the starting direction vector for the beam
        local friendlies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            caster:GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        for _, friend in pairs(friendlies) do
            if friend:GetUnitName() == "npc_tinker" then
                self.tinker_origin = friend:GetAbsOrigin()
            end
        end

        local vTinkerDirectionInverse = -( self.tinker_origin - caster:GetAbsOrigin() ):Normalized()
        local beam_point = caster:GetAbsOrigin() + vTinkerDirectionInverse * beam_length
        DebugDrawCircle(beam_point, Vector(155,0,0),128,50,true,60)

        -- create particle effect
        local particleName = "particles/tinker/green_phoenix_sunray.vpcf"
        self.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
        caster:SetContextThink( DoUniqueString( "updateSunRay" ), function ( )

            ParticleManager:SetParticleControl(self.pfx, 0, Vector( caster:GetAbsOrigin().x,caster:GetAbsOrigin().y, caster:GetAbsOrigin().z + 100 ))

            self.end_pos = ( RotatePosition(caster:GetAbsOrigin(), QAngle(0,currentAngle,0), beam_point ) )
			self.end_pos = GetGroundPosition( self.end_pos, nil )
			self.end_pos.z = caster:GetAbsOrigin().z + 100
            --DebugDrawCircle(self.end_pos, Vector(0,155,0),128,50,true,60)

            ParticleManager:SetParticleControl( self.pfx, 1, self.end_pos )

            local units = FindUnitsInLine(
                caster:GetTeamNumber(),
				caster:GetAbsOrigin(),
				self.end_pos,
				nil,
				radius,
				DOTA_UNIT_TARGET_TEAM_BOTH,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE)

			for _,unit in pairs(units) do
                --print(unit:GetUnitName())
                if unit:GetUnitName() == "npc_tinker" then
                    self.stopFireWave = true
                    ParticleManager:DestroyParticle(self.pfx, false)
                    return 0.0
                end
            end

            if currentAngle == 360 then
                currentAngle = 0
            end

            currentAngle = currentAngle + angleIncrement
            --print("currentAngle ",currentAngle)
            return 0.01
        end, 0.0 )

    end
end
------------------------------------------------------------------------------------------------------------------------------

function green_beam:FireBlastWave(direction)
    if IsServer() then
        local projectile_speed = 600

        local projectile = {
            EffectName = "particles/custom/tinker_blast_wave/tinker_blast_wave.vpcf",
            vSpawnOrigin = self:GetCaster():GetAbsOrigin() + Vector(0, 0, 100),
            fDistance = 5000,
            fStartRadius = 1,
			fEndRadius = 2500,
            Source = self:GetCaster(),
            vVelocity = direction * projectile_speed,
            UnitBehavior = PROJECTILES_DESTROY,
            TreeBehavior = PROJECTILES_DESTROY,
            WallBehavior = PROJECTILES_DESTROY,
            GroundBehavior = PROJECTILES_NOTHING,
            fGroundOffset = 80,
            draw = true,
            UnitTest = function(_self, unit)
                return unit:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and CheckGlobalUnitTableForUnitName(unit) ~= true
            end,
            OnUnitHit = function(_self, unit)
            end,
            OnFinish = function(_self, pos)
            end,
        }

        Projectiles:CreateProjectile(projectile)
    end
end