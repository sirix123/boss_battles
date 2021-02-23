shield_cosmetic = class({})

--------------------------------------------------------------------------------
-- Classifications
function shield_cosmetic:IsHidden()
	return false
end

function shield_cosmetic:IsDebuff()
	return false
end

function shield_cosmetic:IsPurgable()
	return true
end
--------------------------------------------------------------------------------
-- Initializations
function shield_cosmetic:OnCreated( kv )

end

function shield_cosmetic:OnDestroy()

end

--------------------------------------------------------------------------------

function shield_cosmetic:GetEffectName()
    return "particles/econ/items/ember_spirit/ember_ti9/ember_ti9_flameguard.vpcf"
end

function shield_cosmetic:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end