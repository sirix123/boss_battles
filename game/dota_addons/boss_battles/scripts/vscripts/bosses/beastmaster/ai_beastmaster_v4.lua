LinkLuaModifier("ai_bear", "bosses/beastmaster/ai_bear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_remove_healthbar", "core/modifier_remove_healthbar", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "beastmaster_puddle_dot_debuff_attack", "bosses/beastmaster/beastmaster_puddle_dot_debuff_attack", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "beastmaster_puddle_dot_debuff_attack_player_debuff", "bosses/beastmaster/beastmaster_puddle_dot_debuff_attack_player_debuff", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	boss_frame_manager:SendBossName()
	boss_frame_manager:UpdateManaHealthFrame( thisEntity )
	boss_frame_manager:ShowBossHpFrame()
	boss_frame_manager:ShowBossManaFrame()

	_G.Beastmaster_Puddles_Locations = {}

	thisEntity:AddNewModifier( nil, nil, "modifier_remove_healthbar", { duration = -1 } )

	thisEntity:SetMana(0)

	-- abilities this boss has
	thisEntity.beastmaster_mark = thisEntity:FindAbilityByName( "beastmaster_mark" )
	thisEntity.summon_bear = thisEntity:FindAbilityByName( "summon_bear" )

	thisEntity.roar = thisEntity:FindAbilityByName( "roar" )
	thisEntity.roar:StartCooldown(30)

	thisEntity.summon_bird = thisEntity:FindAbilityByName( "summon_bird" )
	thisEntity.summon_bird:StartCooldown(10)

	thisEntity.summon_quillboar = thisEntity:FindAbilityByName( "summon_quillboar" )
	thisEntity.summon_quillboar:StartCooldown(15)

	thisEntity.beastmaster_net = thisEntity:FindAbilityByName( "beastmaster_net" )
	thisEntity.beastmaster_net:StartCooldown(thisEntity.beastmaster_net:GetCooldown(thisEntity.beastmaster_net:GetLevel()))

	thisEntity.beastmaster_break = thisEntity:FindAbilityByName( "beastmaster_break" )
	thisEntity.beastmaster_break:StartCooldown(thisEntity.beastmaster_break:GetCooldown(thisEntity.beastmaster_break:GetLevel()))

	thisEntity.puddle_projectile_spell = thisEntity:FindAbilityByName( "puddle_projectile_spell" )

	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 } )

	thisEntity.enraged = false
	thisEntity.poison_on = false

	thisEntity.mana_regen = thisEntity:GetManaRegen()

	-- summon dino
	thisEntity.dino_spawns = {
		Vector(-3049.123779,-11183.102539,261.128906),
		Vector(-3058.546387,-8512.565430,261.128906),
		Vector(-333.317780,-8508.639648,261.128906),
		Vector(-320.668762,-11194.767578,261.128906),
	}

	DinoSpawn()

	--PoisonSpellRootChecker()

	Timers:CreateTimer(5,function ()

		local dino_spawn = thisEntity.dino_spawns[RandomInt(1,#thisEntity.dino_spawns)]

		CreateUnitByName("npc_beastmaster_bear", dino_spawn, true, nil, nil, DOTA_TEAM_BADGUYS)

		return false
	end)

	thisEntity:SetContextThink( "Beastmaster", BeastmasterThink, 0.5 )

	thisEntity:SetHullRadius(60)
end

--------------------------------------------------------------------------------

function BeastmasterThink()
	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		--[[for _, puddle in pairs(Beastmaster_Puddles_Locations) do
			if puddle then
				print("puddle")
				--puddle:Destroy()
				puddle:ForceKill(false)
			end
		end]]
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	thisEntity:SetBaseManaRegen(thisEntity.mana_regen)

	if thisEntity:HasModifier("beastmaster_bloodlust_modifier") and thisEntity.enraged == false then
		DinoSpawn()
		thisEntity.puddle_projectile_spell:StartCooldown(RandomInt(5,15))
		thisEntity.enraged = true
	end

	if thisEntity:HasModifier("puddle_projectile_spell_beastmaster_buff") and thisEntity.poison_on == false then
		thisEntity.poison_on = true

		if thisEntity:HasModifier("modifier_rooted") then
			thisEntity:RemoveModifierByName("modifier_rooted")
		end

		local stacks = 0
		if thisEntity:HasModifier("puddle_projectile_spell_beastmaster_buff") then
			stacks = thisEntity:GetModifierStackCount("puddle_projectile_spell_beastmaster_buff", thisEntity)
			thisEntity:RemoveModifierByName("puddle_projectile_spell_beastmaster_buff")
		end

		if stacks ~= 0 then
			thisEntity:AddNewModifier( thisEntity,thisEntity.puddle_projectile_spell, "beastmaster_puddle_dot_debuff_attack", { duration = 15, stacks = stacks } )
			PoisonTimer()
		end
	end

	if thisEntity.roar:IsFullyCastable() and thisEntity.roar:IsCooldownReady() and thisEntity.roar:IsInAbilityPhase() == false then
		return CastRoar()
	end

	if thisEntity.summon_bird:IsFullyCastable() and thisEntity.summon_bird:IsCooldownReady() and thisEntity:GetHealthPercent() < 95 and thisEntity.summon_bird:IsInAbilityPhase() == false then
		return SummonBird()
	end

	if thisEntity.summon_quillboar:IsFullyCastable() and thisEntity.summon_quillboar:IsCooldownReady() and thisEntity.summon_quillboar:IsInAbilityPhase() == false then
		return SummonQuillBoar()
	end

	if thisEntity.beastmaster_net:IsFullyCastable() and thisEntity.beastmaster_net:IsCooldownReady() and thisEntity.beastmaster_net:IsInAbilityPhase() == false then
		return BeastmasterNet_v2()
	end

	if thisEntity.enraged == true then
		if thisEntity.puddle_projectile_spell:IsFullyCastable() and thisEntity.puddle_projectile_spell:IsCooldownReady() and thisEntity.puddle_projectile_spell:IsInAbilityPhase() == false then
			return CastPuddleSpell()
		end
	end

	return 0.5
end

--------------------------------------------------------------------------------


function CastRoar()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.roar:entindex(),
		Queue = false,
	})

	local spell_puddle_cd = thisEntity.puddle_projectile_spell:GetCooldown(thisEntity.puddle_projectile_spell:GetLevel())
	if spell_puddle_cd <= 5 then
		thisEntity.puddle_projectile_spell:StartCooldown(RandomInt(15,25))
	end

	thisEntity:SetBaseManaRegen(0)

	return thisEntity.roar:GetSpecialValueFor( "duration" ) + thisEntity.beastmaster_net:GetCastPoint() + 1
