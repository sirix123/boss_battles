clock_ai = class({})

function Spawn( entityKeyValues )

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	-- set mana to 0 on spawn
	thisEntity:SetMana(0)

	-- droids + turrets
	thisEntity.summon_flame_turret = thisEntity:FindAbilityByName( "summon_flame_turret" )
	thisEntity.summon_chain_gun_turret = thisEntity:FindAbilityByName( "summon_chain_gun_turret" )
	thisEntity.summon_furnace_droid = thisEntity:FindAbilityByName( "summon_furnace_droid" )

	-- electric turret
	thisEntity.summon_electric_turret = thisEntity:FindAbilityByName( "summon_electric_turret" )

	-- hook
	thisEntity.hookshot = thisEntity:FindAbilityByName( "hookshot" )
	thisEntity.return_hookshot = thisEntity:FindAbilityByName( "return_hookshot" )
	thisEntity.hookshotStayInFurnaceDuration = 20

	-- salvo
	thisEntity.missile_salvo = thisEntity:FindAbilityByName( "missile_salvo" )
	thisEntity.nMaxWaves = thisEntity.missile_salvo:GetLevelSpecialValueFor("flTimeBetweenWaves", thisEntity.missile_salvo:GetLevel())
	thisEntity.fTimeBetweenWaves = thisEntity.missile_salvo:GetLevelSpecialValueFor("nMaxWaves", thisEntity.missile_salvo:GetLevel())

	-- chooking gas
	thisEntity.missile_salvo = thisEntity:FindAbilityByName( "choking_gas" )

	-- invul debuff
	thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )

	thisEntity.clockSpawnTime = GameRules:GetGameTime()

	-- handle level up
	thisEntity.levelTracker = 0

	-- states
	thisEntity.STATE = 0
	thisEntity.NOT_BURN_PHASE = 0
	thisEntity.BURN_PHASE = 1

	thisEntity:SetContextThink( "Clock", ClockThink, 0.5 )
end

function ClockThink()

	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	--[[ level up abilities at certain hp %ers
	if thisEntity:GetHealthPercent() < 99 and thisEntity.levelTracker == 0 then
		LevelUpAbilities() -- forces all abilities to be level 1
	end
	if thisEntity:GetHealthPercent() < 80 and thisEntity.levelTracker == 1 then
		LevelUpAbilities() -- forces all abilities to be level 2
	end
	if thisEntity:GetHealthPercent() < 60 and thisEntity.levelTracker == 2 then
		LevelUpAbilities() -- forces all abilities to be level 3
	end
	if thisEntity:GetHealthPercent() < 40 and thisEntity.levelTracker == 3 then
		LevelUpAbilities() -- forces all abilities to be level 4
	end]]

	print(thisEntity.STATE)

	-- apply invul every loop, remove invul explcitly in furnace below modifier
	thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )

	-- state machine? - YES SIR
	if thisEntity.STATE == thisEntity.BURN_PHASE then
		if thisEntity:HasModifier("inside_furnace_modifier") == false then -- this applied in furnace AI
			if thisEntity.return_hookshot:IsFullyCastable() then
				thisEntity.STATE = thisEntity.NOT_BURN_PHASE
				return CastReturnHookshot()
			end
		else -- if clock has the furnace modiifer then remove invul, wait, then hook back

			-- remove invul
			thisEntity:RemoveModifierByName("modifier_invulnerable")

			-- wait x seconds then returnhook
			Timers:CreateTimer(thisEntity.hookshotStayInFurnaceDuration, function()
				return false
			end)

			-- cast return hookshot
			if thisEntity.return_hookshot:IsFullyCastable() then
				thisEntity.STATE = thisEntity.NOT_BURN_PHASE
				return CastReturnHookshot()
			end
		end
	end

	if thisEntity.STATE == thisEntity.NOT_BURN_PHASE then

		--hook shot cast on x mana, gets mana from furnace droids
		if thisEntity.hookshot:IsFullyCastable() then
			thisEntity.STATE = thisEntity.BURN_PHASE
			-- i dont want to large return values here cause then the invul won't drop straight away, start cooldown works better
			thisEntity.return_hookshot:StartCooldown(thisEntity.return_hookshot:GetCooldown(thisEntity.return_hookshot:GetLevel()))
			return CastHookshot()
		end

		-- cast xyz spell on cd


	end

	return 0.5
end
--------------------------------------------------------------------------------

function HardModeCheck()


end
--------------------------------------------------------------------------------

function LevelUpAbilities()

	--[[thisEntity.levelTracker = thisEntity.levelTracker + 1

	thisEntity.saw_blade:SetLevel(thisEntity.levelTracker)
	thisEntity.chain:SetLevel(thisEntity.levelTracker)
	thisEntity.fire_shell:SetLevel(thisEntity.levelTracker)
	thisEntity.timber_droid_support:SetLevel(thisEntity.levelTracker)
	thisEntity.blast_wave:SetLevel(thisEntity.levelTracker)]]

end
--------------------------------------------------------------------------------

function FindRandomPlayer()
	-- find closet player
	local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil,
		5000,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST,
		false )

	if #enemies == 0 then
		return 0.5
	end

	local i = RandomInt(1,#enemies)

	return enemies[i]
end
--------------------------------------------------------------------------------

function CastHookshot()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.hookshot:entindex(),
		Queue = 0,
	})

	return 0.5
end
--------------------------------------------------------------------------------

function CastReturnHookshot()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.return_hookshot:entindex(),
		Queue = 0,
	})

	return 0.5
end
--------------------------------------------------------------------------------