spawn_rocks = class({})

LinkLuaModifier( "modifier_rock_push", "bosses/techies/modifiers/modifier_rock_push", LUA_MODIFIER_MOTION_NONE )

function spawn_rocks:OnAbilityPhaseStart()
    if IsServer() then

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
        local max_lines = 4

        -- todo, push units away in the area where the rocks spawn (sml push and fast)
        -- min angle
        -- i think ned to start spawning at some offset from the centre cause of the models that will be in the centre

        for i = 1, max_lines, 1 do
            --print("in spell spawning rocks")
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

                -- find units around each rock and push them back (apply the modifier)
                self:PushBack( rock )
            end
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
            80,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        -- apply modifier
        if self.units ~= nil or #self.units ~= 0 then
            for _, unit in pairs(self.units) do
                EmitSoundOn("DOTA_Item.ForceStaff.Activate", unit)
                unit:AddNewModifier(self:GetCaster(), ability, "modifier_stomp_push", {duration = 0.5})
            end
        end

    end
end