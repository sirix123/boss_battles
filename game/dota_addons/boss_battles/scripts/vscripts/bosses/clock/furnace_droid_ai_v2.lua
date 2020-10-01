
furnace_droid_ai_v2 = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end


    thisEntity:SetContextThink( "FurnaceDroidThink", FurnaceDroidThink, 0.5 )
end
--------------------------------------------------------------------------------

function FurnaceDroidThink()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
    end

	return 0.5
end

--------------------------------------------------------------------------------
