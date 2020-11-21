
function fishtrigger(trigger)

        local ent = trigger.activator

        if not ent then return end

        ent:ForceKill(true)

    return 0.1
end