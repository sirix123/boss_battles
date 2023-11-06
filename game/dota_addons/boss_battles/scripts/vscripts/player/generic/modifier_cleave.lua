modifier_cleave = class ({})

--- Misc 
function modifier_cleave:IsHidden()
    return true
end

function modifier_cleave:DestroyOnExpire()
    return false
end

function modifier_cleave:IsPurgable()
    return false
end

function modifier_cleave:RemoveOnDeath()
    return false
end

function modifier_cleave:GetTexture()
    return "omniknight_guardian_angel"
end

function modifier_cleave:GetPriority()
    return 100
end


function modifier_cleave:OnCreated( kv )
    if IsServer() then
        self.cleave_damage = self:GetCaster():GetAttackDamage()
        self.cleave_radius = 300
    end
end

function modifier_cleave:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function modifier_cleave:OnAttackLanded( params )
	if IsServer() then
		if params.attacker == self:GetParent() and ( not self:GetParent():IsIllusion() ) then
			if self:GetParent():PassivesDisabled() then
				return 0
			end

			local target = params.target
			if target ~= nil and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
                DoCleaveAttack(self:GetParent(), target, nil, self.cleave_damage, 150, self.cleave_radius, 500, "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf")
			end
		end
	end
	
	return 0
end
