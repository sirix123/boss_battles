vortex_prison_modifier = class({})

function vortex_prison_modifier:IsHidden()
	return true
end

function vortex_prison_modifier:IsDebuff()
	return true
end

function vortex_prison_modifier:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function vortex_prison_modifier:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()


	end
end
---------------------------------------------------------------------------

function vortex_prison_modifier:OnDestroy( kv )
    if IsServer() then

	end
end
---------------------------------------------------------------------------

function vortex_prison_modifier:CheckState()

	state = {
            [MODIFIER_STATE_FROZEN] = true,
			[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_SILENCED] = true,
            [MODIFIER_STATE_INVISIBLE] = false,
    }

	return state
end
