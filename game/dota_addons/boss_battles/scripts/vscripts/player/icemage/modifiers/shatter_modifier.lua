
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

        self:SetStackCount(1)
    end
end
----------------------------------------------------------------------------
--maybe get the stacks on refresh as well? is created might be the same thing?
function shatter_modifier:OnRefresh( kv )
	if IsServer() then
        if self:GetStackCount() < self.max_shatter_stacks then
            self:IncrementStackCount()
        end
    end
end
----------------------------------------------------------------------------

function shatter_modifier:OnDestroy()
    if IsServer() then
        
    end
end
----------------------------------------------------------------------------