spawn_rocks = class({})

--LinkLuaModifier( "spawn_rocks_modifier", "bosses/techies/modifiers/spawn_rocks_modifier", LUA_MODIFIER_MOTION_BOTH  )

function spawn_rocks:OnAbilityPhaseStart()
    if IsServer() then

        -- play voice line
        EmitSoundOn("techies_tech_suicidesquad_01", self:GetCaster())

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function spawn_rocks:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()

        -- calculate line (caster + arena radius)
        -- calculate a random directional vector
        -- line length
        -- rock size (radius/hitbox)
        -- how many rocks can we fit in the line?

        -- get a vector location for each rock along the line
        -- insert rocks into the table
        -- randomly remove 1/multiple rocks up to xyz amount
        -- for rocks in the table spawn them
        -- make it look like a sexy fissure?

        local max_lines = 4

        for i = 1, max_lines, 1 do
            local beam_length = 3000
            local rock_size = 200
            local fit_rocks = ( beam_length / rock_size )
            local tRocks = {}
            local max_rocks_remove = 5

            --local angle = RandomInt(1,360)
            --local point = caster:GetAbsOrigin() + caster:GetForwardVector() * beam_length

            --local end_pos_direction = ( RotatePosition(caster:GetAbsOrigin(), QAngle(0,angle,0), point ) ):Normalized()
            local end_pos_direction = Vector(	RandomFloat( -1 	, 1 ), RandomFloat( -1 , 1 ), 0 ):Normalized()

            -- calculate the rock spots along the line
            for i = 1, fit_rocks, 1 do
                local offset = i * rock_size
                local vRock = Vector( caster:GetAbsOrigin().x + ( offset * end_pos_direction.x ), caster:GetAbsOrigin().y + ( offset * end_pos_direction.y ), 0)
                --DebugDrawCircle(vRock, Vector(0,155,0),128,50,true,60)
                table.insert(tRocks, vRock)
            end

            -- remove random amount of rocks
            local remove_rocks = RandomInt(1,max_rocks_remove)
            for i = 1, remove_rocks, 1 do
                table.remove(tRocks, RandomInt(1,#tRocks))
            end

            -- for rocks that remain, spawn them
            for _, rock in pairs(tRocks) do
                local rock_unit = CreateUnitByName("npc_rock", rock, true, nil, nil, DOTA_TEAM_BADGUYS)
                rock_unit:SetHullRadius(rock_size - 60 )
                rock_unit:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
            end
        end
    end
end