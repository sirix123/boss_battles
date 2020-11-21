
LinkLuaModifier( "droid_colour_modifier_green", "bosses/timber/droid_colour_modifier_green", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_flying_movement_ground", "core/modifier_flying_movement_ground", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then return end

	thisEntity.smelter_droid_enhance = thisEntity:FindAbilityByName( "smelter_droid_enhance" )

	--thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })

	thisEntity:AddNewModifier(thisEntity, self, "droid_colour_modifier_green", {duration = 9000})
	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })
	thisEntity:AddNewModifier( nil, nil, "modifier_flying_movement_ground", { duration = -1 })

	thisEntity:SetHullRadius(60)

	thisEntity:SetContextThink( "DroidThink", DroidThink, 0.5 )

end
--------------------------------------------------------------------------------

function DroidThink()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	-- find timber
	local friendlies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil, 
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false )

	if #friendlies == 0 then
		return 0.5
	end

	-- find timber
	for _, friendly in pairs(friendlies) do
		if friendly:GetUnitName() == "npc_timber" then

			-- distance from droid to timber 
			thisEntity.distanceFromTimber = ( thisEntity:GetAbsOrigin() - friendly:GetAbsOrigin() ):Length2D()

			-- cast enhance
			if thisEntity.smelter_droid_enhance:IsCooldownReady() and ( thisEntity.distanceFromTimber < 800 ) then
				CastEnhance()
			elseif thisEntity.distanceFromTimber > 800 then
				thisEntity:MoveToPosition( friendly:GetAbsOrigin() )
			end
		end
	end

	return 0.5
end
--------------------------------------------------------------------------------

function CastEnhance()
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			AbilityIndex = thisEntity.smelter_droid_enhance:entindex(),
			Queue = false,
	})
	return 1
end
--------------------------------------------------------------------------------
