function OnStartTouch(trigger)

	--print(trigger.activator)
	--print(trigger.caller)

	if thisEntity == nil then
		--print("returning thisent = nil")
		return
	end
	-- start thinker here
	-- if trigger.activator:GetUnitName() == furnace stoker then...
	thisEntity:SetContextThink( "ActivateFurnace", function() return FurnaceActivated() end, 0 )

end
------------------------------------------------------------------------------------------------------

function FurnaceActivated()

	if not IsServer() then
		return
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil,
		500,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false )

	if enemies ~= nil or #enemies ~= 0 then
		for _,enemy in pairs(enemies) do

			-- TODO
			-- create a flag that some trigger is activated and exit  loop once it is activate (have a timer so the unit has to be inside it for x duration before activaing )
			-- if clock remove invul modifier (POC this... cause it needs to readd.. could readd/refresh when hook shot? notsure tbh)
			-- if furnance driod actiavet etc..
			-- if player then just dmg them / do nothing if not acticated 

			-- if enemy is clock do or adds
			if enemy:GetUnitName() == "npc_dota_hero_templar_assassin" then
				--print("trying to spawn ")
				--print("orgin ent ",thisEntity:GetAbsOrigin())
				local particle_cast2 = "particles/clock/clock_hero_snapfire_ultimate_linger.vpcf"
				local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_WORLDORIGIN, nil )
				ParticleManager:SetParticleControl( effect_cast, 0, thisEntity:GetAbsOrigin() )
				ParticleManager:SetParticleControl( effect_cast, 2, Vector(10,0,0) )
				ParticleManager:SetParticleControl( effect_cast, 1, thisEntity:GetAbsOrigin() )
				ParticleManager:ReleaseParticleIndex( effect_cast )
			end

			-- else do this (damage ticks)
			--print("unit name ",enemy:GetUnitName())
			--print("entity name ",thisEntity:GetName())
		end
	end

	return 0.5

end