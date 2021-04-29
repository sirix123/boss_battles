if disconnect_manager == nil then
    disconnect_manager = class({})
end

function disconnect_manager:Init()

    print("disconnect_manager:Init()")

    Timers:CreateTimer(1.0, function()
        if self.nHeroConnectionState == #HERO_LIST then
            -- send the session data
            SessionManager:SendSessionData()
            return false
        end

        self.nHeroConnectionState = 0
        local hero_state = 0

        if HERO_LIST then
            for _, hero in pairs(HERO_LIST) do
                hero_state = PlayerResource:GetConnectionState(hero.playerId)
                print("hero_state ",hero_state)
                if hero_state == 1 then -- still need to figure out what state is disconnected
                    self.nHeroConnectionState = self.nHeroConnectionState + 1
                end
            end
        end

        return 1.0
    end)

end
--------------------------------------------------------------------------------------------------