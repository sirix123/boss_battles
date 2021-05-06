spawn_cleaning_bot = class({})

function spawn_cleaning_bot:OnAbilityPhaseStart()
    if IsServer() then

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function spawn_cleaning_bot:OnSpellStart()
    if IsServer() then

        -- flee point calculations
        local ArenaTop = 2700
        local ArenaBot = 425
        local ArenaLeft = -13600
        local ArenaRight = -11000
        local AreanMiddle = Vector((ArenaLeft/2)+(ArenaRight/2), (ArenaTop/2) + (ArenaBot/2), 132) --MID POINT FORMULA: -- (ArenaTop / 2 ) + (ArenaBot / 2)
        self.GyroArenaLocations = {
            Vector(AreanMiddle.x,ArenaTop,132),
            Vector(ArenaRight,ArenaTop,132),
            Vector(ArenaRight,AreanMiddle.y,132),
            Vector(ArenaRight,ArenaBot,132),
            Vector(AreanMiddle.x,ArenaBot,132),
            Vector(ArenaLeft,ArenaBot,132),
            Vector(ArenaLeft,AreanMiddle.y,132),
            Vector(ArenaLeft,ArenaTop,132),
            Vector(ArenaLeft,ArenaTop,132),
            AreanMiddle,
        }

        CreateUnitByName("npc_cleaning_bot", self.GyroArenaLocations[RandomInt(1,#self.GyroArenaLocations)], true, nil, nil, DOTA_TEAM_BADGUYS)

    end
end