movement_modifier_thinker = class({})

local DEBUG = true

local RADIUS_BIG = 40
local RADIUS_MINI = 10

local COLLIDE_OFFSET = 7
local COLLIDE_OFFSET_MINI = 1.0

local COLLIDE_SLOW_FACTOR = 1.5
local COLLIDE_SUPER_SLOW_FACTOR = 5.0

local MAX_Z_DIFF = 80
local MIN_Z_DIFF = 0

local RED = Vector(255, 0, 0)
local GREEN = Vector(0, 255, 0)
local BLUE = Vector(0, 0, 255)
local YELLOW = Vector(255, 255, 0)
local PURPLE = Vector(255, 0, 255)
local SKYBLUE = Vector(0, 255, 255)

local EAST = Vector(1, 0, 0)
local WEST = Vector(-1, 0, 0)
local NORTH = Vector(0, 1, 0)
local SOUTH = Vector(0, -1, 0)

local NORTH_EAST = Vector(1, 1, 0)
local NORTH_WEST = Vector(-1, 1, 0)
local SOUTH_EAST = Vector(1, -1, 0)
local SOUTH_WEST = Vector(-1, -1, 0)

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
    --print(current_animation)

    if current_animation_modifier ~= nil then
        if current_animation_modifier.keys.base ~= nil then
            print("do we get in here?")
            if current_animation_modifier.keys.base == 1 then
                current_animation = "walking"
                print(current_animation)
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
        future_position.z = GetGroundPosition(future_position, self.parent).z
        --self.parent:SetAbsOrigin(future_position)

        -- test future position for colliding
        local test_position_front = origin + direction * speed * COLLIDE_OFFSET
        local colliding = self:GetColliding(test_position_front, origin.z, GREEN)

        if --math.abs(GetGroundPosition(test_position_front, self.parent).z - origin.z) < MAX_Z_DIFF and
            not colliding[EAST] and
            not colliding[WEST] and
            not colliding[NORTH] and
            not colliding[SOUTH]
        then
            self.parent:SetAbsOrigin(future_position)
        else
            if direction == NORTH_EAST then
                self:SubMove(colliding, origin, speed, NORTH, EAST, COLLIDE_SLOW_FACTOR)
            elseif direction == NORTH_WEST then
                self:SubMove(colliding, origin, speed, NORTH, WEST, COLLIDE_SLOW_FACTOR)
            elseif direction == SOUTH_EAST then
                self:SubMove(colliding, origin, speed, SOUTH, EAST, COLLIDE_SLOW_FACTOR)
            elseif direction == SOUTH_WEST then
                self:SubMove(colliding, origin, speed, SOUTH, WEST, COLLIDE_SLOW_FACTOR)


            elseif direction == EAST then
                self:SubMove(colliding, origin, speed, SOUTH, NORTH, COLLIDE_SUPER_SLOW_FACTOR)
            elseif direction == WEST then
                self:SubMove(colliding, origin, speed, SOUTH, NORTH, COLLIDE_SUPER_SLOW_FACTOR)
            elseif direction == NORTH then
                self:SubMove(colliding, origin, speed, EAST, WEST, COLLIDE_SUPER_SLOW_FACTOR)
            elseif direction == SOUTH then
                self:SubMove(colliding, origin, speed, EAST, WEST, COLLIDE_SUPER_SLOW_FACTOR)
            end
        end

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
        if current_animation == "walking" then
            print("trying to stop walking animiation")
            print(current_animation)
            GameRules.EndAnimation(self.parent)
            self.frame = 0.00
        end
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
--------------------------------------------------------------------------------

