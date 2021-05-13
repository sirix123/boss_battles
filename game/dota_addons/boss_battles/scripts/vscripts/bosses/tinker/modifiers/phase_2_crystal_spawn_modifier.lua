phase_2_crystal_spawn_modifier = class({})

function phase_2_crystal_spawn_modifier:IsHidden()
	return false
end

function phase_2_crystal_spawn_modifier:IsDebuff()
	return true
end

function phase_2_crystal_spawn_modifier:GetEffectName()
	return "particles/tinker/tinker_remote_gyro_guided_missile_target.vpcf"
end

function phase_2_crystal_spawn_modifier:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function phase_2_crystal_spawn_modifier:OnCreated( kv )
    if IsServer() then

    end
end

function phase_2_crystal_spawn_modifier:OnRefresh(table)
    if IsServer() then

    end
end

function phase_2_crystal_spawn_modifier:OnDestroy()
    if IsServer() then

        -- add a swirl particle to the floor (store it in a table the index and destroy in tinker transition phase)
        local particle_rock_spawn = "particles/custom/swirl/green_dota_swirl.vpcf"
        local particle_effect_rock_spawn = ParticleManager:CreateParticle( particle_rock_spawn, PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl(particle_effect_rock_spawn, 0, self:GetParent():GetAbsOrigin() )
        table.insert(Crystal_Phase1_Spawns_Particles,particle_effect_rock_spawn)

        -- add the location to the global table
        table.insert(Crystal_Phase2_Spawns,self:GetParent():GetAbsOrigin())

    end
end

--------------------------------------------------------------------------------