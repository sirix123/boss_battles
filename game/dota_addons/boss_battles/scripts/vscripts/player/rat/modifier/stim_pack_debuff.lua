stim_pack_debuff = class({})

-----------------------------------------------------------------------------
-- Classifications
function stim_pack_debuff:IsHidden()
	return false
end

function stim_pack_debuff:IsDebuff()
	return true
end

-----------------------------------------------------------------------------

function stim_pack_debuff:OnCreated( kv )

	self.ms_slow = -self:GetAbility():GetSpecialValueFor( "ms_slow")

	if not IsServer() then return end

	local sound_cast = "Hero_Hoodwink.Scurry.End"
	EmitSoundOn( sound_cast, self:GetCaster() )

    -- give ms slow
    self.ms_slow = -self:GetAbility():GetSpecialValueFor( "ms_slow")

end

function stim_pack_debuff:OnRefresh( kv )
	if not IsServer() then return end

end

function stim_pack_debuff:OnRemoved()
    if not IsServer() then return end

end

function stim_pack_debuff:OnDestroy()
	if not IsServer() then return end

end
----------------------------------------------------------------------------

function stim_pack_debuff:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
-----------------------------------------------------------------------------

function stim_pack_debuff:GetModifierMoveSpeedBonus_Percentage( params )
	return self.ms_slow
end
--------------------------------------------------------------------------------
