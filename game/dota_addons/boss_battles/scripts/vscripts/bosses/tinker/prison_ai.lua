prison_ai = class({})

LinkLuaModifier("prison_death_modifier", "bosses/tinker/modifiers/prison_death_modifier", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

    thisEntity:AddNewModifier( nil, nil, "prison_death_modifier", { duration = -1 } )

    thisEntity:SetContextThink( "PrisonThinker", PrisonThinker, 0.1 )

end
--------------------------------------------------------------------------------

function PrisonThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	thisEntity:StartGestureWithPlaybackRate(ACT_DOTA_IDLE, 1.0)

	return 5
end
