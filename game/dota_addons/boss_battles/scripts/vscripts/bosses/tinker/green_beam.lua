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
        local radius = 100

        local angleIncrement = 1
        local currentAngle = 1
        local point = caster:GetAbsOrigin() + caster:GetForwardVector() * beam_length

        -- what does this need to do?
        -- similar to chain gun turret and fire shell
        -- it needs to start the findunits in line / particle at caster origin
        -- every tick of the timer it needs to move the end of the particle effect / findunitsinline around in a circle

        -- create particle effect
        local particleName = "particles/tinker/green_phoenix_sunray.vpcf"
        self.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
        caster:SetContextThink( DoUniqueString( "updateSunRay" ), function ( )

            ParticleManager:SetParticleControl(self.pfx, 0, Vector( caster:GetAbsOrigin().x,caster:GetAbsOrigin().y, caster:GetAbsOrigin().z + 100 ))

            local end_pos = ( RotatePosition(caster:GetAbsOrigin(), QAngle(0,currentAngle,0), point ) )
			end_pos = GetGroundPosition( end_pos, nil )
			end_pos.z = caster:GetAbsOrigin().z + 100
            --DebugDrawCircle(end_pos, Vector(0,155,0),128,50,true,60)

            ParticleManager:SetParticleControl( self.pfx, 1, end_pos )

            local units = FindUnitsInLine(
                caster:GetTeamNumber(),
				caster:GetAbsOrigin(),
				end_pos,
				nil,
				radius,
				DOTA_UNIT_TARGET_TEAM_BOTH,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE)

			for _,unit in pairs(units) do
				print(unit:GetUnitName())
			end

            currentAngle = currentAngle + angleIncrement
            return 0.01
        end, 0.0 )

    end
end