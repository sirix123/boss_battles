LinkLuaModifier("modifier_remove_healthbar", "core/modifier_remove_healthbar", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_everything_phasing", "core/modifier_generic_everything_phasing", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("chain_edge_bubble", "bosses/timber/chain_edge_bubble", LUA_MODIFIER_MOTION_NONE)

timber_ai_v2 = class({})

function Spawn( entityKeyValues )

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	boss_frame_manager:SendBossName()
	boss_frame_manager:UpdateManaHealthFrame( thisEntity )
	boss_frame_manager:ShowBossManaFrame()
	boss_frame_manager:ShowBossHpFrame()

	if SOLO_MODE == true then
        thisEntity:AddNewModifier( nil, nil, "SOLO_MODE_modifier", { duration = -1 } )
    end

	-- set mana to 0 on spawn
	thisEntity:SetMana(0)

	thisEntity:AddNewModifier( nil, nil, "modifier_remove_healthbar", { duration = -1 } )
	thisEntity:AddNewModifier( nil, nil, "modifier_generic_everything_phasing", { duration = -1 } )

	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })

	-- saw blade references and init
	thisEntity.saw_blade = thisEntity:FindAbilityByName( "saw_blade" )
	thisEntity.saw_blade:StartCooldown(3)
	thisEntity.nMaxSawBlades = thisEntity.saw_blade:GetLevelSpecialValueFor("nMaxSawBlades", thisEntity.saw_blade:GetLevel())
	thisEntity.nCurrentSawBlades = 0
	thisEntity.return_saw_blades = thisEntity:FindAbilityByName( "return_saw_blades" )

	-- chain references and init
	thisEntity.chain = thisEntity:FindAbilityByName( "chain" )
	thisEntity.chain:StartCooldown(5)

	thisEntity.chain_map_edge = thisEntity:FindAbilityByName( "chain_map_edge" )
	thisEntity.chain_edge_speed = thisEntity.chain_map_edge:GetLevelSpecialValueFor("speed", thisEntity.chain_map_edge:GetLevel())
	thisEntity.createParticleOnce = true

	thisEntity.mana_regen = thisEntity:GetManaRegen()

	thisEntity.vertical_saw_blade = thisEntity:FindAbilityByName( "vertical_saw_blade" )

	-- fire shell references and init
	thisEntity.fire_shell = thisEntity:FindAbilityByName( "fire_shell" )
	thisEntity.nMaxWaves = thisEntity.fire_shell:GetLevelSpecialValueFor("nMaxWaves", thisEntity.fire_shell:GetLevel())
	thisEntity.fTimeBetweenWaves = thisEntity.fire_shell:GetLevelSpecialValueFor("fTimeBetweenWaves", thisEntity.fire_shell:GetLevel())

	-- droid support references and init
	thisEntity.timber_droid_support = thisEntity:FindAbilityByName( "timber_droid_support" )

	-- blast wave references and init
	thisEntity.blast_wave = thisEntity:FindAbilityByName( "blast_wave_v2" )

	thisEntity.timberSpawnTime = GameRules:GetGameTime()

	-- handle level up
	thisEntity.levelTracker = 0
	thisEntity.state = 1

	thisEntity:SetHullRadius(60)

	thisEntity:SetContextThink( "Timber", TimberThink, 0.5 )
end

