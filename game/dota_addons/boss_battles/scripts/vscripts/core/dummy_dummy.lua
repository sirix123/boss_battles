dummy_dummy = class({})

function Spawn( entityKeyValues )

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

    thisEntity:AddNewModifier( nil, nil, "modifier_remove_healthbar", { duration = -1 } )
	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })

end
