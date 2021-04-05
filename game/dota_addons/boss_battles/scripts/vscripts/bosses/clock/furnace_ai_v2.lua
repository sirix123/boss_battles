furnace_ai_v2 = class({})
LinkLuaModifier( "inside_furnace_modifier", "bosses/clock/modifiers/inside_furnace_modifier", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

	thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
	thisEntity:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 } )
	--MODIFIER_STATE_NO_UNIT_COLLISION
	--MODIFIER_STATE_OUT_OF_GAME

	thisEntity.FURNACE_1 = false
	thisEntity.FURNACE_2 = false
	thisEntity.FURNACE_3 = false
	thisEntity.FURNACE_4 = false

	thisEntity.FURNACE_ACTIVATED_COUNT = 0

	thisEntity.last_time_furance_activated = 0

	thisEntity.cool_down_between_furnaces = 25

    thisEntity:SetContextThink( "ActivateFurnace", ActivateFurnace, 2 )

end
--------------------------------------------------------------------------------

function ActivateFurnace()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		--ParticleManager:DestroyParticle(thisEntity.pfx, true)
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	return 0.5
end

--------------------------------------------------------------------------------