function movement_modifier_thinker:GetColliding(test_position_front, actual_z, color)
	local test_position_east = test_position_front + RADIUS_BIG * EAST * COLLIDE_OFFSET_MINI
	local test_position_west = test_position_front + RADIUS_BIG * WEST * COLLIDE_OFFSET_MINI
	local test_position_north = test_position_front + RADIUS_BIG * NORTH * COLLIDE_OFFSET_MINI
	local test_position_south = test_position_front + RADIUS_BIG * SOUTH * COLLIDE_OFFSET_MINI

	local test_z = GetGroundPosition(test_position_front, self.parent).z
	local test_z_east = GetGroundPosition(test_position_east, self.parent).z
	local test_z_west = GetGroundPosition(test_position_west, self.parent).z
	local test_z_north = GetGroundPosition(test_position_north, self.parent).z
	local test_z_south = GetGroundPosition(test_position_south, self.parent).z

	if DEBUG then 
		test_position_east.z = test_z_east 
		test_position_west.z = test_z_west
		test_position_north.z = test_z_north
		test_position_south.z = test_z_south


		--DebugDrawCircle(future_position, RED, 5, RADIUS_BIG, false, 0.01)
		DebugDrawCircle(test_position_front, color, 5, RADIUS_BIG, false, 0.01)
		DebugDrawCircle(test_position_east, BLUE, 5, RADIUS_MINI, false, 0.01)
		DebugDrawCircle(test_position_west, YELLOW, 5, RADIUS_MINI, false, 0.01)
		DebugDrawCircle(test_position_north, SKYBLUE, 5, RADIUS_MINI, false, 0.01)
		DebugDrawCircle(test_position_south, PURPLE, 5, RADIUS_MINI, false, 0.01)
	end

	local colliding = {}
	local differences = {
		east = math.abs(test_z_east - actual_z),
		west = math.abs(test_z_west - actual_z),
		north = math.abs(test_z_north - actual_z),
		south = math.abs(test_z_south - actual_z),
	}

	colliding[EAST] = differences.east > MAX_Z_DIFF or self:GetCollidingWithObjects(test_position_east) == true or differences.east < MIN_Z_DIFF
	colliding[WEST] = differences.west > MAX_Z_DIFF or self:GetCollidingWithObjects(test_position_west) == true or differences.west < MIN_Z_DIFF
	colliding[NORTH] = differences.north > MAX_Z_DIFF or self:GetCollidingWithObjects(test_position_north) == true or differences.north < MIN_Z_DIFF
	colliding[SOUTH] = differences.south > MAX_Z_DIFF or self:GetCollidingWithObjects(test_position_south) == true or differences.south < MIN_Z_DIFF

	return colliding
end

function movement_modifier_thinker:GetCollidingWithObjects(test_position)
	if self.parent:IsPhased() then
		return false
	end

	local units = FindUnitsInRadius( 
		self.parent:GetTeamNumber(), -- int, your team number
		test_position, -- point, center point
		nil, -- handle, cacheUnit. (not known)
		RADIUS_MINI, -- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_BOTH, -- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0, -- int, flag filter
		0, -- int, order filter
		false -- bool, can grow cache
	)

	for _,unit in pairs(units) do
		if unit ~= self.parent then
			if not unit:IsPhased() then
				return true
			end
		end
	end

	return false
end

function movement_modifier_thinker:SubMove(colliding, origin, speed, direction_a, direction_b, slow)
	if colliding[direction_a] then
		local sub_future_position = origin + direction_b * speed / slow
		local sub_test_position_front = origin + direction_b * speed * COLLIDE_OFFSET
		local sub_colliding = self:GetColliding(sub_test_position_front, origin.z, RED)
		
		if not sub_colliding[direction_b] then
			self.parent:SetAbsOrigin(sub_future_position)
		end
	else
		local sub_future_position = origin + direction_a * speed / slow
		local sub_test_position_front = origin + direction_a * speed * COLLIDE_OFFSET
		local sub_colliding = self:GetColliding(sub_test_position_front, origin.z, RED)
		
		if not sub_colliding[direction_a] then
			self.parent:SetAbsOrigin(sub_future_position)
		end
	end
end