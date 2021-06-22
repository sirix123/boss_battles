casting_modifier_thinker_windrunner_focusfire = class({})

-----------------------------------------------------------------------------

function casting_modifier_thinker_windrunner_focusfire:IsHidden()
    return true
end

function casting_modifier_thinker_windrunner_focusfire:RemoveOnDeath()
    return false
end
----------------------------------------------------------------------------

function casting_modifier_thinker_windrunner_focusfire:DeclareFunctions() 
    return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end

function casting_modifier_thinker_windrunner_focusfire:GetActivityTranslationModifiers()
    return "attacking_run"
end

function casting_modifier_thinker_windrunner_focusfire:OnCreated( kv )
	if IsServer() then

    end
end



function casting_modifier_thinker_windrunner_focusfire:OnRefresh( kv )
	if IsServer() then

    end
end


function casting_modifier_thinker_windrunner_focusfire:OnDestroy()
    if not IsServer() then return nil end

end

