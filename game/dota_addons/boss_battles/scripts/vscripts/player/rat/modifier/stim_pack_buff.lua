stim_pack_buff = class({})

-----------------------------------------------------------------------------
-- Classifications
function stim_pack_buff:IsHidden()
	return false
end

function stim_pack_buff:IsDebuff()
	return false
end

function stim_pack_buff:GetEffectName()
	return "particles/units/heroes/hero_hoodwink/hoodwink_scurry_aura.vpcf"
end


-----------------------------------------------------------------------------

function stim_pack_buff:OnCreated( kv )
	if not IsServer() then return end
end

function stim_pack_buff:OnRefresh( kv )
	if not IsServer() then return end

end

function stim_pack_buff:OnRemoved()
    if not IsServer() then return end

end

function stim_pack_buff:OnDestroy()
	if not IsServer() then return end

    -- give rat crash
    self:GetParent():AddNewModifier(
        self:GetParent(), -- player source
        self:GetAbility(), -- ability source
        "stim_pack_debuff", -- modifier name
        { duration = self:GetAbility():GetSpecialValueFor( "duration_debuff") } -- kv
    )

end
----------------------------------------------------------------------------

