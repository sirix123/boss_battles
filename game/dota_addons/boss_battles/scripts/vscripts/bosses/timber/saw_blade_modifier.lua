saw_blade_modifier = class({})


function saw_blade_modifier:OnCreated(kv)
	self.radius = 100
	self.tick_rate = 1
	
	if IsServer() then
		self:StartIntervalThink(self.tick_rate)
	end
end

--------------------------------------------------------------------------------
function saw_blade_modifier:OnIntervalThink()
	local enemies = FindUnitsInRadius(
		DOTA_TEAM_GOODGUYS,	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
		DOTA_UNIT_TARGET_ALL,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
		FIND_ANY_ORDER,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
        print("find someone.... ")
	end
end
