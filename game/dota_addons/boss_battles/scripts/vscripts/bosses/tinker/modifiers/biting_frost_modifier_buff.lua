biting_frost_modifier_buff = class({})

function biting_frost_modifier_buff:IsHidden()
	return false
end

function biting_frost_modifier_buff:IsDebuff()
	return false
end

function biting_frost_modifier_buff:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function biting_frost_modifier_buff:OnCreated( kv )
    if IsServer() then


	end
end
---------------------------------------------------------------------------

function biting_frost_modifier_buff:OnDestroy( kv )
    if IsServer() then

	end
end
---------------------------------------------------------------------------