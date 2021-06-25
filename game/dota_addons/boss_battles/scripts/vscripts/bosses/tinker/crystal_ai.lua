crystal_ai = class({})
LinkLuaModifier("modifier_rubick", "bosses/tinker/modifiers/modifier_rubick", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("phase_2_crystal_spawn_modifier", "bosses/tinker/modifiers/phase_2_crystal_spawn_modifier", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------
function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    local boss_name = "Prism"
    boss_frame_manager:SendBossName( boss_name )
    boss_frame_manager:UpdateManaHealthFrame( thisEntity )
    boss_frame_manager:ShowBossHpFrame()
	boss_frame_manager:ShowBossManaFrame()

    thisEntity.green_beam = thisEntity:FindAbilityByName( "green_beam" )
    thisEntity.spawn_rocks = thisEntity:FindAbilityByName( "spawn_rocks" )
    thisEntity.electric_field_v2 = thisEntity:FindAbilityByName( "electric_field_v2" )

    thisEntity.summon_ice_ele = thisEntity:FindAbilityByName( "summon_ice_ele" )
    thisEntity.summon_fire_ele = thisEntity:FindAbilityByName( "summon_fire_ele" )
    thisEntity.summon_elec_ele = thisEntity:FindAbilityByName( "summon_elec_ele" )

    thisEntity.summon_ice_ele:StartCooldown(thisEntity.summon_ice_ele:GetCooldown(thisEntity.summon_ice_ele:GetLevel()))
    thisEntity.summon_fire_ele:StartCooldown(thisEntity.summon_fire_ele:GetCooldown(thisEntity.summon_fire_ele:GetLevel()))
    thisEntity.summon_elec_ele:StartCooldown(thisEntity.summon_elec_ele:GetCooldown(thisEntity.summon_elec_ele:GetLevel()))

    -- spawn rubick inside this unit
    thisEntity.rubick = CreateUnitByName( "npc_rubick", Vector(-10673,11950,0), false, thisEntity, thisEntity, DOTA_TEAM_BADGUYS)
    thisEntity.rubick:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
    thisEntity.rubick:AddNewModifier( nil, nil, "modifier_rubick", { duration = -1 } )
    local vec = Vector(0, -1, 0)
    thisEntity.rubick:SetForwardVector( vec )
    thisEntity.rubick:SetHullRadius(1)

    -- elemental buff phase timer -- summon timer
	thisEntity.ice_phase = false
	thisEntity.fire_phase = false
    thisEntity.elec_phase = false
    thisEntity.start_summoning = 3
    ElementalPhaseTimer()

    CrystalPhase2Spawner()

    thisEntity.stop_timers = false

    thisEntity:SetHullRadius(100)

    thisEntity.beam_phase = false

    thisEntity.beam_stack_count = 0 -- 0
    thisEntity.total_beams = 3 -- 3

    thisEntity:SetMana(0)

    thisEntity.check_tinker = false

    thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )

    local spawn_1 = Entities:FindByName(nil, "tinker_add_spawn_1"):GetAbsOrigin()
    local spawn_2 = Entities:FindByName(nil, "tinker_add_spawn_2"):GetAbsOrigin()
    local spawn_3 = Entities:FindByName(nil, "tinker_add_spawn_3"):GetAbsOrigin()
    local spawn_4 = Entities:FindByName(nil, "tinker_add_spawn_4"):GetAbsOrigin()
    local tSpawns = {spawn_1, spawn_2, spawn_3, spawn_4}
    local random_index_1 = Vector(0,0,0)
    Timers:CreateTimer(5,function()
        if IsValidEntity(thisEntity) == false then return false end

        random_index_1 = RandomInt(1,#tSpawns)

        local particle = "particles/tinker/summon_elementals_portal_open_good.vpcf"
        thisEntity.effect_cast_1 = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(thisEntity.effect_cast_1, 0, tSpawns[random_index_1])
        ParticleManager:ReleaseParticleIndex(thisEntity.effect_cast_1)

        Timers:CreateTimer(1.0,function()
            if IsValidEntity(thisEntity) == false then return false end

            CreateUnitByName( "npc_charge_bot", tSpawns[random_index_1], true, nil, nil, DOTA_TEAM_BADGUYS)

            return false
        end)

        return 40
    end)

    thisEntity:SetContextThink( "CrystalThinker", CrystalThinker, 0.1 )

    -- during an activation phase particles/units/heroes/hero_rubick/rubick_golem_ambient.vpcf use this particle

end
--------------------------------------------------------------------------------

function CrystalThinker()
	if not IsServer() then return end

    if ( not thisEntity:IsAlive() ) then
        Timers:RemoveTimer(thisEntity.elemental_timer)
        thisEntity.stop_timers = true
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
    end

    -- find tinker and if he has x stacks of the modifier do something else...
    local friends = FindUnitsInRadius(
        thisEntity:GetTeamNumber(),
        thisEntity:GetAbsOrigin(),
        nil,
        4000,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_CLOSEST,
        false
    )

    if #friends == 0 then
        --print("#friends ", #friends)
		return 0.5
    end

    if thisEntity.check_tinker == true then
        for _, friend in pairs(friends) do
            --print("npc unit name", friend:GetUnitName())
            if friend:GetUnitName() == "npc_tinker" then
                if friend:HasModifier("beam_counter") then
                    thisEntity.beam_stack_count = friend:FindModifierByName("beam_counter"):GetStackCount()

                    if thisEntity.beam_stack_count == 0 then
                        thisEntity.check_tinker = false
                        return
                    else
                        -- remove hp from crystal
                        thisEntity:SetHealth( thisEntity:GetHealth() -  ( thisEntity:GetMaxHealth() /  thisEntity.total_beams ))

                        print("thisEntity:GetMaxHealth() ",thisEntity:GetMaxHealth())
                        print("thisEntity:currenheath() ",thisEntity:GetHealth())
                        print("--------------------")

                        thisEntity.check_tinker = false
                    end


                end
            end
        end
    end

    -- start next phase
    if thisEntity.beam_stack_count == thisEntity.total_beams then
        -- do cool stuff when destroyed and setup arena
        CastDestroySelf()

        --thisEntity:RemoveSelf()
        return 1
    end

    if thisEntity.electric_field_v2 ~= nil and thisEntity.electric_field_v2:IsFullyCastable() and thisEntity.electric_field_v2:IsCooldownReady() and thisEntity:HasModifier("cast_electric_field") then
        thisEntity:RemoveModifierByName("cast_electric_field")
        return CastElectricField()
    end

    --if thisEntity.beam_phase == false then
        if thisEntity.summon_ice_ele ~= nil and thisEntity.summon_ice_ele:IsFullyCastable() and thisEntity.summon_ice_ele:IsCooldownReady() and thisEntity.ice_phase == true then
            return CastSummonIceEle()
        end

        if thisEntity.summon_fire_ele ~= nil and thisEntity.summon_fire_ele:IsFullyCastable() and thisEntity.summon_fire_ele:IsCooldownReady() and thisEntity.fire_phase == true then
            return CastSummonFireEle()
        end

        if thisEntity.summon_elec_ele ~= nil and thisEntity.summon_elec_ele:IsFullyCastable() and thisEntity.summon_elec_ele:IsCooldownReady() and thisEntity.elec_phase == true then
            return CastSummonElecEle()
        end

    --end

    --print("crystal thisEntity:GetManaPercent() ", thisEntity:GetManaPercent())

    if thisEntity:GetManaPercent() == 100 then
        thisEntity:SetBaseManaRegen(0)
        thisEntity.beam_phase = true
        thisEntity.green_beam:EndCooldown()
        thisEntity.spawn_rocks:EndCooldown()

        if thisEntity.spawn_rocks ~= nil and thisEntity.spawn_rocks:IsFullyCastable() and thisEntity.spawn_rocks:IsCooldownReady() then
            SpawnRocks()
        end

        Timers:CreateTimer(7,function()

            if thisEntity.green_beam ~= nil and thisEntity.green_beam:IsFullyCastable() and thisEntity.green_beam:IsCooldownReady() then
                CastGreenBeam()
            end

            return false

        end)

        thisEntity:SetMana(0)
        thisEntity.beam_phase = false
        thisEntity.check_tinker = true

        -- rough beam duration to go all the way around
        return 40

    end

	return 0.5
end
--------------------------------------------------------------------------------

function CastGreenBeam(  )

    

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.green_beam:entindex(),
        Queue = false,
    })

end
--------------------------------------------------------------------------------

function SpawnRocks(  )
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.spawn_rocks:entindex(),
        Queue = false,
    })

