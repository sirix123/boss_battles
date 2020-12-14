npc_rock_techies_ai = class({})
--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )

	--thisEntity:SetHullRadius(80)

    thisEntity:SetContextThink( "RockThinker", RockThinker, 0.5 )

end
--------------------------------------------------------------------------------

function RockThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	return 0.5
end

