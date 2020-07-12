m1_trackingshot_charges = class({})

-----------------------------------------------------------------------------
-- Classifications
function m1_trackingshot_charges:IsHidden()
	return false
end

function m1_trackingshot_charges:IsDebuff()
	return false
end

function m1_trackingshot_charges:IsStunDebuff()
	return false
end

function m1_trackingshot_charges:IsPurgable()
	return false
end
-----------------------------------------------------------------------------

function m1_trackingshot_charges:GetEffectName()
	return
end

function m1_trackingshot_charges:GetStatusEffectName()
	return
end
-----------------------------------------------------------------------------

function m1_trackingshot_charges:OnCreated( kv )
	if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        -- reference from kv
        self.nMaxCharges = 3

        -- start replenish thinker
        self:StartIntervalThink( 1 )

    end
end
----------------------------------------------------------------------------

function m1_trackingshot_charges:OnIntervalThink()
    if IsServer() then
        self.nCharges = self:GetStackCount()

        if self.nCharges == self.nMaxCharges then
            return
        end

        if self.nCharges < self.nMaxCharges then
            self:IncrementStackCount()
        end

    end
end
----------------------------------------------------------------------------

function m1_trackingshot_charges:OnDestroy()
    if IsServer() then

    end
end
----------------------------------------------------------------------------