end
--------------------------------------------------------------------------------

function CastPuddleSpell()

	thisEntity:AddNewModifier( nil, nil, "modifier_rooted", { duration = -1 } )

	PoisonSpellRootChecker()

	local roar_cd = thisEntity.roar:GetCooldown(thisEntity.roar:GetLevel())
	if roar_cd <= 35 then
		thisEntity.roar:StartCooldown(RandomInt(35,42))
	end

	thisEntity.beastmaster_net:StartCooldown(RandomInt(10,20))

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.puddle_projectile_spell:entindex(),
		Queue = false,
	})

	return thisEntity.puddle_projectile_spell:GetChannelTime()
end
--------------------------------------------------------------------------------

function SummonBird()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.summon_bird:entindex(),
		Queue = false,
	})

	return 0.5
end

--------------------------------------------------------------------------------

function SummonQuillBoar()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.summon_quillboar:entindex(),
		Queue = false,
	})
	return 0.5
end

------------------------------------------------------------------------------------------------------------

function BeastmasterNet_v2()

	local tFarTargets = {}

	local units = FindUnitsInRadius(
		thisEntity:GetTeamNumber(),	-- int, your team number
		thisEntity:GetAbsOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	if units == nil or #units == 0 then
		return 0.5
	else
		for _, unit in pairs(units) do
			if ( thisEntity:GetAbsOrigin() - unit:GetAbsOrigin() ):Length2D() > 400 and unit:HasModifier("grab_player_modifier") == false and unit:HasModifier("modifier_stunned") == false then
				table.insert(tFarTargets,unit)
			end
		end

		if tFarTargets == nil or #tFarTargets == 0 then
			return 0.5
		else
			thisEntity.hTarget = tFarTargets[RandomInt(1, #tFarTargets)]

			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = thisEntity.hTarget:entindex(),
				AbilityIndex = thisEntity.beastmaster_net:entindex(),
				Queue = false,
			})

			return thisEntity.beastmaster_net:GetCastPoint() + 1
		end
	end

	return 0.5
end
---------------------------------------------------------------------------------

function PoisonTimer()
	-- poison checker
	Timers:CreateTimer(30,function ()
		if IsValidEntity(thisEntity) == false then return false end

		if thisEntity:HasModifier("beastmaster_puddle_dot_debuff_attack") then
			thisEntity:RemoveModifierByName("beastmaster_puddle_dot_debuff_attack")
		end

		thisEntity.poison_on = false

		return false
	end)
end

--------------------------------------------------------------------------------

function DinoSpawn()
	Timers:CreateTimer(5,function ()
		if IsValidEntity(thisEntity) == false then return false end

		local dino_spawn = thisEntity.dino_spawns[RandomInt(1,#thisEntity.dino_spawns)]
		local center_pos = Vector(-1496.469482, -9943.101563, 261.128906)

		local dino = CreateUnitByName("npc_beastmaster_dino", dino_spawn, true, nil, nil, DOTA_TEAM_BADGUYS)
		dino:SetForwardVector(center_pos)
		dino:FaceTowards(center_pos)

		return false
	end)
end
--------------------------------------------------------------------------------

function PoisonSpellRootChecker()
	-- if for some reason the posion never hits beastmaster at all we will manually remove the root so the fight can continue
	Timers:CreateTimer(thisEntity.puddle_projectile_spell:GetChannelTime() + 5,function ()
		if IsValidEntity(thisEntity) == false then return false end

		if thisEntity.poison_on == true then
			return false
		end

		if thisEntity:HasModifier("modifier_rooted") and thisEntity.poison_on == false then
			thisEntity:RemoveModifierByName("modifier_rooted")
		end

		return thisEntity.puddle_projectile_spell:GetChannelTime() + 4
	end)
end

--------------------------------------------------------------------------------