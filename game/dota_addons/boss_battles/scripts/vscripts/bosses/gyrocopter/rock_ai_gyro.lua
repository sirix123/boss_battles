rock_ai_gyro = class({})
LinkLuaModifier( "gyro_field_thinker", "bosses/gyrocopter/gyro_field_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "vortex_prison_modifier", "bosses/clock/modifiers/vortex_prison_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned", "core/modifier_generic_stunned", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity:SetContextThink( "RockThinker", RockThinker, 0.1 )

end
--------------------------------------------------------------------------------

function RockThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then

		if thisEntity:GetUnitName() == "npc_gyro_ring_blocker" then
			local particle = "particles/units/heroes/hero_rubick/rubick_chaos_meteor_cubes.vpcf"
			local nfx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(nfx , 3, thisEntity:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(nfx)
		elseif thisEntity:GetUnitName() == "npc_gyro_ring_blocker_blue" then
			local particle = "particles/gyrocopter/blue_rubick_chaos_meteor_cubes.vpcf"
			local nfx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(nfx , 3, thisEntity:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(nfx)
			OnRockDeathEffects(thisEntity)
		elseif thisEntity:GetUnitName() == "npc_gyro_ring_blocker_red" then
			local particle = "particles/gyrocopter/red_rubick_chaos_meteor_cubes.vpcf"
			local nfx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(nfx , 3, thisEntity:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(nfx)
			OnRockDeathEffects(thisEntity)
		elseif thisEntity:GetUnitName() == "npc_gyro_ring_blocker_purple" then
			local particle = "particles/gyrocopter/red_rubick_chaos_meteor_cubes.vpcf"
			local nfx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(nfx , 3, thisEntity:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(nfx)
			OnRockDeathEffects(thisEntity)
		end

		UTIL_RemoveImmediate(thisEntity)
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	return 0.5
end
--------------------------------------------------------------------------------

function OnRockDeathEffects(unit)

	if unit:GetUnitName() == "npc_gyro_ring_blocker_blue" then

		thisEntity.gyro_field_thinker = CreateModifierThinker(
            unit,
            self,
            "gyro_field_thinker",
            {
                duration = 15,
                target_x = unit:GetAbsOrigin().x,
                target_y = unit:GetAbsOrigin().y,
                target_z = unit:GetAbsOrigin().z,
            },
            unit:GetAbsOrigin(),
            unit:GetTeamNumber(),
            false
        )

	elseif unit:GetUnitName() == "npc_gyro_ring_blocker_red" then
		local friendly = FindUnitsInRadius(
			unit:GetTeamNumber(),
            unit:GetAbsOrigin(),
            nil,
            200,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_ANY_ORDER,
            false )

        if friendly ~= nil and #friendly ~= 0 then
            for _, friend in pairs(friendly) do
                if friend:GetUnitName() == "npc_gyro_ring_blocker" or friend:GetUnitName() == "npc_gyro_ring_blocker_blue" or friend:GetUnitName() == "npc_gyro_ring_blocker_red" then

					local particle = "particles/units/heroes/hero_rubick/rubick_chaos_meteor_cubes.vpcf"
					local nfx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
					ParticleManager:SetParticleControl(nfx , 3, friend:GetAbsOrigin())
					ParticleManager:ReleaseParticleIndex(nfx)

					local particle_2 = "particles/econ/items/shadow_fiend/sf_desolation/sf_base_attack_desolation_explode.vpcf"
					local nfx_2 = ParticleManager:CreateParticle(particle_2, PATTACH_WORLDORIGIN, nil)
					ParticleManager:SetParticleControl(nfx_2 , 0, friend:GetAbsOrigin())
					ParticleManager:ReleaseParticleIndex(nfx_2)

                    friend:RemoveSelf()
                end
            end
        end
	elseif unit:GetUnitName() == "npc_gyro_ring_blocker_purple" then
		local friendly = FindUnitsInRadius(
			unit:GetTeamNumber(),
            unit:GetAbsOrigin(),
            nil,
            9000,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_ANY_ORDER,
            false )

        if friendly ~= nil and #friendly ~= 0 then
            for _, friend in pairs(friendly) do
                if friend:GetUnitName() == "npc_gyrocopter" then

					EmitSoundOn( "Hero_Rubick.FadeBolt.Cast", unit )

					friend:AddNewModifier( unit, nil, "modifier_generic_stunned", { duration = 15 } )

					local nFXIndex = ParticleManager:CreateParticle( "particles/gyrocopter/gyro_rubick_ti8_immortal_fade_bolt.vpcf", PATTACH_CUSTOMORIGIN, nil )
					ParticleManager:SetParticleControl(nFXIndex, 0, unit:GetAbsOrigin())
					ParticleManager:SetParticleControlEnt( nFXIndex, 1, friend, PATTACH_POINT_FOLLOW, "attach_hitloc", friend:GetOrigin(), true )
					ParticleManager:ReleaseParticleIndex( nFXIndex )

                end
            end
        end
	end
end
