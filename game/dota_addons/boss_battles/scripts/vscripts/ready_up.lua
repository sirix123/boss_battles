local tTriggers = {}
local DEBUG = false

function OnStartTouch(trigger)

    local ent = trigger.activator
    if not ent then return end

    --PrintTable(trigger, indent, done)

    ent.ready_up = true

    local allHeroesAreReady = true --start on true, then set to false if you find one not ready
    local heroes = HERO_LIST
    for _, hero in pairs(heroes) do
        if hero.ready_up == false then
            allHeroesAreReady = false
            break
        end
    end
    if allHeroesAreReady then
        if BOSS_BATTLES_ENCOUNTER_COUNTER < 8 then
            GameSetup:ReadyupCheck()
        end
    end

    --[[local triggerName = thisEntity:GetName()

    -- if triggername is not in the table then add it... (so 4 people can't stand on the same trigger)
    table.insert(tTriggers,triggerName)

    if #tTriggers == #HERO_LIST or DEBUG then
        -- need to clear the table here, so can be re-used
        tTriggers = {}
        GameSetup:ReadyupCheck()
    end]]

end

function OnEndTouch( trigger )

    local ent = trigger.activator
    if not ent then return end

    ent.ready_up = false -- could move this to gamesetup ready up check.,.. and reset ... that way... it will only fire once.. but once you ready up.. you ready up..(for good until next boss)

    --[[local triggerName = thisEntity:GetName()

    for k, triggers in pairs(tTriggers) do
        if triggerName == triggers then
            table.remove(tTriggers,k)
        end
    end]]
end

--[[function OnStartTouchAnimation( trigger )

    --PrintTable(trigger, indent, done)
    local triggerName = thisEntity:GetName()

    PrintTable(thisEntity, indent, done)
    thisEntity:StartGestureWithPlaybackRate(ACT_DOTA_CAPTURE, 1.0)

    --DoEntFire(triggerName, "SetAnimation", "ancient_trigger001_down", 0, self, self)
    --EntFire: Generate an entity i/o event ( szTarget, szAction, szValue, flDelay, hActivator, hCaller )

    --thisEntity:SetAnimation( "ancient_trigger001_down" )
    --trigger.caller:GetOwnerEntity():StartGestureWithPlaybackRate(ACT_DOTA_CAPTURE, 1.0)
    -- ancient_trigger001_down ACT_DOTA_ATTACK ACT_DOTA_CAPTURE
end]]