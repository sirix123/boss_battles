
gyro_bubble = class({})


-----------------------------------------------------------------------------

function gyro_bubble:OnCreated(  )
    if IsServer() then

        -- push back enemies to edge of arena (wind gust em)

        -- start channeling calldown

    end
end

function gyro_bubble:OnRemoved()
    if IsServer() then
    end
end

function gyro_bubble:OnDestroy()
    if IsServer() then
    end
end

-----------------------------------------------------------------------------