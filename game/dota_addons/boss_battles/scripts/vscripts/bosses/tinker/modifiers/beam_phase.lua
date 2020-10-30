beam_phase = class({})

function beam_phase:IsHidden()
	return false
end

function beam_phase:IsDebuff()
	return false
end

function beam_phase:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function beam_phase:OnCreated( kv )
	if IsServer() then

		--print("are we resetting tp cd?")
		--print(self:GetParent():GetAbilityByIndex(0))
		self:GetParent():GetAbilityByIndex(0):EndCooldown()

	end
end
---------------------------------------------------------------------------

function beam_phase:OnRefresh( kv )
    if IsServer() then
	end
end
---------------------------------------------------------------------------

function beam_phase:OnDestroy( kv )
    if IsServer() then
	end
end
-----------------------------------------------------------------------------