function TimberThink()

	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	-- state change handler
	if thisEntity:GetHealthPercent() < 85 and thisEntity.chain_map_edge:IsCooldownReady() == true then
		thisEntity.createParticleOnce = true
		thisEntity.draw_feet_particle_helper = true
		thisEntity:SetBaseManaRegen(0)
		thisEntity.state = 2
	elseif thisEntity.state == 2 and ( FindUnitsCloseAndBubbleGone() == true or thisEntity.end_phase_2 == true ) then

		-- destroy feet particle
		if thisEntity.nPreviewFXIndex then
			ParticleManager:DestroyParticle(thisEntity.nPreviewFXIndex,true)
		end

		-- start the CD on fireshell just incase he can cast it when the circle is tiny particles/units/heroes/hero_shredder/shredder_armor_lyr.vpcf
		thisEntity.fire_shell:StartCooldown(60)

		-- furion handler
		thisEntity:EmitSoundParams("furion_furi_death_04", 1, 3.0, 0.0)

		-- tp particle effect
		local particle = "particles/units/heroes/hero_furion/furion_teleport.vpcf"
		local nFXIndex = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, nil )

        ParticleManager:SetParticleControl(nFXIndex, 0, Vector(10136,-10597,136) )

		Timers:CreateTimer(4, function()
			if IsValidEntity(thisEntity) == false then return false end
			ParticleManager:DestroyParticle(nFXIndex, false)
			thisEntity.furion = CreateUnitByName( "npc_furion", Vector(10136,-10597,136), true, thisEntity, thisEntity, DOTA_TEAM_BADGUYS)
			EmitSoundOn("Hero_Furion.Teleport_Appear", thisEntity.furion)

			-- animation channel
			thisEntity.furion:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 0.3)
			return false
		end)

		Timers:CreateTimer(12, function()
			if IsValidEntity(thisEntity) == false then return false end

			-- play tp sound and voiceline
			--EmitGlobalSound("furion_furi_ability_wrath_09")
			thisEntity:EmitSoundParams("furion_furi_ability_wrath_09", 1, 3.0, 0.0)

			-- regrow all trees
			GridNav:RegrowAllTrees()

			return false
		end)

		Timers:CreateTimer(14, function()

			if IsValidEntity(thisEntity.furion) == false then
				return false
			else
				-- particle effect on furion to show tp out, just release particel
				local particle_end = "particles/units/heroes/hero_furion/furion_teleport_flash.vpcf"
				local nFXIndex_end = ParticleManager:CreateParticle( particle_end, PATTACH_WORLDORIGIN, nil )
				ParticleManager:SetParticleControl(nFXIndex_end, 0, thisEntity.furion:GetAbsOrigin() )

				-- remove him from game
				thisEntity.furion:SetAbsOrigin(Vector(0,0,0))
				thisEntity.furion:ForceKill(false)
				UTIL_Remove( thisEntity.furion )

				return false
			end
		end)

		thisEntity:SetBaseManaRegen(thisEntity.mana_regen)
		thisEntity:RemoveModifierByName("modifier_rooted")
		thisEntity.state = 1
	end

	if thisEntity.state == 1 then

		if thisEntity:GetMana() >= 85 then
			thisEntity.fire_shell:EndCooldown()
		end

		-- fire shell logic
		if thisEntity:GetHealthPercent() < 99 and thisEntity.fire_shell ~= nil and thisEntity.fire_shell:IsFullyCastable() and thisEntity.fire_shell:IsCooldownReady() and thisEntity.fire_shell:IsInAbilityPhase() == false then
			--print("casting fireshell")
			return CastFireShell()
		end

		-- saw blade cast logic
		if thisEntity.saw_blade:IsInAbilityPhase() == false and thisEntity.saw_blade ~= nil and thisEntity.saw_blade:IsFullyCastable() and thisEntity.nCurrentSawBlades < thisEntity.nMaxSawBlades and thisEntity.saw_blade:IsCooldownReady() then
			thisEntity.nCurrentSawBlades = thisEntity.nCurrentSawBlades + 1
			--print("casting saw baldes")
			return CastSawBlade()
		elseif thisEntity.return_saw_blades ~= nil and thisEntity.saw_blade:IsFullyCastable() and thisEntity.nCurrentSawBlades == thisEntity.nMaxSawBlades and thisEntity.return_saw_blades:IsCooldownReady() then
			--print("casting return sawblades")
			thisEntity.nCurrentSawBlades = 0
			return CastReturnSawBlade()
		end

		-- chain cast logic
		if thisEntity.chain ~= nil and thisEntity.chain:IsFullyCastable() and thisEntity.chain:IsCooldownReady() and thisEntity.chain:IsInAbilityPhase() then
			return CastChain()
		end

		-- droid support logic
		if thisEntity:GetHealthPercent() < 95 and thisEntity.timber_droid_support ~= nil and thisEntity.timber_droid_support:IsFullyCastable() and thisEntity.timber_droid_support:IsCooldownReady() then
			return CastDroidSupport()
		end

		-- blast wave (hardmode) logic 
		if thisEntity.blast_wave ~= nil and thisEntity.blast_wave:IsFullyCastable() and thisEntity:GetHealthPercent() < 95 and thisEntity.blast_wave:IsCooldownReady() then
			return CastBlastWave()
		end

		-- level up abilities at certain hp %ers
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
		end
	end

	if thisEntity.state == 2 then

		if thisEntity.createParticleOnce == true then
			thisEntity.createParticleOnce = false

			thisEntity:AddNewModifier( thisEntity, nil, "chain_edge_bubble", { duration = -1 } )

			thisEntity.end_phase_2 = false
			Timers:CreateTimer(40, function()
				if IsValidEntity(thisEntity) == false then return false end
				thisEntity.end_phase_2 = true
				return false
			end)

		end

		if thisEntity.chain_map_edge ~= nil and thisEntity.chain_map_edge:IsFullyCastable() and thisEntity.chain_map_edge:IsCooldownReady() and thisEntity.chain_map_edge:IsInAbilityPhase() == false then
			return CastChainMapEdge()
		end

		if thisEntity:HasModifier("chain_edge_bubble") ~= true then

			-- only do it once though
			if thisEntity.draw_feet_particle_helper == true then
				thisEntity.draw_feet_particle_helper = false

				-- draw green circle/arrow at timbers feet
				thisEntity.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/custom/markercircle/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
				ParticleManager:SetParticleControl( thisEntity.nPreviewFXIndex, 0, thisEntity:GetAbsOrigin() )
				ParticleManager:SetParticleControl( thisEntity.nPreviewFXIndex, 1, Vector( 600, -600, -600 ) )
				ParticleManager:SetParticleControl( thisEntity.nPreviewFXIndex, 2, Vector( 60, 0, 0 ) );

			end
		end

		if thisEntity.vertical_saw_blade ~= nil and thisEntity.vertical_saw_blade:IsFullyCastable() 
			and thisEntity.vertical_saw_blade:IsCooldownReady() and thisEntity.vertical_saw_blade:IsInAbilityPhase() == false
			and thisEntity.vertical_saw_blade:IsChanneling() == false and thisEntity:HasModifier("chain_edge_bubble") == true
			then
			return CastVerticalSawBlade()
		end
	end

	return 0.5
