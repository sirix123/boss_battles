furnace_activate_modifier = class({})

function furnace_activate_modifier:IsHidden()
	return true
end

function furnace_activate_modifier:IsDebuff()
	return false
end

function furnace_activate_modifier:OnCreated( kv )
    if IsServer() then
        print("we are in the modifier")
    end
end
----------------------------------------------------------------------------

function furnace_activate_modifier:OnDestroy()
    if IsServer() then


    end
end
