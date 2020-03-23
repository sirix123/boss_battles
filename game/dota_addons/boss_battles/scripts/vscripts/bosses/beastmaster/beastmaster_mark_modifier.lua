
beastmaster_mark_modifier = class({})

-----------------------------------------------------------------------------

function beastmaster_mark_modifier:IsHidden()
	return false
end

-----------------------------------------------------------------------------

function beastmaster_mark_modifier:OnCreated( kv )
	if IsServer() then
		local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile_target_b.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() + Vector( 0, 0, -100 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
    end
end

-----------------------------------------------------------------------------


