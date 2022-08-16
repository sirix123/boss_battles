primalbeast_baby_ai = class({})
LinkLuaModifier( "rock_golem_status", "bosses/primalbeast/modifiers/rock_golem_status", LUA_MODIFIER_MOTION_NONE )

function Spawn( entityKeyValues )

	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	-- general boss init
	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })
	thisEntity:SetHullRadius(80)

	AddFOWViewer(DOTA_TEAM_GOODGUYS, thisEntity:GetAbsOrigin(), 8000, 9999, true)

	if SOLO_MODE == true then
        thisEntity:AddNewModifier( nil, nil, "SOLO_MODE_modifier", { duration = -1 } )
    end

	-- add root explode modifier
	thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
	thisEntity:AddNewModifier( nil, nil, "rock_golem_status", { duration = -1 } )

	thisEntity:SetContextThink( "PrimalbeastBabyThink", PrimalbeastBabyThink, 0.1 )
end

function PrimalbeastThink()

	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

    -- find cloest target and run towards them


	return 3
end
