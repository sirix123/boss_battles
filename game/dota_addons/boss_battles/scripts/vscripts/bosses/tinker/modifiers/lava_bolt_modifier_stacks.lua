lava_bolt_modifier_stacks = class({})

function lava_bolt_modifier_stacks:IsHidden()
	return false
end

function lava_bolt_modifier_stacks:IsDebuff()
	return false
end

function lava_bolt_modifier_stacks:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function lava_bolt_modifier_stacks:OnCreated( kv )
    if IsServer() then
        self:IncrementStackCount()
        --print("getstaks ",self:GetStackCount())
	end
end

function lava_bolt_modifier_stacks:OnRefresh( kv )
    if IsServer() then
        self:OnCreated()
	end
end

---------------------------------------------------------------------------

function lava_bolt_modifier_stacks:OnDestroy( kv )
    if IsServer() then
	end
end
-----------------------------------------------------------------------------
