movement_modifier_thinker = class({})
LinkLuaModifier("modifier_hero_movement", "player/generic/modifier_hero_movement", LUA_MODIFIER_MOTION_NONE)

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

function movement_modifier_thinker:OnCreated()
	if IsServer() then
		self.interval = FrameTime()
		self.parent = self:GetParent()

        self:StartIntervalThink(self.interval)
    end
end
--------------------------------------------------------------------------------

function movement_modifier_thinker:OnIntervalThink()
    self:Move()
end
--------------------------------------------------------------------------------

function movement_modifier_thinker:Move()
    -- animation init
	if self.parent:IsAnimating() then
		self.parent:RemoveModifierByName("modifier_hero_movement")
	end

    -- variable init
    local future_position = nil
    local origin = self.parent:GetAbsOrigin()
    local speed = self.parent:GetIdealSpeed() / 30

    -- get parent vector and store in an array
    local direction = nil
    direction = Vector(
        self.parent.direction.x,
        self.parent.direction.y,
        self.parent:GetForwardVector().z
    )

    -- init mouse locations
    local mouse = GameMode.mouse_positions[self.parent:GetPlayerID()]
	local mouseDirection = (mouse - self.parent:GetOrigin()):Normalized()

	-- set forward vector as the mouse location also handle spell casting...
	-- current problem if moving and casting the casting animations cancels if standing still works good
	--local abilityBeingCast = self.parent:GetCurrentActiveAbility()
	self.parent:SetForwardVector(Vector(mouseDirection.x, mouseDirection.y, self.parent:GetForwardVector().z ))
	self.parent:FaceTowards(self.parent:GetAbsOrigin() + Vector(mouseDirection.x, mouseDirection.y, self.parent:GetForwardVector().z ))

    -- moving
	if self.parent:IsWalking() == true then
		local offset = 7

        -- needed to not give speed boost on diagonal
        if self.parent.direction.x ~= 0 and self.parent.direction.y ~= 0 then
            speed = speed * 0.75
        end

        future_position = origin + direction * speed
		future_position.z = GetGroundPosition(future_position, self.parent).z

		-- new colliding code (checks for colliding on a wall - units - objects)
		local test_position_front = origin + direction * speed * offset
		test_position_front.z = GetGroundPosition(future_position, self.parent).z

		if GridNav:IsTraversable(test_position_front) then
			if not self.parent:IsPhased() then
				local units = FindUnitsInRadius( 
					self.parent:GetTeamNumber(), -- int, your team number
					test_position_front, -- point, center point
					nil, -- handle, cacheUnit. (not known)
					5, -- float, radius. or use FIND_UNITS_EVERYWHERE
					DOTA_UNIT_TARGET_TEAM_BOTH, -- int, team filter
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
					DOTA_UNIT_TARGET_FLAG_NONE, -- int, flag filter
					FIND_ANY_ORDER, -- int, order filter
					false -- bool, can grow cache
				)

				local trees = GridNav:GetAllTreesAroundPoint( test_position_front, 1, true )
				print(#trees)
				if #trees > 0 then
					print("tree here")
					return false
				end

				for _,unit in pairs(units) do
					if unit ~= self.parent then
						if not unit:IsPhased() then
							return false
						end
					end
				end

				if not self.parent:IsAnimating() then
					if not self.parent:HasModifier("modifier_hero_movement") then
						self.parent:AddNewModifier(self.parent, nil, "modifier_hero_movement", {})
					end
				end

				self.parent:SetAbsOrigin(future_position)

				return true
			else
				return false
			end
		end

    -- not moving
    else
		self.parent:RemoveModifierByName("modifier_hero_movement")
    end
end
--------------------------------------------------------------------------------

function movement_modifier_thinker:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
	}

	return funcs
end

function movement_modifier_thinker:GetModifierIgnoreMovespeedLimit( params )
    return 1
end

