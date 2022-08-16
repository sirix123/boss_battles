primal_rock_prison_breaker_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function primal_rock_prison_breaker_modifier:IsHidden()
	return false
end

function primal_rock_prison_breaker_modifier:IsDebuff()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function primal_rock_prison_breaker_modifier:OnCreated( kv )
	if not IsServer() then return end

	self.caster = self:GetCaster()
	self.parent = self:GetParent()

	self:PlayEffects()
end

function primal_rock_prison_breaker_modifier:OnIntervalThink()
    if not IsServer() then return end

end

function primal_rock_prison_breaker_modifier:OnDestroy()
	if not IsServer() then return end

end


function primal_rock_prison_breaker_modifier:PlayEffects()
	
end