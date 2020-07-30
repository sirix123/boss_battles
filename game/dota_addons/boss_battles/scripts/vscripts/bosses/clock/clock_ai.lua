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

	thisEntity.timberSpawnTime = GameRules:GetGameTime()

	-- handle level up
	thisEntity.levelTracker = 0

	--thisEntity:SetContextThink( "Clock", ClockThink, 0.5 )
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

	-- find cloest player and attack if nothing else can be cast... add everything not ready?
	-- GetAggroTarget
	if thisEntity:GetAttackTarget() == nil then
		AttackClosestPlayer()
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

function AttackClosestPlayer()
	-- find closet player
	local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST,
		false )

	if #enemies == 0 then
		return 0.5
	end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		TargetIndex = enemies[1]:entindex(),
		Queue = 0,
	})

	return 0.5
end
--------------------------------------------------------------------------------