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
    self.frame = 0.00

    if IsServer() then
        self.previous_speed = self:GetParent():GetIdealSpeed() / 30
        self:StartIntervalThink(self.interval)
    end
end
--------------------------------------------------------------------------------

function movement_modifier_thinker:OnIntervalThink()
    self:Move()
end
--------------------------------------------------------------------------------

function movement_modifier_thinker:Move()
    local current_animation_modifier = self.parent:FindModifierByName("modifier_animation")
    local current_animation = "not_walking"

    if current_animation_modifier ~= nil then
		if current_animation_modifier.keys.base ~= nil then
			if current_animation_modifier.keys.base == 1 then
				current_animation = "walking"
			end
		end
    end

    local future_position = nil
    local origin = self.parent:GetAbsOrigin()
    local speed = self.parent:GetIdealSpeed() / 30
    --local abilityBeingCast = self.parent:GetCurrentActiveAbility()

    local mouse = GameMode.mouse_positions[self.parent:GetPlayerID()]
    local direction = (mouse - self.parent:GetOrigin()):Normalized()
    self.parent:SetForwardVector(Vector(direction.x, direction.y, self.parent:GetForwardVector().z ))

    -- moving
    if self.parent:IsWalking() == true then

        -- needed to not give speed boost on diagonal
        if self.parent.direction.x ~= 0 and self.parent.direction.y ~= 0 then
            speed = speed * 0.75
        end

        future_position = origin + Vector( self.parent.direction.x, self.parent.direction.y, self.parent:GetForwardVector().z ) * speed
        self.parent:SetAbsOrigin(future_position)

        -- If not animating
        if current_animation_modifier == nil then
			self.frame = self.frame + 0.01
			if self.frame >= 0.1 then
				self:Animate( speed, self.parent )
			end
		elseif current_animation_modifier == "walking" then
			-- Check for running annimation
			if self.previous_speed ~= speed then
				self:Animate( speed, self.parent )
				self.previous_speed = speed
			end
        end

    -- not moving
    else
        GameRules.EndAnimation(self.parent)
        self.frame = 0.00
    end
end
--------------------------------------------------------------------------------

function movement_modifier_thinker:Animate( speed, hUnit )
	--[[if speed > 5 then 
		StartAnimation(hUnit, {
			duration=100,
			translate="haste",
			activity=ACT_DOTA_RUN, 
			rate=1.3, 
			base=1
		})
	else]]
		StartAnimation(hUnit, {
			duration=100, 
			activity=ACT_DOTA_RUN,
			rate=1.0,
			base=1
		})
	--end
end
