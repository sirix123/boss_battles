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

        if self:GetParent():GetUnitName() == "npc_dota_hero_juggernaut" then
            self.status_effect = "particles/status_fx/status_effect_omnislash.vpcf"
        else
            self.status_effect = ""
        end

    end
end

function modifier_arcana_cosmetics:GetStatusEffectName() return self.status_effect end
function modifier_arcana_cosmetics:StatusEffectPriority() return 1000 end



function modifier_arcana_cosmetics:OnRefresh( kv )
	if IsServer() then

    end
end


function modifier_arcana_cosmetics:OnDestroy()
    if not IsServer() then return nil end

end

