
--[[ bosses/beastmaster/ai_bear.lua ]]
LinkLuaModifier("bear_death_modifier", "bosses/beastmaster/bear_death_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bear_bloodlust_modifier", "bosses/beastmaster/bear_bloodlust_modifier", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	thisEntity:AddNewModifier( thisEntity, thisEntity, "bear_death_modifier", { duration = -1 } )

	thisEntity.hClaw = thisEntity:FindAbilityByName( "bear_claw" )
	thisEntity.hClaw:StartCooldown(thisEntity.hClaw:GetCooldown(thisEntity.hClaw:GetLevel()))

	thisEntity.hBloodlust = thisEntity:FindAbilityByName( "bear_bloodlust" )
	thisEntity.hBloodlust:StartCooldown(thisEntity.hBloodlust:GetCooldown(thisEntity.hBloodlust:GetLevel()))

	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 } )

	thisEntity:SetContextThink( "BearThink", BearThink, 0.5 )

	thisEntity.target = nil

	thisEntity:SetHullRadius(60)

end

--------------------------------------------------------------------------------

function BearThink()
	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	-- find all players in the entire map
	local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetOrigin(),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false)

	if #enemies == 0 then
		return 0.5
	end

	-- search each enemy on the map for the beastmaster mark
	for _, enemy in pairs(enemies) do
		if enemy:HasModifier("beastmaster_mark_modifier") then
			thisEntity.target = enemy
			thisEntity:MoveToTargetToAttack(thisEntity.target)
		end
	end

	if thisEntity.hClaw ~= nil and thisEntity.hClaw:IsFullyCastable() and thisEntity.hBloodlust:IsCooldownReady() then
		return CastClaw(thisEntity.target)
	end

	if thisEntity.hBloodlust ~= nil and thisEntity.hBloodlust:IsCooldownReady() then
		--print("we casting this every 10seconds?")
		return CastBloodlust()
	end

	return 0.1
end

--------------------------------------------------------------------------------

function CastClaw(beastmasterMarkTarget)
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			TargetIndex = beastmasterMarkTarget:entindex(),
			AbilityIndex = thisEntity.hClaw:entindex(),
			Queue = false,
	})

	return 0.5
end

function CastBloodlust()
		ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.hBloodlust:entindex(),
		Queue = false,
	})
	return 0.5
end

