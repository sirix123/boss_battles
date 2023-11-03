shatter_modifier = class({})


-----------------------------------------------------------------------------
-- Classifications
function shatter_modifier:IsHidden()
	return false
end

function shatter_modifier:IsDebuff()
	return false
end

function shatter_modifier:IsStunDebuff()
	return false
end

function shatter_modifier:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

-- debuff effect on npc
-- these probably need to be like... stack count above the hero and... 'mob starts getting incased in ice?'
function shatter_modifier:GetEffectName()
	return
end

function shatter_modifier:GetStatusEffectName()
	return
end
-----------------------------------------------------------------------------

function shatter_modifier:OnCreated( kv )
	if IsServer() then
        self.max_shatter_stacks = kv.max_shatter_stacks
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        self.particleName = "particles/icemage/icemage_icelance_phoenix_fire_spirits.vpcf"
        self.pfx = ParticleManager:CreateParticle( self.particleName, PATTACH_ABSORIGIN_FOLLOW, self.caster )

        self:SetStackCount(1)

        ParticleManager:SetParticleControl( self.pfx, 1, Vector( self.max_shatter_stacks, 0, 0 ) )
    end
end
----------------------------------------------------------------------------
--maybe get the stacks on refresh as well? is created might be the same thing?
function shatter_modifier:OnRefresh( kv )
	if IsServer() then
        if self:GetStackCount() < self.max_shatter_stacks then
            self:IncrementStackCount()

            ParticleManager:SetParticleControl( self.pfx, 1, Vector( self:GetStackCount(), 0, 0 ) )
            for i=1, self:GetStackCount() do
                ParticleManager:SetParticleControl( self.pfx, 8+i, Vector( 1, 0, 0 ) )
            end
        end
    end
end

function shatter_modifier:OnStackCountChanged( prevStackCount )
	if IsServer() then
        ParticleManager:SetParticleControl( self.pfx, 1, Vector( prevStackCount, 0, 0 ) )
        for i=1, self.max_shatter_stacks, 1 do
            local radius = 0

            if i <= prevStackCount then
                radius = 1
            end

            ParticleManager:SetParticleControl( self.pfx, 8+i, Vector( radius, 0, 0 ) )
        end
    end
end
----------------------------------------------------------------------------

function shatter_modifier:OnDestroy()
    if IsServer() then

        if self.pfx then
            ParticleManager:DestroyParticle( self.pfx, false )
            ParticleManager:ReleaseParticleIndex( self.pfx )
        end
        
    end
end
----------------------------------------------------------------------------