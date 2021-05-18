
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

	thisEntity.bear_charge = thisEntity:FindAbilityByName( "bear_charge" )
	--thisEntity.bear_charge:StartCooldown(thisEntity.bear_charge:GetCooldown(thisEntity.bear_charge:GetLevel()))

	thisEntity.bear_claw = thisEntity:FindAbilityByName( "bear_claw" )
	thisEntity.cast_claw = false

	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 } )

	TargetingTimer()

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
		1500,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		FIND_ANY_ORDER,
		false)

	local stacks = 0
	if thisEntity:HasModifier("bear_bloodlust_modifier") then
		stacks = thisEntity:GetModifierStackCount("bear_bloodlust_modifier", thisEntity)
		if stacks >= 10 then
			thisEntity.cast_claw = true
		end
	end

	if thisEntity.hBloodlust ~= nil and thisEntity.hBloodlust:IsCooldownReady() and thisEntity.hBloodlust:IsFullyCastable() and stacks < 20 then
		return CastBloodlust()
	end

	if thisEntity.bear_charge ~= nil and thisEntity.bear_charge:IsFullyCastable() and thisEntity.bear_charge:IsCooldownReady() and #enemies >= 1 then
		return CastCharge()
	end

	if thisEntity.bear_claw ~= nil and thisEntity.bear_claw:IsFullyCastable() and thisEntity.bear_claw:IsCooldownReady() and thisEntity.cast_claw == true then
		return CastClaw()
	end

	return 0.1
end

--------------------------------------------------------------------------------

function CastCharge()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.bear_charge:entindex(),
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

function CastClaw()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = thisEntity.bear_target:entindex(),
		AbilityIndex = thisEntity.bear_claw:entindex(),
		Queue = false,
	})
	return 0.5
end



function TargetingTimer()
	Timers:CreateTimer(3.0,function()
		if IsValidEntity(thisEntity) ==  false then
			return false
		end

		local bear_enemies = FindUnitsInRadius(
			DOTA_TEAM_BADGUYS,
			thisEntity:GetOrigin(),
			nil,
			5000,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			FIND_FARTHEST,
			false)

		if bear_enemies ~= nil and #bear_enemies ~= 0 then
			thisEntity.bear_target = bear_enemies[1]
			thisEntity:MoveToTargetToAttack(thisEntity.bear_target)
		end

		return RandomInt(12,22)
	end)
end