end
--------------------------------------------------------------------------------

function CastElectricField(  )
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.electric_field_v2:entindex(),
        Queue = false,
    })
    return 1
end
--------------------------------------------------------------------------------

function CastDestroySelf(  )

end
--------------------------------------------------------------------------------

function CastSummonIceEle(  )
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.summon_ice_ele:entindex(),
        Queue = false,
    })
    return 1
end
--------------------------------------------------------------------------------

function CastSummonFireEle(  )
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.summon_fire_ele:entindex(),
        Queue = false,
    })
    return 1
end
--------------------------------------------------------------------------------

function CastSummonElecEle(  )
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.summon_elec_ele:entindex(),
        Queue = false,
    })
    return 1
end
--------------------------------------------------------------------------------

function ElementalPhaseTimer()
    thisEntity.elemental_timer = Timers:CreateTimer(thisEntity.start_summoning,function()
        if IsValidEntity(thisEntity) == false then return false end


		if thisEntity.stop_timers == true then
			--print("end timer?")
			return false
		end

        --[[
        thisEntity.ice_phase = true
        thisEntity.fire_phase = true
        thisEntity.elec_phase = true
        ]]
        --EmitSoundOn( "tinker_tink_ability_marchofthemachines_01", thisEntity )

            if thisEntity.beam_stack_count == 0 then
                thisEntity.ice_phase = true
                thisEntity.fire_phase = false
                thisEntity.elec_phase = false
            elseif thisEntity.beam_stack_count == 1 then
                thisEntity.ice_phase = true
                thisEntity.fire_phase = true
                thisEntity.elec_phase = true
            elseif thisEntity.beam_stack_count >= 2 then

                thisEntity.ice_phase = true
                thisEntity.fire_phase = true
                thisEntity.elec_phase = true


                --[[local random_summon_pool = RandomInt(1,3)

                if random_summon_pool == 1 then
                    thisEntity.ice_phase = true
                    thisEntity.fire_phase = true
                    thisEntity.elec_phase = false
                elseif random_summon_pool == 2 then
                    thisEntity.ice_phase = true
                    thisEntity.fire_phase = false
                    thisEntity.elec_phase = true
                elseif random_summon_pool == 3 then
                    thisEntity.ice_phase = false
                    thisEntity.fire_phase = true
                    thisEntity.elec_phase = true
                end]]

            elseif thisEntity.beam_stack_count >= 3 then
                thisEntity.ice_phase = true
                thisEntity.fire_phase = true
                thisEntity.elec_phase = true
            end

        --thisEntity.summon_ice_ele:EndCooldown()
        --thisEntity.summon_fire_ele:EndCooldown()
        --thisEntity.summon_elec_ele:EndCooldown()

		return 10
	end)
end
--------------------------------------------------------------------------------

function CrystalPhase2Spawner()
    Timers:CreateTimer(5,function()
        if IsValidEntity(thisEntity) == false then return false end

		if thisEntity.stop_timers == true then
			return false
		end

        -- pick a random enemy and apply the phase_2_crystal_spawn_modifier to them
        
        local enemies = FindUnitsInRadius(
            thisEntity:GetTeamNumber(),
            thisEntity:GetAbsOrigin(),
            nil,
            4000,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_CLOSEST,
            false
        )

        if enemies == nil or #enemies == 0 then
            return 1
        else
            local target = enemies[RandomInt(1,#enemies)]
            target:AddNewModifier( target, nil, "phase_2_crystal_spawn_modifier", { duration = 7 } )
        end

		return 15
	end)
end
--------------------------------------------------------------------------------
