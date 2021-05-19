
beastmaster_bloodlust_modifier = class({})

-----------------------------------------------------------------------------

function beastmaster_bloodlust_modifier:IsHidden()
	return false
end

-----------------------------------------------------------------------------

--[[function beastmaster_bloodlust_modifier:GetHeroEffectName()
	return "particles/beastmaster/ursa_enrage_buff_beastmaster.vpcf"
end]]
-----------------------------------------------------------------------------

function beastmaster_bloodlust_modifier:OnCreated( kv )
	if IsServer() then
		self.bloodlust_speed = 80
		self.bloodlust_as_speed = 25
		self.dmg_bonus = 160
		self.bat = 1.0

		-- takes more dmg?

		--self.effect = ParticleManager:CreateParticle( "particles/beastmaster/beastmaster_enrage.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
		--ParticleManager:SetParticleControl( self.effect, 0, self:GetParent():GetAbsOrigin() )
		--ParticleManager:SetParticleControl( self.effect, 3, self:GetParent():GetAbsOrigin() )
	end
end

function beastmaster_bloodlust_modifier:OnDestroy()
    if IsServer() then
        --ParticleManager:DestroyParticle(self.effect, true)
    end
end
-----------------------------------------------------------------------------

function beastmaster_bloodlust_modifier:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
	return funcs
end

-----------------------------------------------------------------------------

function beastmaster_bloodlust_modifier:GetModifierModelScale()
	return 50
end
-----------------------------------------------------------------------------

function beastmaster_bloodlust_modifier:GetModifierBaseDamageOutgoing_Percentage( params )
	return self.dmg_bonus
end
--------------------------------------------------------------------------------

function beastmaster_bloodlust_modifier:GetModifierMoveSpeedBonus_Percentage( params )
	return self.bloodlust_speed
end
--------------------------------------------------------------------------------

function beastmaster_bloodlust_modifier:GetModifierAttackSpeedBonus_Constant( params )
	return self.bloodlust_as_speed
end
--------------------------------------------------------------------------------

function beastmaster_bloodlust_modifier:GetModifierBaseAttackTimeConstant()
	return self.bat
end


