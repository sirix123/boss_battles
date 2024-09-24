modifier_cleaing_bot_shield = class({})

function modifier_cleaing_bot_shield:Precache( context )
    PrecacheResource( "particle", "particles/tinker/tinker_medusa_daughters_mana_shield.vpcf", context )
end

function modifier_cleaing_bot_shield:IsHidden()
	return false
end

function modifier_cleaing_bot_shield:IsDebuff()
	return false
end

function modifier_cleaing_bot_shield:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function modifier_cleaing_bot_shield:OnCreated( kv )
    if IsServer() then

        local particle = "particles/tinker/tinker_medusa_daughters_mana_shield.vpcf"
        self.effect_cast = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetParent():GetAbsOrigin())


	end
end
---------------------------------------------------------------------------

function modifier_cleaing_bot_shield:OnDestroy( kv )
    if IsServer() then
        ParticleManager:DestroyParticle(self.effect_cast,false)
	end
end
-----------------------------------------------------------------------------
