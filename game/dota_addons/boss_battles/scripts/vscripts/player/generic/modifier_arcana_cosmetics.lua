modifier_arcana_cosmetics = class({})

-----------------------------------------------------------------------------

function modifier_arcana_cosmetics:IsHidden()
    return true
end

function modifier_arcana_cosmetics:RemoveOnDeath()
    return false
end
----------------------------------------------------------------------------

function modifier_arcana_cosmetics:DeclareFunctions() 
    return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end

function modifier_arcana_cosmetics:GetActivityTranslationModifiers()
    return "arcana"
end

function modifier_arcana_cosmetics:OnCreated( kv )
	if IsServer() then

    end
end



function modifier_arcana_cosmetics:OnRefresh( kv )
	if IsServer() then

    end
end


function modifier_arcana_cosmetics:OnDestroy()
    if not IsServer() then return nil end

end

