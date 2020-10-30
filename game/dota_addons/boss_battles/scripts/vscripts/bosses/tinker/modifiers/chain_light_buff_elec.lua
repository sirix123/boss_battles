chain_light_buff_elec = class({})

function chain_light_buff_elec:IsHidden()
	return false
end

function chain_light_buff_elec:IsDebuff()
	return false
end

function chain_light_buff_elec:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function chain_light_buff_elec:OnCreated( kv )
    if IsServer() then

		-- gives proj speed in spell and changes the particle effect
	end
end
---------------------------------------------------------------------------

function chain_light_buff_elec:OnDestroy( kv )
    if IsServer() then

        CreateUnitByName( "npc_elec_ele", self:GetCaster():GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
        CreateUnitByName( "npc_elec_ele", self:GetCaster():GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)

	end
end
---------------------------------------------------------------------------