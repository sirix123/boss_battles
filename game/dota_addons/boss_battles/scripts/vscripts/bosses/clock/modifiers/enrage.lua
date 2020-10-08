
enrage = class({})

-----------------------------------------------------------------------------

function enrage:IsHidden()
	return false
end

function enrage:IsDebuff()
	return false
end

function enrage:IsPurgable()
	return false
end

-----------------------------------------------------------------------------

function enrage:OnCreated(  )
    if IsServer() then

        print("enrage buff damage")
        -- armor buff
		self.bonus_damage = 300

		local particle_cast = "particles/clock/clock_enigma_ambient_body.vpcf"
        self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetParent():GetAbsOrigin())
        --ParticleManager:ReleaseParticleIndex(self.effect_cast)

    end
end

function enrage:OnDestroy()
    if IsServer() then
		self.bonus_damage = 0
		ParticleManager:DestroyParticle(self.effect_cast, true)
    end
end

-----------------------------------------------------------------------------

function enrage:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
	}
	return funcs
end

-----------------------------------------------------------------------------

function enrage:GetModifierBaseAttack_BonusDamage( params )
	return self.bonus_damage
end

--------------------------------------------------------------------------------