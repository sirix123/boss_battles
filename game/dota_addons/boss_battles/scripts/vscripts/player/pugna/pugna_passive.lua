pugna_passive = class({})

LinkLuaModifier("pugna_passive_modifier", "player/pugna/pugna_passive", LUA_MODIFIER_MOTION_NONE)

function pugna_passive:GetIntrinsicModifierName()
	return "pugna_passive_modifier"
end

pugna_passive_modifier = class({})

LinkLuaModifier("soul_crystals", "player/pugna/modifiers/soul_crystals", LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

function pugna_passive_modifier:IsHidden()
	return true
end

function pugna_passive_modifier:OnCreated( params )
    if IsServer() then
    end
end
