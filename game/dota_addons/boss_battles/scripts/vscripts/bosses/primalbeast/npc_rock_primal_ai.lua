npc_rock_primal_ai = class({})

function Spawn( entityKeyValues )

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	AddFOWViewer(DOTA_TEAM_GOODGUYS, thisEntity:GetAbsOrigin(), 8000, 9999, true)

	if SOLO_MODE == true then
        thisEntity:AddNewModifier( nil, nil, "SOLO_MODE_modifier", { duration = -1 } )
    end

	thisEntity:SetContextThink( "PrimalRockPrisonThink", PrimalRockPrisonThink, 0.1 )
end

function PrimalRockPrisonThink()

	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

    


	return 1
end
