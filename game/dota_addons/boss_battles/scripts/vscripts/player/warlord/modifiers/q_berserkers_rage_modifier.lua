q_berserkers_rage_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function q_berserkers_rage_modifier:IsHidden()
	return false
end

function q_berserkers_rage_modifier:IsDebuff()
	return false
end

function q_berserkers_rage_modifier:IsPurgable()
	return false
end

function q_berserkers_rage_modifier:RemoveOnDeath()
	return true
end

function q_berserkers_rage_modifier:GetTexture()
	return "axe_berserkers_call"
end

--------------------------------------------------------------------------------
-- Initializations
function q_berserkers_rage_modifier:OnCreated( kv )
    --if IsServer() then 
        --print("ghello123")
        self.armor_reduce = self:GetAbility():GetSpecialValueFor( "armor_reduce" )
    --end
end

function q_berserkers_rage_modifier:OnRefresh( kv )

end

function q_berserkers_rage_modifier:OnDestroy( kv )

end

--------------------------------------------------------------------------------

function q_berserkers_rage_modifier:DeclareFunctions()
	local funcs = 
	{
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}	
	return funcs
end

-----------------------------------------------------------------------------

function q_berserkers_rage_modifier:GetModifierPhysicalArmorBonus ( params )
	return self.armor_reduce
end

--------------------------------------------------------------------------------

