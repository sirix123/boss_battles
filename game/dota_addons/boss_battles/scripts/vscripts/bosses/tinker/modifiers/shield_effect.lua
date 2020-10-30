shield_effect = class({})

function shield_effect:IsHidden()
	return false
end

function shield_effect:IsDebuff()
	return false
end

function shield_effect:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function shield_effect:OnCreated( kv )
    if IsServer() then

        local particle = "particles/tinker/tinker_medusa_daughters_mana_shield.vpcf"
        self.effect_cast = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetParent():GetAbsOrigin())


	end
end
---------------------------------------------------------------------------

function shield_effect:OnDestroy( kv )
    if IsServer() then
        ParticleManager:DestroyParticle(self.effect_cast,false)
	end
end
-----------------------------------------------------------------------------
