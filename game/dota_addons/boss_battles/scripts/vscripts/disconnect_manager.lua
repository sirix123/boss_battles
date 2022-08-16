if disconnect_manager == nil then
    disconnect_manager = class({})
end

function disconnect_manager:Init()
    self.disconnected_players = {}
    self.disconnected_players_count = 0

    Timers:CreateTimer(30,function()

        if (    GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS   and PICKING_DONE == true   or
                GameRules:State_Get() == DOTA_GAMERULES_STATE_DISCONNECT         and PICKING_DONE == true   or
                GameRules:State_Get() == DOTA_GAMERULES_STATE_POST_GAME          and PICKING_DONE == true ) and
                nBOSSES_KILLED ~= 8
        then

            -- print("#HERO_LIST ",#HERO_LIST)
            -- print("self.disconnected_players_count ",self.disconnected_players_count)

            if self.disconnected_players_count == #HERO_LIST then
                print("dc sending session data")
                bGAME_COMPLETE = false
                SessionManager:SendSessionData( )
                return false
            end

        end

        return 1
    end)


end
--------------------------------------------------------------------------------------------------

function disconnect_manager:PlayerDisconnect( )
    --table.insert(self.disconnected_players,DisconHeroId)
    self.disconnected_players_count = self.disconnected_players_count + 1
end
--------------------------------------------------------------------------------------------------

function disconnect_manager:PlayerReconnect(  )
    self.disconnected_players_count = self.disconnected_players_count - 1
end
--------------------------------------------------------------------------------------------------