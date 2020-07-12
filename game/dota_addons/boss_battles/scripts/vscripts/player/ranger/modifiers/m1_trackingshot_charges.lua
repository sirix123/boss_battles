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
        self:SetStackCount(self.nMaxCharges)
        self.bReplenish = true

        -- start replenish thinker
        -- i think we only want this to start once the charges have started being used
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

        if self.nCharges == 0 and self.bReplenish == true then
            self.bReplenish = false

            Timers:CreateTimer(2, function()

                self.nCharges = self:GetStackCount()

                if self.nCharges == self.nMaxCharges then
                    self.bReplenish = true
                    return false
                end

                self:SetStackCount(self.nMaxCharges)

                return 0.01
              end
            )
        end

        if self.nCharges < self.nMaxCharges and self.nCharges ~= 0 then
            --self:IncrementStackCount()
        end

    end
end
----------------------------------------------------------------------------

function m1_trackingshot_charges:OnDestroy()
    if IsServer() then

    end
end
----------------------------------------------------------------------------