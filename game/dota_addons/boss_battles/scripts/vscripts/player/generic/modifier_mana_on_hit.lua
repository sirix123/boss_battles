modifier_mana_on_hit = class ({})

--- Misc 
function modifier_mana_on_hit:IsHidden()
    return true
end

function modifier_mana_on_hit:DestroyOnExpire()
    return false
end

function modifier_mana_on_hit:IsPurgable()
    return false
end

function modifier_mana_on_hit:RemoveOnDeath()
    return false
end

function modifier_mana_on_hit:GetTexture()
    return "omniknight_guardian_angel"
end

function modifier_mana_on_hit:GetPriority()
    return 100
end


function modifier_mana_on_hit:OnCreated( kv )
    if IsServer() then
        self.mana_on_hit = 5
    end
end

function modifier_mana_on_hit:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function modifier_mana_on_hit:OnAttackLanded( params )
	if IsServer() then
		if params.attacker == self:GetParent() and ( not self:GetParent():IsIllusion() ) then
			if self:GetParent():PassivesDisabled() then
				return 0
			end

			local target = params.target
			if target ~= nil and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
                self:GetParent():ManaOnHit(self.mana_on_hit)
			end
		end
	end
	
	return 0
end
