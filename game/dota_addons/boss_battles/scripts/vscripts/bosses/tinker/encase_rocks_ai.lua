encase_rocks_ai = class({})

LinkLuaModifier("encaserocks_death_modifier", "bosses/tinker/modifiers/encaserocks_death_modifier", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity:AddNewModifier( nil, nil, "encaserocks_death_modifier", { duration = -1 } )

    thisEntity:SetContextThink( "EncaseRocksThinker", EncaseRocksThinker, 0.1 )

end
--------------------------------------------------------------------------------

function EncaseRocksThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	return 0.5
end
