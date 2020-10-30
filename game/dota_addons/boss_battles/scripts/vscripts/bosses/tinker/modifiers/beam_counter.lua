beam_counter = class({})

function beam_counter:IsHidden()
	return false
end

function beam_counter:IsDebuff()
	return false
end

function beam_counter:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function beam_counter:OnCreated( kv )
    if IsServer() then
	end
end
---------------------------------------------------------------------------

function beam_counter:OnRefresh( kv )
    if IsServer() then
	end
end
---------------------------------------------------------------------------

function beam_counter:OnDestroy( kv )
    if IsServer() then
	end
end
-----------------------------------------------------------------------------
