movement_modifier_thinker = class({})
LinkLuaModifier("modifier_hero_movement", "player/generic/modifier_hero_movement", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
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
	return true
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
	-- variable init
	local speed = self.parent:GetIdealSpeed() / 30

	-- get parent vector and store in an array
	local direction = nil
	direction = Vector(
		self.parent.direction.x,
		self.parent.direction.y,
		self.parent:GetForwardVector().z
	)

	-- check for items on the ground
	if self.parent:IsAlive() then
		self:PickUpItems()
	end

	-- moving
	if self.parent:IsWalking() == true
		and self.parent:HasModifier("modifier_generic_arc_lua") == false
		and self.parent:HasModifier("furnace_master_grab_debuff") == false
		and self.parent:HasModifier("furnace_master_grabbed_buff") == false
		and self.parent:HasModifier("space_chain_hook_modifier") == false
		and self.parent:IsAlive() == true
		then

		-- needed to not give speed boost on diagonal
		if self.parent.direction.x ~= 0 and self.parent.direction.y ~= 0 then
			speed = speed * 0.75
		end

		if self:Move(direction, speed) == false then
			local alternative_directions = self:AlternatieDirections(direction)

			for _, alt_direction in pairs(alternative_directions) do
				if self:Move(alt_direction, speed/2) == true then
					break
				end
			end
		end

		-- set hero facing towards moving vector unless casting
		if self.parent:HasModifier("casting_modifier_thinker") == false then
			self.parent:SetForwardVector(Vector(direction.x, direction.y, self.parent:GetForwardVector().z ))
			self.parent:FaceTowards(self.parent:GetAbsOrigin() + Vector(direction.x, direction.y, self.parent:GetForwardVector().z ))
		end

	-- not moving
	else
		self.parent:RemoveModifierByName("modifier_hero_movement")
	end
end
--------------------------------------------------------------------------------

function movement_modifier_thinker:Move(direction, speed)
	-- variable init
	local origin = self.parent:GetAbsOrigin()
	local offset = 7

	-- next postion where the player will move to
	local future_position = origin + direction * speed
	future_position.z = GetGroundPosition(future_position, self.parent).z

	local test_position_front = future_position + direction * offset
	test_position_front.z = GetGroundPosition(future_position, self.parent).z

	if GridNav:IsTraversable(test_position_front) and self.parent:HasMovementCapability() then
		if not self.parent:IsPhased() then

			-- find untis in radius around future postion
			-- only look at enemy units?
			local units = FindUnitsInRadius( 
				self.parent:GetTeamNumber(), -- int, your team number
				test_position_front, -- point, center point
				nil, -- handle, cacheUnit. (not known)
				offset, -- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter DOTA_UNIT_TARGET_TEAM_BOTH
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
				DOTA_UNIT_TARGET_FLAG_INVULNERABLE, -- int, flag filter
				FIND_ANY_ORDER, -- int, order filter
				false -- bool, can grow cache
			)

			-- find trees around fuuture position if finds trees dont allow movement 
			local trees = GridNav:GetAllTreesAroundPoint( test_position_front, offset, true )
			if #trees > 0 then
				return false
			end

			-- find players around fuuture position if finds players and no-one is phased then dont allow movement
			for _,unit in pairs(units) do
				if unit ~= self.parent then
					if not unit:IsPhased() then
						return false
					end
				end
			end

			-- if not playing the moving animation start it
			if not self.parent:HasModifier("modifier_hero_movement") then
				self.parent:AddNewModifier(self.parent, nil, "modifier_hero_movement", {})

			-- if playing the moving animation and we are casting then remove the animation 
			-- (top and bottom animations are not seperate in dota, cant do both running and casting at the same time)
			--elseif self.parent:HasModifier("casting_modifier_thinker") == true
			--	and abilityBeingCast ~= nil
			--	and self.parent:HasModifier("modifier_hero_movement") == true then

			--	self.parent:RemoveModifierByName("modifier_hero_movement")
			end

			self.parent:SetAbsOrigin(future_position)

			return true
		else
			return false
		end
	else
		return false
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
--------------------------------------------------------------------------------

function movement_modifier_thinker:AlternatieDirections(vDirection)
	local directions = {}
	
	if vDirection == NORTH_EAST then
		table.insert(directions, NORTH)
		table.insert(directions, EAST)
	end 
	if vDirection == NORTH_WEST then
		table.insert(directions, NORTH)
		table.insert(directions, WEST)
	end 
	if vDirection == SOUTH_EAST then
		table.insert(directions, SOUTH)
		table.insert(directions, EAST)
	end 
	if vDirection == SOUTH_WEST then
		table.insert(directions, SOUTH)
		table.insert(directions, WEST)
 	end 
	if vDirection == EAST or vDirection == WEST then
		if self.parent:GetAbsOrigin().y < 0 then
			table.insert(directions, SOUTH)
		end

		if self.parent:GetAbsOrigin().y > 0 then
			table.insert(directions, NORTH)
		end
	end 
	if vDirection == NORTH or vDirection == SOUTH then
		if self.parent:GetAbsOrigin().x < 0 then
			table.insert(directions, WEST)
		end
		if self.parent:GetAbsOrigin().x > 0 then
			table.insert(directions, EAST)
		end
	end

	return directions
end
--------------------------------------------------------------------------------

function movement_modifier_thinker:PickUpItems()
	
	-- consstantly search for items around the player
	local objs = Entities:FindAllByClassnameWithin("dota_item_drop", self.parent:GetAbsOrigin(), self.parent:GetHullRadius() * 2)

	-- loop through the items on the floor and add them to heroes inventory
	for _, obj in pairs(objs) do

		-- get item from container
		local item = obj:GetContainedItem()
		self.parent:AddItem(item)

		UTIL_Remove(obj)

	end
end
