
purple_crystal_modifier = class({})
-----------------------------------------------------------------------------

function purple_crystal_modifier:IsHidden()
	return false
end
-----------------------------------------------------------------------------

function purple_crystal_modifier:GetEffectName()
	return "particles/status_fx/status_effect_enigma_blackhole_tgt.vpcf"
end

function purple_crystal_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function purple_crystal_modifier:OnCreated(  )
    if IsServer() then
        self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/gyrocopter/biger_earthshaker_arcana_stunned.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, Vector(self:GetParent():GetAbsOrigin().x, self:GetParent():GetAbsOrigin().y, 200 ))
    end
end

function purple_crystal_modifier:OnRefresh(  )
    if IsServer() then
    end
end


function purple_crystal_modifier:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle( self.nPreviewFXIndex,true )
    end
end

-----------------------------------------------------------------------------