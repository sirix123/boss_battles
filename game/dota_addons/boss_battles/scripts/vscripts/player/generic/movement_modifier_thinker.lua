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
    local future_position = nil
    --local direction = nil

    local origin = self.parent:GetAbsOrigin()

    local speed = self.parent:GetIdealSpeed() / 30
    local abilityBeingCast = self.parent:GetCurrentActiveAbility()
    local point = self.parent:GetCursorPosition()

    --direction = Vector( self.parent.direction.x, self.parent.direction.y, self.parent:GetForwardVector().z )

    local mouse = GameMode.mouse_positions[self.parent:GetPlayerID()]
    local direction = (mouse - self.parent:GetOrigin()):Normalized()
    self.parent:SetForwardVector(Vector(direction.x, direction.y, self.parent:GetForwardVector().z ))

    if self.parent:IsWalking() == true then

        -- needed to not give speed boost on diagonal
        if self.parent.direction.x ~= 0 and self.parent.direction.y ~= 0 then
            speed = speed * 0.75
        end

        --[[ not casting
        if abilityBeingCast == nil then

            self.parent:SetForwardVector(direction)

            future_position = origin + direction * speed
            self.parent:SetAbsOrigin(future_position)

        -- casting
        elseif abilityBeingCast ~= nil then
            local directionToCastLocation = (origin - point):Normalized()

            self.parent:SetForwardVector(directionToCastLocation)

            future_position = origin + direction * speed
            self.parent:SetAbsOrigin(future_position)
        end]]
    end
end

--------------------------------------------------------------------------------
