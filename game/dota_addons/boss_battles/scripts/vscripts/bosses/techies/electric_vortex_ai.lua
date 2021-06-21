electric_vortex_ai = class({})
LinkLuaModifier( "modifier_electric_vortex", "bosses/techies/modifiers/modifier_electric_vortex", LUA_MODIFIER_MOTION_HORIZONTAL )

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then return end

	thisEntity.electric_vortex = thisEntity:FindAbilityByName( "electric_vortex" )

	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })

	EmitSoundOnLocationWithCaster(thisEntity:GetAbsOrigin(),"Hero_Techies.StasisTrap.Plant",thisEntity)

	thisEntity:SetHullRadius(60)
	
	-- random start time 
	thisEntity.random_start = RandomInt(5,15) -- dont make this higher then 29
	thisEntity.count = thisEntity.random_start
	StartTimer()

	thisEntity:SetContextThink( "ElectricTurretThink", ElectricTurretThink_v2, thisEntity.random_start )
	--ElectricTurretThink_v2 ElectricTurretThink
end
--------------------------------------------------------------------------------

function ElectricTurretThink_v2()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		Timers:RemoveTimer(thisEntity.timer)
		if thisEntity.randomTarget then
			if thisEntity.randomTarget:HasModifier("modifier_electric_vortex") then
				thisEntity.randomTarget:RemoveModifierByName("modifier_electric_vortex")
			end
		end
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	--print(" thisEntity.PHASE  ",thisEntity.PHASE)

	-- phase handler
	if thisEntity.randomTarget == nil then
		thisEntity.PHASE = 1 
		thisEntity.return_value = 0.5
	else
		thisEntity.PHASE = 2
		thisEntity.return_value = 0.1
	end

	if thisEntity:HasModifier("modifier_electric_vortex_phase_change") then
		thisEntity.PHASE = 3
	end

	-- phase 1
	-- find units 
	-- apply electric vortex modifier
	-- find targets
	if thisEntity.PHASE == 1 then
		local targets = FindUnitsInRadius(
			thisEntity:GetTeamNumber(),	-- int, your team number
			thisEntity:GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			3000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		local filtered_targets = {}

		if targets ~= nil and #targets ~= 0 then

			for i, target in pairs(targets) do
				if CheckGlobalUnitTableForUnitName(target) ~= true then
					--print("remoiving rocks as targets / all other units")
					--print("target ",target:GetUnitName())
					--table.remove(targets,i)
					table.insert(filtered_targets,target)
				end
			end

			if filtered_targets ~= nil and #filtered_targets ~= 0 then
				--[[for _, target in pairs(filtered_targets) do
					print("target: ",target:GetUnitName())
				end]]
				thisEntity.randomTarget = filtered_targets[RandomInt(1, #filtered_targets)]
				--print("thisEntity.randomTarget: ",thisEntity.randomTarget:GetUnitName())

				EmitSoundOn("techies_tech_trapgoesoff_01", thisEntity)

				thisEntity.randomTarget:AddNewModifier(
					thisEntity, -- player source
						self, -- ability source
						"modifier_electric_vortex", -- modifier name
						{
							duration = -1,
							x = thisEntity:GetAbsOrigin().x,
							y = thisEntity:GetAbsOrigin().y,
						} -- kv
					)

				local sound_cast = "Hero_StormSpirit.ElectricVortexCast"
				EmitGlobalSound( sound_cast )
			end

			thisEntity.rock = nil

		end
	end

	-- phase 2
	-- find units in line between self and player being dragged (update this a lot)
	-- if a rock enters the line
	-- the end of this line needs to be updateed and be the players location
	if thisEntity.PHASE == 2 then
		local targets_inline = FindUnitsInLine(
			thisEntity:GetTeamNumber(),
			thisEntity:GetAbsOrigin(),
			thisEntity.randomTarget:GetAbsOrigin(),
			nil,
			100,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE)

		-- check end of  line pos
		--DebugDrawCircle(thisEntity.randomTarget:GetAbsOrigin(),Vector(255,0,0),128,100,true,2)

		if thisEntity.rock == nil then
			local previous_distance = 999999
			-- remove non rocks
			for k, unit in pairs(targets_inline) do
				if unit:GetUnitName() ~= "npc_rock_techies" then
					table.remove(targets_inline,k)
				end
			end

			-- find the cloest rock
			if targets_inline ~= nil and #targets_inline ~= 0 then
				--print("rock found")
				--print("#targets_inline, ",#targets_inline)
				for _, unit in pairs(targets_inline) do
					--print("unit name", unit:GetUnitName())
					thisEntity.rock = unit
					local distance = ( thisEntity:GetAbsOrigin() - unit:GetAbsOrigin() ):Length2D()
					if distance < previous_distance then
						thisEntity.rock = unit
					end
					previous_distance = distance
				end

				if thisEntity.randomTarget:HasModifier("modifier_electric_vortex") then
					thisEntity.randomTarget:RemoveModifierByName("modifier_electric_vortex")
					thisEntity.PHASE = 3
					if thisEntity.particle then
						ParticleManager:DestroyParticle(thisEntity.particle, true)
					end
				end

				if IsValidEntity(thisEntity.rock) then
					if thisEntity.rock:HasModifier("modifier_electric_vortex") == nil or thisEntity.rock:HasModifier("modifier_electric_vortex") == false then

						--print("are we trying to apply this to the cube?")

						thisEntity.rock:AddNewModifier(
								thisEntity, -- player source
								self, -- ability source
								"modifier_electric_vortex", -- modifier name
								{
									duration = -1,
									x = thisEntity:GetAbsOrigin().x,
									y = thisEntity:GetAbsOrigin().y,
								} -- kv
							)

					end
				end
			else
				--print("no rock found")
				if thisEntity.randomTarget:HasModifier("modifier_electric_vortex") ~= true then
					thisEntity.PHASE = 3
				end
			end
		end
	end

	-- phase 3
	-- reset a bunch of stuff
	if thisEntity.PHASE == 3 then
		if thisEntity:HasModifier("modifier_electric_vortex_phase_change") then
			thisEntity:RemoveModifierByName("modifier_electric_vortex_phase_change")
		end

		Timers:RemoveTimer(thisEntity.timer) -- remove the old timer for the count down
		thisEntity.random_start = RandomInt(5,15) -- generate a new start time
		thisEntity.count = thisEntity.random_start -- use this start time for timer
		StartTimer() -- start the timer again
		thisEntity.randomTarget = nil -- remove the target so we reenter phase 1
		thisEntity.return_value = thisEntity.random_start
	end

	return thisEntity.return_value
end

--------------------------------------------------------------------------------

function StartTimer()

	--print("thisEntity.count ",thisEntity.count)

	thisEntity.timer = Timers:CreateTimer(function()
		if IsValidEntity(thisEntity) == false then return false end

		if thisEntity.count == 0 or thisEntity:IsAlive() == nil or thisEntity:IsAlive() == false then
			ParticleManager:DestroyParticle(thisEntity.particle, true)
			return false
		end

		if thisEntity.particle then
			ParticleManager:DestroyParticle(thisEntity.particle, true)
		end

		thisEntity.particle = ParticleManager:CreateParticle("particles/techies/wisp_relocate_timer_custom.vpcf", PATTACH_OVERHEAD_FOLLOW, thisEntity)
		--local digitX = thisEntity.count >= 10 and 1 or 0
		if thisEntity.count >= 10 and thisEntity.count < 20 then
			digitX = 1
		elseif thisEntity.count >= 20 then
			digitX = 2
		else 
			digitX = 0
		end

		local digitY = thisEntity.count % 10
		--print("digitX: ",digitX,"digitY: ",digitY)
		ParticleManager:SetParticleControl(thisEntity.particle, 0, thisEntity:GetAbsOrigin())
		ParticleManager:SetParticleControl(thisEntity.particle, 1, Vector( digitX, digitY, 0 ))

		thisEntity.count = thisEntity.count - 1

		return 1.0
	end)

end
--------------------------------------------------------------------------------