end
--------------------------------------------------------------------------------

function HardModeCheck()

	local trees = GridNav:GetAllTreesAroundPoint( thisEntity:GetAbsOrigin(), 10000, true )

	if #trees < 1 then
		return true
	else
		return false
	end
end
--------------------------------------------------------------------------------

function LevelUpAbilities()

	thisEntity.levelTracker = thisEntity.levelTracker + 1

	thisEntity.saw_blade:SetLevel(thisEntity.levelTracker)
	thisEntity.chain:SetLevel(thisEntity.levelTracker)
	thisEntity.fire_shell:SetLevel(thisEntity.levelTracker)
	thisEntity.timber_droid_support:SetLevel(thisEntity.levelTracker)
	thisEntity.blast_wave:SetLevel(thisEntity.levelTracker)

end
--------------------------------------------------------------------------------

function FindUnitsCloseAndBubbleGone()

	-- find closet player
	local enemies = FindUnitsInRadius(
		thisEntity:GetTeamNumber(),
		thisEntity:GetAbsOrigin(),
		nil,
		600,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		FIND_CLOSEST,
		false )

	if #enemies == 0 or enemies == nil or thisEntity:HasModifier("chain_edge_bubble") ~= false then
		return false
	elseif #enemies >= 1 and thisEntity:HasModifier("chain_edge_bubble") ~= true then
		return true
	end
end
--------------------------------------------------------------------------------

function AttackClosestPlayer()
	-- find closet player
	local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil,
		3000,
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

function CastSawBlade()

	local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil, 
		3000,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false )

	if #enemies == 0 or enemies == nil then
		return 0.5
	end

	thisEntity.vLocation = enemies[RandomInt(1,#enemies)]:GetAbsOrigin()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = thisEntity.saw_blade:entindex(),
		Position = thisEntity.vLocation,
		Queue = 0,
	})
	return 0.5
end
--------------------------------------------------------------------------------

function CastReturnSawBlade()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.return_saw_blades:entindex(),
		Queue = 0,
	})
	return 3
end
--------------------------------------------------------------------------------

function CastChain()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.chain:entindex(),
		Queue = 0,
	})

	return 4
end
--------------------------------------------------------------------------------

function CastChainMapEdge()

	local tPos ={
		Vector(8598,-10593,136),
		Vector(9771,-8865,136),
		Vector(11628,-10653,136),
		Vector(10332,-12021,136),
	}

	local previous_length = 0
	local furthestPos = Vector(0,0,0)
	for _, pos in pairs(tPos) do
		if ( pos - thisEntity:GetAbsOrigin() ):Length2D() >= previous_length then
			previous_length = ( pos - thisEntity:GetAbsOrigin() ):Length2D()
			furthestPos = pos
		end
	end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = thisEntity.chain_map_edge:entindex(),
		Position = furthestPos,
		Queue = false,
	})

	local time = previous_length / thisEntity.chain_edge_speed
	return time + 2

	--return 2.5
end
--------------------------------------------------------------------------------

function CastVerticalSawBlade()

	-- root self in place
	thisEntity:AddNewModifier( nil, nil, "modifier_rooted", { duration = -1 })

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.vertical_saw_blade:entindex(),
		Queue = 0,
	})
	return 1
end
--------------------------------------------------------------------------------

function CastFireShell()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.fire_shell:entindex(),
		Queue = 0,
	})
	return (thisEntity.nMaxWaves * thisEntity.fTimeBetweenWaves) + 4
end
--------------------------------------------------------------------------------

function CastDroidSupport()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.timber_droid_support:entindex(),
		Queue = 0,
	})
	return 0.5
end
--------------------------------------------------------------------------------

function CastBlastWave()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.blast_wave:entindex(),
		Queue = 0,
	})

	return 0.5
end
--------------------------------------------------------------------------------