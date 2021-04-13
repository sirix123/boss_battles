biting_frost_modifier_buff_fire = class({})

function biting_frost_modifier_buff_fire:IsHidden()
	return false
end

function biting_frost_modifier_buff_fire:IsDebuff()
	return false
end

function biting_frost_modifier_buff_fire:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function biting_frost_modifier_buff_fire:OnCreated( kv )
    if IsServer() then
		self.effect = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_break.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControl( self.effect, 0, self:GetParent():GetAbsOrigin() )

	end
end
---------------------------------------------------------------------------

function biting_frost_modifier_buff_fire:OnDestroy( kv )
    if IsServer() then
		ParticleManager:DestroyParticle(self.effect,true)
	end
end
---------------------------------------------------------------------------

function biting_frost_modifier_buff_fire:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

-----------------------------------------------------------------------------

function biting_frost_modifier_buff_fire:GetModifierPhysicalArmorBonus( params )
	return -5
end

--------------------------------------------------------------------------------

