spawn_rocks = class({})

LinkLuaModifier( "modifier_rock_push", "bosses/techies/modifiers/modifier_rock_push", LUA_MODIFIER_MOTION_NONE )

function spawn_rocks:OnAbilityPhaseStart()
    if IsServer() then

        -- play voice line
        EmitSoundOn("rubick_rub_arc_pain_04", self:GetCaster())
        EmitSoundOn("rubick_rub_arc_attack_06", self:GetCaster())
        --print("in spell spawning rocks")
        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function spawn_rocks:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local end_pos_direction = Vector(0,0,0)
        local currentAngle = 0

        --for i = 1, max_lines, 1 do
        local beam_length = 2500
        local rock_size = 200
        local fit_rocks = ( beam_length / rock_size )
        local tRocks = {}
        local max_rocks_remove = 9
        local min_rocks_remove = 4

        local maxAngle = 360 --increase beyond 360 for ... more laps around, more density. You probably don't want that.
        local minIncrement = 20
        while (currentAngle < maxAngle) do

            local randomIncrement = RandomInt(1,30) --TODO: make this random val between 1 and 30?
            currentAngle =  currentAngle + ( minIncrement + randomIncrement )
            local radAngle = currentAngle * 0.0174532925 --angle in radians
            local point = Vector(beam_length * math.cos(radAngle), beam_length * math.sin(radAngle), 0)
            end_pos_direction = point:Normalized()

            -- calculate the rock spots along the line
            for i = 1, fit_rocks, 1 do
                local offset = i * rock_size
                local vRock = Vector( caster:GetAbsOrigin().x + ( offset * end_pos_direction.x ), caster:GetAbsOrigin().y + ( offset * end_pos_direction.y ), 132)
                --DebugDrawCircle(vRock, Vector(0,155,0),128,50,true,60)
                table.insert(tRocks, vRock)
            end

            --DebugDrawLine_vCol(caster:GetAbsOrigin(), caster:GetAbsOrigin() + ( end_pos_direction * beam_length ) , Vector(255,0,0), true, 8)

            -- remove random amount of rocks
            local remove_rocks = RandomInt(min_rocks_remove,max_rocks_remove)
            for i = 1, remove_rocks, 1 do
                table.remove(tRocks, RandomInt(1,#tRocks))
            end
        end

        -- encase this in a timer... (spawning the rocks, then before this comment rumble the ground) this is wrok around... 
        -- kill the player if they stand on the rocks spawning...
        -- can remove the pushback code then... also add a particle effect
        -- how to show them rising from the ground?
        -- going to have to create a particle effect with that rock model...when the effect ends spawns the model in the same spot...
        for _, rock in pairs(tRocks) do
            --print("ROCKS")
            --DebugDrawCircle(rock, Vector(0,155,0),128,50,true,60)
            -- play particle effect at each location (swirl)
            --particles/tinker/tinker_rock_spawns_enigma_blackhole_ti5_dark_swirl.vpcf "particles/custom/swirl/dota_swirl.vpcf"
            local particle_rock_spawn = "particles/custom/swirl/dota_swirl.vpcf"
            local particle_effect_rock_spawn = ParticleManager:CreateParticle( particle_rock_spawn, PATTACH_WORLDORIGIN, self:GetCaster() )
            ParticleManager:SetParticleControl(particle_effect_rock_spawn, 0, rock )
            ParticleManager:SetParticleControl(particle_effect_rock_spawn, 1, Vector(5,0,0) )
            ParticleManager:ReleaseParticleIndex(particle_effect_rock_spawn)

        end

        Timers:CreateTimer(5, function()

            -- for rocks that remain, spawn them, at each location check for units and kill him,
            for _, rock in pairs(tRocks) do
                local rock_unit = CreateUnitByName("npc_rock", rock, true, nil, nil, DOTA_TEAM_BADGUYS)
                rock_unit:SetHullRadius(rock_size - 60 )
                rock_unit:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )

                -- find units around each rock and push them back (apply the modifier)
                --self:PushBack( rock )

                -- kill anyone on top of a rock that spawns
                self:KillUnits( rock )
            end

            return false
        end)

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function spawn_rocks:PushBack( vRock )
    if IsServer() then

        -- find units
        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            vRock,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            150,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        -- apply modifier
        if units ~= nil or #units ~= 0 then
            for _, unit in pairs(units) do
                EmitSoundOn("DOTA_Item.ForceStaff.Activate", unit)
                unit:AddNewModifier(self:GetCaster(), ability, "modifier_stomp_push", {duration = 1})
            end
        end

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function spawn_rocks:KillUnits( pos )
    if IsServer() then

        -- find units
        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            pos,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            105,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        -- apply modifier
        if units ~= nil or #units ~= 0 then
            for _, unit in pairs(units) do
                unit:ForceKill(false)
            end
        end

    end
end