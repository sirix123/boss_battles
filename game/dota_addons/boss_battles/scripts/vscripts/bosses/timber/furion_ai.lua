furion_ai = class({})

function Spawn( entityKeyValues )

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	-- set mana to 0 on spawn
	thisEntity:SetMana(0)

	thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )

end