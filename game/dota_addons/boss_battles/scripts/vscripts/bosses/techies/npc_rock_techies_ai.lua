npc_rock_techies_ai = class({})
LinkLuaModifier( "green_cube_on_attacked", "bosses/techies/modifiers/green_cube_on_attacked", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity:AddNewModifier( nil, nil, "green_cube_on_attacked", { duration = -1 } )

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

