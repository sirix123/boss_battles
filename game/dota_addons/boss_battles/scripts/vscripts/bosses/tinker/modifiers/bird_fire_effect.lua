bird_fire_effect = class({})

function bird_fire_effect:IsHidden()
	return false
end

function bird_fire_effect:IsDebuff()
	return false
end

function bird_fire_effect:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function bird_fire_effect:OnCreated( kv )
    if IsServer() then

		-- gives proj speed in spell and changes the particle effect
	end
end
---------------------------------------------------------------------------

function bird_fire_effect:OnDestroy( kv )
    if IsServer() then

	end
end
---------------------------------------------------------------------------

function bird_fire_effect:GetEffectName()
    return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function bird_fire_effect:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end