movement_modifier_thinker = class({})

--------------------------------------------------------------------------------
function movement_modifier_thinker:IsHidden()
	return false
end

function movement_modifier_thinker:IsDebuff()
	return false
end

function movement_modifier_thinker:IsStunDebuff()
	return false
end

function movement_modifier_thinker:IsPurgable()
	return false
end

function movement_modifier_thinker:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------

-- need oncreated
-- need on think
-- need movement function 

function movement_modifier_thinker:OnCreated(table)
    self.interval = FrameTime()
    self.parent = self:GetParent()

    if IsServer() then
        self:StartIntervalThink(self.interval)
    end
end
--------------------------------------------------------------------------------

function movement_modifier_thinker:OnIntervalThink()
    self:Move()
end
--------------------------------------------------------------------------------

function movement_modifier_thinker:Move()
    local speed = self.parent:GetIdealSpeed() / 76.5
    local origin = self.parent:GetAbsOrigin()
    local direction = nil

    direction = Vector( self.parent.direction.x, self.parent.direction.y, self.parent:GetForwardVector().z )

    if self.parent:IsWalking() == true then
        self.parent:SetForwardVector(direction)
        local future_position = origin + direction * speed
        self.parent:SetAbsOrigin(future_position)
    end
end

--------------------------------------------------------------------------------
