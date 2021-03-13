cast_fireball_modifier = class({})

function cast_fireball_modifier:IsHidden()
	return false
end

function cast_fireball_modifier:IsDebuff()
	return false
end

function cast_fireball_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

function cast_fireball_modifier:OnCreated( kv )
	if IsServer() then
    end
end

----------------------------------------------------------------------------

function cast_fireball_modifier:OnDestroy()
	if IsServer() then

	end
end
----------------------------------------------------------------------------
