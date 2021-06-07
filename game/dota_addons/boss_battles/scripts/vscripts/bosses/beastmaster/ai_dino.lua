
dino_ai = class({})
LinkLuaModifier("modifier_generic_everything_phasing", "core/modifier_generic_everything_phasing", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	thisEntity:AddNewModifier( nil, nil, "modifier_remove_healthbar", { duration = -1 } )
	thisEntity:AddNewModifier( nil, nil, "modifier_generic_everything_phasing", { duration = -1 } )
	thisEntity:AddNewModifier( thisEntity, nil, "modifier_invulnerable", { duration = -1 } )

	thisEntity.STATE = 1

	thisEntity.moving = false
	thisEntity.vWaterPos = nil
	thisEntity.charge_target = nil

	thisEntity.dino_spawns = {
		Vector(-3049.123779,-11183.102539,261.128906),
		Vector(-3058.546387,-8512.565430,261.128906),
		Vector(-333.317780,-8508.639648,261.128906),
		Vector(-320.668762,-11194.767578,261.128906),
	}

	thisEntity.center_pos = Vector(-1496.469482, -9943.101563, 261.128906)
	thisEntity:SetForwardVector(thisEntity.center_pos)
	thisEntity:FaceTowards(thisEntity.center_pos)

	thisEntity.dino_charge = thisEntity:FindAbilityByName( "dino_charge" )
	thisEntity.dino_charge:StartCooldown(10)

	thisEntity.charge_cooldown = 40

	thisEntity:SetContextThink( "DinoThink", DinoThink, 0.5 )

end

--------------------------------------------------------------------------------

function DinoThink()
	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	--print("thisEntity.STATE ,", thisEntity.STATE)

	-- state 1
	-- dino waits until charge is off CD sitting in the corner, charge off cd, finds a target and charges at them
	if thisEntity.STATE == 1 then

		if thisEntity.charge_target == nil then
			if thisEntity.dino_charge:IsFullyCastable() and thisEntity.dino_charge:IsCooldownReady() and thisEntity.dino_charge:IsInAbilityPhase() == false and thisEntity.moving == false then
				-- find target
				local enemies = FindUnitsInRadius(
					DOTA_TEAM_BADGUYS,
					thisEntity:GetAbsOrigin(),
					nil,
					3500,
					DOTA_UNIT_TARGET_TEAM_ENEMY,
					DOTA_UNIT_TARGET_HERO,
					DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
					FIND_ANY_ORDER,
					false )

				if #enemies == 0 or enemies == nil then
					--print("cant find enemies")
					return 0.5
				else
					thisEntity.charge_target = enemies[RandomInt(1,#enemies)]
					if thisEntity.charge_target:HasModifier("grab_player_modifier") == true then
						thisEntity.charge_target = nil
						return 1
					end
				end

				return CastDinoCharge( thisEntity.charge_target )
			end
		end

		-- stuff that is checked during the cp
		if thisEntity.charge_target ~= nil and thisEntity.dino_charge:IsInAbilityPhase() == true then

			if thisEntity.charge_target:HasModifier("q_iceblock_modifier") then
				thisEntity.charge_target:RemoveModifierByName("q_iceblock_modifier")
				thisEntity.STATE = 1
				thisEntity.charge_target = nil
			end

			if thisEntity.charge_target:IsAlive() == false then
				thisEntity.STATE = 3
			end

			if thisEntity.charge_target:IsInvulnerable() == true then
				thisEntity.STATE = 1
				thisEntity.charge_target = nil
			end
		end

		-- stuff that happens after the windup/castpoint
		if thisEntity:HasModifier("modifier_generic_arc_lua") == false and thisEntity.dino_charge:IsInAbilityPhase() == false and thisEntity.charge_target ~= nil then

			--print("distance, ",distance)
			local distance = ( thisEntity:GetAbsOrigin() - thisEntity.charge_target:GetAbsOrigin() ):Length2D()

			if distance < 150 then
				--print("are we close to the player")
				thisEntity.STATE = 2
				return 3
			elseif ( distance > 150 ) and thisEntity.charge_target:HasModifier("grab_player_modifier_dino") == false then
				thisEntity.STATE = 3
				return 3
			end
		end

	end

	-- state 2
	if thisEntity.STATE == 2 then
		if thisEntity.charge_target:HasModifier("grab_player_modifier_dino") and thisEntity.charge_target:IsAlive() == true then
			print("i have grabbed the player")
			if thisEntity.vWaterPos == nil then
				
				local vPos = {
					Vector(-1789.364868, -11690.703125, 133.128906),
					Vector(-3550.518311, -9739.487305, 133.128906),
					Vector(-1465.154541, -7916.410156, 133.128906),
					Vector(191.335999, -10026.628906, 133.128906),
				}

				local previous_length = 9999
				local closetPos = Vector(0,0,0)
				for _, pos in pairs(vPos) do
					if ( pos - thisEntity:GetAbsOrigin() ):Length2D() <= previous_length then
						previous_length = ( pos - thisEntity:GetAbsOrigin() ):Length2D()
						closetPos = pos
					end
				end

				print("i have picked a location to go to")
				thisEntity.vWaterPos = closetPos
				thisEntity:MoveToPosition(thisEntity.vWaterPos)

			end

			if ( thisEntity:GetAbsOrigin() - thisEntity.vWaterPos ):Length2D() < 100 then
				print("i am moving to the water")

				FindClearSpaceForUnit(thisEntity.charge_target, thisEntity:GetAbsOrigin(), true)

				if thisEntity.charge_target:HasModifier("grab_player_modifier_dino") == true then
					thisEntity.charge_target:RemoveModifierByName("grab_player_modifier_dino")
				end
				thisEntity.STATE = 3
				return 3
			end

		else
			thisEntity.STATE = 3
			return 3
		end
	end

	-- stage 3
	-- handles resetting back to the corner
	if thisEntity.STATE == 3 then
		if thisEntity.charge_target:HasModifier("grab_player_modifier_dino") then
			thisEntity.STATE = 2
		end

		if thisEntity.vResetPos == nil then

			local previous_length = 0
			local furthestPos = Vector(0,0,0)
			for _, pos in pairs(thisEntity.dino_spawns) do
				if ( pos - thisEntity:GetAbsOrigin() ):Length2D() >= previous_length then
					previous_length = ( pos - thisEntity:GetAbsOrigin() ):Length2D()
					furthestPos = pos
				end
			end

			thisEntity.vResetPos = furthestPos
			thisEntity:MoveToPosition(thisEntity.vResetPos)
			return 1
		end

		if ( thisEntity:GetAbsOrigin() - thisEntity.vResetPos ):Length2D() < 100 then
			thisEntity.charge_cooldown = RandomInt(20,50)
			thisEntity.dino_charge:StartCooldown(thisEntity.charge_cooldown)
			thisEntity.vResetPos = nil
			thisEntity.charge_target = nil
			thisEntity.vWaterPos = nil
			thisEntity.moving = false
			thisEntity:SetForwardVector(thisEntity.center_pos)
			thisEntity:FaceTowards(thisEntity.center_pos)
			thisEntity.STATE = 1
			return 1
		end
	end

	return 1
end

--------------------------------------------------------------------------------

function CastDinoCharge( hTarget )

	thisEntity.moving = true

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = hTarget:entindex(),
		AbilityIndex = thisEntity.dino_charge:entindex(),
		Queue = false,
	})

	return 1
end
--------------------------------------------------------------------------------