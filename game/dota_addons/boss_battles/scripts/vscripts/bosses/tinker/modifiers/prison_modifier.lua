prison_modifier = class({})

function prison_modifier:IsHidden()
	return false
end

function prison_modifier:IsDebuff()
	return true
end

function prison_modifier:OnCreated( kv )
    if IsServer() then
        local particle = "particles/tinker/tinker_obsidian_destroyer_prison.vpcf"
        self.effect_cast = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN, self:GetParent() )
        ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetAbsOrigin() )

        --self:IncrementStackCount()
        --print("self:GetStackCount() ",self:GetStackCount())
    end
end

function prison_modifier:OnRefresh(table)
    --if IsServer() then
        --self:IncrementStackCount()
        --print("self:GetStackCount() ",self:GetStackCount())
    --end
end

function prison_modifier:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle(self.effect_cast, false)
        --self:IncrementStackCount()
        --print("self:GetStackCount() ",self:GetStackCount())
    end
end

--------------------------------------------------------------------------------

function prison_modifier:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end
function prison_modifier:GetOverrideAnimationRate()
	return 0.3
end

