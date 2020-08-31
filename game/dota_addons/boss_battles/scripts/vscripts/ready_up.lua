ready = class({})

function ready_up(trigger)

    local ent = trigger.activator

    if not ent then return end

    --PrintTable(trigger, indent, done)

    -- logic todo etc
    --[[


    4 triggers, all trigger the same trigger script (this one)

    record what playerID is touching it,
    if a playerid has touched one don't let them activate another
    once they touch it, it is activated (show something) (handle this on an AI file for the actual model IMO with the thinker very basic)
    how can we link this file to gamesetup to manage the tp'ing? and call a functionin gamesetup?
        I guess we just 'require this script' in gamesetup and run the function from here?
                quick POC! it works!!!!!!!!!!!!!!!!!!!!!!

    summary all we need is the logic for activation in here

    ]]

    GameSetup:Test123()

end

function ready:ReadyCheck()


    return true
end
