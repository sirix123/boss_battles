crystal_ai = class({})



--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity.green_beam = thisEntity:FindAbilityByName( "green_beam" )
    thisEntity.spawn_rocks = thisEntity:FindAbilityByName( "spawn_rocks" )
    thisEntity.electric_field_v2 = thisEntity:FindAbilityByName( "electric_field_v2" )

    thisEntity.summon_ice_ele = thisEntity:FindAbilityByName( "summon_ice_ele" )
    thisEntity.summon_fire_ele = thisEntity:FindAbilityByName( "summon_fire_ele" )
    thisEntity.summon_elec_ele = thisEntity:FindAbilityByName( "summon_elec_ele" )

    thisEntity.summon_ice_ele:StartCooldown(thisEntity.summon_ice_ele:GetCooldown(thisEntity.summon_ice_ele:GetLevel()))
    thisEntity.summon_fire_ele:StartCooldown(thisEntity.summon_fire_ele:GetCooldown(thisEntity.summon_fire_ele:GetLevel()))
    thisEntity.summon_elec_ele:StartCooldown(thisEntity.summon_elec_ele:GetCooldown(thisEntity.summon_elec_ele:GetLevel()))

    -- elemental buff phase timer -- summon timer
	thisEntity.ice_phase = false
	thisEntity.fire_phase = false
    thisEntity.elec_phase = false
    thisEntity.start_summoning = 10
    ElementalPhaseTimer()

    thisEntity.stop_timers = false

    thisEntity:SetHullRadius(80)

    thisEntity.beam_phase = false

    thisEntity.beam_stack_count = 0
    thisEntity.total_beams = 1

    thisEntity:SetMana(0)

    thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )

    thisEntity:SetContextThink( "CrystalThinker", CrystalThinker, 0.1 )

    -- during an activation phase particles/units/heroes/hero_rubick/rubick_golem_ambient.vpcf use this particle

end
--------------------------------------------------------------------------------

function CrystalThinker()
	if not IsServer() then return end

    if ( not thisEntity:IsAlive() ) then
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

    for _, friend in pairs(friends) do
        --print("npc unit name", friend:GetUnitName())
        if friend:GetUnitName() == "npc_tinker" then
            if friend:HasModifier("beam_counter") then
                thisEntity.beam_stack_count = friend:FindModifierByName("beam_counter"):GetStackCount()
                --print(" crystakl beam_stack_count ", thisEntity.beam_stack_count)
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

    if thisEntity.beam_phase == false then
        if thisEntity.summon_ice_ele ~= nil and thisEntity.summon_ice_ele:IsFullyCastable() and thisEntity.summon_ice_ele:IsCooldownReady() and thisEntity.ice_phase == true then
            return CastSummonIceEle()
        end

        if thisEntity.summon_fire_ele ~= nil and thisEntity.summon_fire_ele:IsFullyCastable() and thisEntity.summon_fire_ele:IsCooldownReady() and thisEntity.fire_phase == true then
            return CastSummonFireEle()
        end

        if thisEntity.summon_elec_ele ~= nil and thisEntity.summon_elec_ele:IsFullyCastable() and thisEntity.summon_elec_ele:IsCooldownReady() and thisEntity.elec_phase == true then
            return CastSummonElecEle()
        end

    end

    --print("crystal thisEntity:GetManaPercent() ", thisEntity:GetManaPercent())

    if thisEntity:GetManaPercent() == 100 then
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

        -- rough beam duration to go all the way around
        return 30

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
	Timers:CreateTimer(thisEntity.start_summoning,function()
		if thisEntity.stop_timers == true then
			--print("end timer?")
			return false
		end

        --[[
        thisEntity.ice_phase = true
        thisEntity.fire_phase = true
        thisEntity.elec_phase = true
        ]]
        EmitSoundOn( "tinker_tink_ability_marchofthemachines_01", thisEntity )

            if thisEntity.beam_stack_count == 0 then
                thisEntity.ice_phase = true
                thisEntity.fire_phase = false
                thisEntity.elec_phase = false
            elseif thisEntity.beam_stack_count == 2 then
                thisEntity.ice_phase = true
                thisEntity.fire_phase = true
                thisEntity.elec_phase = false
            elseif thisEntity.beam_stack_count == 3 then
                local random_summon_pool = RandomInt(1,3)

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
                end

            elseif thisEntity.beam_stack_count == 5 then
                thisEntity.ice_phase = true
                thisEntity.fire_phase = true
                thisEntity.elec_phase = true
            end


        thisEntity.summon_ice_ele:EndCooldown()
        thisEntity.summon_fire_ele:EndCooldown()
        thisEntity.summon_elec_ele:EndCooldown()

		return 60
	end)
end
--------------------------------------------------------------------------------
