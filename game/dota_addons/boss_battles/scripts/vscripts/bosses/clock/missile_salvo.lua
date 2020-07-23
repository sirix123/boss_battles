missile_salvo = class({})

function missile_salvo:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()


        -- really high level plan
        -- fit smalle sqaures into big square
        -- fire projectile at these squares
            -- have a timer that only creates ~10 at a time and fills up the arena quickly
            -- spawn location is random on the map or just straight above the location on z axis
        -- ability x duration modifier on the spot expires and play particle effect / do dmg
            -- TODO/decide do i have 100 modifiers or just 1 ?

        local point_1 = Vector(13616,14826,256)
        local point_2 = Vector(14650,14826,256)
        local point_3 = Vector(13616,14326,256)
        local point_4 = Vector(14650,14326,256)

        --de bug for corner check
        DebugDrawCircle(point_1,Vector(255,255,255),128,100,true,60)
        DebugDrawCircle(point_2,Vector(255,255,255),128,100,true,60)
        DebugDrawCircle(point_3,Vector(255,255,255),128,100,true,60)
        DebugDrawCircle(point_4,Vector(255,255,255),128,100,true,60)

        local length =          math.abs( point_2.y - point_4.y )
        local width =           math.abs( point_3.x - point_4.x )
        local missile_size =    Vector(50,50,256)

        local nColumns =        math.floor( width / missile_size.x )
        local nRows =           math.floor( length / missile_size.y )

        -- debug math checks
        --print("length ",length)
        --print("width ",width)
        --print("ncolumns ",nColumns)
        --print("nRows ",nRows)

        -- create a table full of positions according for row|column
        local tGrid = {}
        local vPrevCalcPos = point_3
        local vGridLocation = Vector(0, 0, 0)
        for i = 0, nColumns, 1 do
            for j = 0, nRows, 1 do

            vPrevCalcPos = Vector(vPrevCalcPos.x + missile_size.x, vPrevCalcPos.y + missile_size.y, missile_size.z)

            vGridLocation = Vector(vPrevCalcPos.x, vPrevCalcPos.y, missile_size.z)

            table.insert(tGrid, vGridLocation)
            end
        end

        -- debug and pos check
        for i = 1, #tGrid, 1 do
            print("index ", i, "pos ", tGrid[i])
            DebugDrawCircle(tGrid[i],Vector(255,0,0),128,50,true,60)
        end


    end
end
--------------------------------------------------------------------------------
