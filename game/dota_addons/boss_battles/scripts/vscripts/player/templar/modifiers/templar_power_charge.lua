templar_power_charge = class({})

-----------------------------------------------------------------------------
-- Classifications
function templar_power_charge:IsHidden()
	return false
end

function templar_power_charge:IsDebuff()
	return false
end

-----------------------------------------------------------------------------

function templar_power_charge:OnCreated( kv )

    self.speed_bonus = self:GetCaster():FindAbilityByName("templar_passive"):GetSpecialValueFor( "power_charge_ms_bonus_percent" )

	if not IsServer() then return end

    self.speed_bonus = self:GetCaster():FindAbilityByName("templar_passive"):GetSpecialValueFor( "power_charge_ms_bonus_percent" )

    if self.pfx and self:GetStackCount() < 3 then
		ParticleManager:DestroyParticle(self.pfx, true)
	end

	if self:GetStackCount() < 3 then
		self:IncrementStackCount()

        local particleName = "particles/templar/templar_icelance_phoenix_fire_spirits.vpcf"
        self.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )

        ParticleManager:SetParticleControl( self.pfx, 1, Vector( self:GetStackCount(), 0, 0 ) )

        for i=1, self:GetStackCount() do
            ParticleManager:SetParticleControl( self.pfx, 8+i, Vector( 1, 0, 0 ) )
        end
	end
end

function templar_power_charge:OnRefresh( kv )
	if not IsServer() then return end
    self:OnCreated()
end

function templar_power_charge:OnRemoved()
    if not IsServer() then return end

	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, true)
	end

end

function templar_power_charge:OnDestroy()
	if not IsServer() then return end

end
----------------------------------------------------------------------------

function templar_power_charge:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function templar_power_charge:GetModifierMoveSpeedBonus_Percentage( params )
	if ( self.speed_bonus * self:GetStackCount() ) ~= nil then
		return self.speed_bonus * self:GetStackCount()
	end
end
