tinker_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

	CreateUnitByName( "npc_crystal", Vector(-10673,11950,0), true, thisEntity, thisEntity, DOTA_TEAM_BADGUYS)

	-- elemental buff phase timer -- summon timer
	thisEntity.ice_phase = true
	thisEntity.fire_phase = false
	thisEntity.light_phase = false
	ElementalPhaseTimer()

    thisEntity:SetContextThink( "TinkerThinker", TinkerThinker, 0.1 )

end
--------------------------------------------------------------------------------

function TinkerThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	--[[print("thisEntity.ice_phase ",thisEntity.ice_phase)
	print("thisEntity.fire_phase ",thisEntity.fire_phase)
	print("thisEntity.light_phase ",thisEntity.light_phase)
	print("------------------------ ")]]



	return 0.5
end
--------------------------------------------------------------------------------

function ElementalPhaseTimer()
	local i = 1
	Timers:CreateTimer(5,function()
		if ( not thisEntity:IsAlive() ) then
			print("end timer?")
			return false
		end

		print("this running?")
		if i > 3 then
			i = 1
		end

		if i == 1 then
			thisEntity.ice_phase = true
			thisEntity.fire_phase = false
			thisEntity.light_phase = false
		elseif i == 2 then
			thisEntity.ice_phase = false
			thisEntity.fire_phase = true
			thisEntity.light_phase = false
		elseif i == 3 then
			thisEntity.ice_phase = false
			thisEntity.fire_phase = false
			thisEntity.light_phase = true
		end

		i = i + 1

		return 5
	end)
end
--------------------------------------------------------------------------------
