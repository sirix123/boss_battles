modifier_beastmaster_net = class({})

------------------------------------------------------------------

function modifier_beastmaster_net:IsHidden()
	return false
end

function modifier_beastmaster_net:IsDebuff()
	return true
end

---------------------------------------------------------------------

function modifier_beastmaster_net:OnCreated( kv )
	if IsServer() then
		-- create particle effect on target
		self.nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_meepo/meepo_earthbind.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.nFXIndex, 0, self:GetParent():GetOrigin() + Vector( 0, 0, 40 ) )

		print("duration ",self:GetRemainingTime())

	end
end

--------------------------------------------------------------------------------

function modifier_beastmaster_net:CheckState()
	local state = {}
	state[MODIFIER_STATE_ROOTED] = true

	return state
end

--------------------------------------------------------------------------------

function modifier_beastmaster_net:OnDestroy()
	if IsServer() then
		if self.nFXIndex then
			ParticleManager:DestroyParticle(self.nFXIndex, true)
			--ParticleManager:ReleaseParticleIndex( self.nFXIndex )
		end
	end
end

--------------------------------------------------------------------------------

--[[]
function modifier_beastmaster_net:GetEffectName()
	return "particles/econ/items/batrider/batrider_ti8_immortal_mount/batrider_ti8_immortal_firefly.vpcf"
end

-----------------------------------------------------------------------------

function modifier_beastmaster_net:GetStatusEffectName()
	return "particles/econ/items/batrider/batrider_ti8_immortal_mount/batrider_ti8_immortal_firefly.vpcf"
end
]]--