if intermission_manager == nil then
    intermission_manager = class({})
end

function intermission_manager:SpawnTestingStuff(keys)

    --[[ flame turrets for right side of the map, need to change facing vector
    local flame_turret_1 = CreateUnitByName("npc_flame_turret", Vector(-10154,-8652,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    flame_turret_1:SetForwardVector(Vector(0,-1, flame_turret_1.z ))

    local flame_turret_2 = CreateUnitByName("npc_flame_turret", Vector(-9511,-8652,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    flame_turret_2:SetForwardVector(Vector(0,-1, flame_turret_2.z ))

    local flame_turret_3 = CreateUnitByName("npc_flame_turret", Vector(-9744,-11704,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    flame_turret_3:SetForwardVector(Vector(0,1, flame_turret_3.z ))]]

    -- create test item
    --local newItem = CreateItem("item_tango", nil, nil)
    --CreateItemOnPositionForLaunch( Vector(-10000,-10000,256), newItem )

    -- target dummy (1 by itself)(immortal)
    local dummy_1 = CreateUnitByName("npc_dota_creature_dummy_target_boss_immortal", Vector(-12276,-10346,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    dummy_1:SetForwardVector(Vector(0,-1, dummy_1.z ))

    -- target dummy (1 by itself)
    --CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(-11744,-9369,256), true, nil, nil, DOTA_TEAM_BADGUYS)

    -- target dummy (3)
    local dummy_2 = CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(-11776,-10352,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    dummy_2:SetForwardVector(Vector(0,-1, dummy_2.z ))

    local dummy_3 = CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(-11776,-10352,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    dummy_3:SetForwardVector(Vector(0,-1, dummy_3.z ))

    local dummy_4 = CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(-11776,-10352,256), true, nil, nil, DOTA_TEAM_BADGUYS)
    dummy_4:SetForwardVector(Vector(0,-1, dummy_4.z ))

    -- target dummy (1 moving)
    --CreateUnitByName("npc_dota_creature_gnoll_assassin_moving", Vector(-11077,-8747,256), true, nil, nil, DOTA_TEAM_BADGUYS)

    -- target dummy friendly
    local dummy_5 = CreateUnitByName("npc_dota_creature_dummy_target_boss", Vector(-12663,-10344,256), true, nil, nil, DOTA_TEAM_GOODGUYS)
    dummy_5:SetForwardVector(Vector(0,-1, dummy_5.z ))

    --test
    --PrintTable(RAID_TABLES, indent, done)

end
--------------------------------------------------------------------------------------------------