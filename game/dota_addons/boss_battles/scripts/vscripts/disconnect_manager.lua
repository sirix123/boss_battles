if disconnect_manager == nil then
    disconnect_manager = class({})
end

function disconnect_manager:Init()

    print("disconnect_manager:Init()")

    local count = 0

    Timers:CreateTimer(function()

        if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS   and PICKING_DONE == true or
           GameRules:State_Get() == DOTA_GAMERULES_STATE_DISCONNECT         and PICKING_DONE == true or
           GameRules:State_Get() == DOTA_GAMERULES_STATE_POST_GAME          and PICKING_DONE == true
        then

            for _, hero in pairs(HERO_LIST) do
                if hero.isConnected == false then
                    count = count + 1
                end
            end

            if count == #HERO_LIST then
                bGAME_COMPLETE = false
                SessionManager:SendSessionData( )
                return false
            end

            --print("#HERO_LIST ",#HERO_LIST)
            --print("count ",count)

            count = 0
        end

        return 0.5
    end)

end
--------------------------------------------------------------------------------------------------