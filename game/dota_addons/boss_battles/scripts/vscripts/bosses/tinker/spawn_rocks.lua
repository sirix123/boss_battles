spawn_rocks = class({})

LinkLuaModifier( "modifier_rock_push", "bosses/techies/modifiers/modifier_rock_push", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("beam_phase", "bosses/tinker/modifiers/beam_phase", LUA_MODIFIER_MOTION_NONE)

function spawn_rocks:OnAbilityPhaseStart()
    if IsServer() then

        -- find tinker and get the direction from tinker to the crystral, use this as the starting direction vector for the beam
        local friendlies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
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
                friend:AddNewModifier( caster, self, "beam_phase", { duration = -1 } )
            end
        end

        -- play voice line
        EmitSoundOn("techies_tech_suicidesquad_01", self:GetCaster())
        --print("in spell spawning rocks")
        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function spawn_rocks:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local max_lines = 6
        local end_pos_direction = Vector(0,0,0)
        local tAngles = {}

        for i = 1, max_lines, 1 do
            local beam_length = 2700
            local rock_size = 200
            local fit_rocks = ( beam_length / rock_size )
            local tRocks = {}
            local max_rocks_remove = 5

            end_pos_direction = Vector(	RandomFloat( -1 	, 1 ), RandomFloat( -1 , 1 ), 0 ):Normalized()
            local acos = math.acos( Dot(end_pos_direction,caster:GetForwardVector()) / (Mag(end_pos_direction) * Mag(caster:GetForwardVector())))

            if i > 1 then
                for _, angle in pairs(tAngles) do
                    local j = 0 -- limit the number of tries
                    while math.abs(acos - angle) < 30 do
                        j = j + 1
                        if j == 5 then break end
                        end_pos_direction = Vector(	RandomFloat( -1 	, 1 ), RandomFloat( -1 , 1 ), 0 ):Normalized()
                        acos = math.acos( Dot(end_pos_direction,caster:GetForwardVector()) / (Mag(end_pos_direction) * Mag(caster:GetForwardVector())))
                    end
                end

                table.insert(tAngles, math.deg(acos))
            elseif i == 1 then
                table.insert(tAngles, math.deg(acos))
            end

            -- calculate the rock spots along the line
            for i = 1, fit_rocks, 1 do
                local offset = i * rock_size
                local vRock = Vector( caster:GetAbsOrigin().x + ( offset * end_pos_direction.x ), caster:GetAbsOrigin().y + ( offset * end_pos_direction.y ), 132)
                --DebugDrawCircle(vRock, Vector(0,155,0),128,50,true,60)
                table.insert(tRocks, vRock)
            end

            -- remove random amount of rocks
            local remove_rocks = RandomInt(1,max_rocks_remove)
            for i = 1, remove_rocks, 1 do
                table.remove(tRocks, RandomInt(1,#tRocks))
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