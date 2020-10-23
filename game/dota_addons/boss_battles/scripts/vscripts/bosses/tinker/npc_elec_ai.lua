npc_elec_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
	if thisEntity == nil then return end

	thisEntity.approach_target = nil
	thisEntity.target = nil

    thisEntity:SetContextThink( "ElecThinker", ElecThinker, 0.1 )

end
--------------------------------------------------------------------------------

function ElecThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	if thisEntity.target == nil then
		return FindEnemy()
	end

	if thisEntity.approach_target == nil then
		return ApproachTarget()
	end

	return 0.5
end

function FindEnemy()
	local enemies = FindUnitsInRadius(
        thisEntity:GetTeamNumber(),
        thisEntity:GetAbsOrigin(),
        nil,
        3000,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )

	if #enemies == 0 or enemies == nil then
		return 0.5
	end

	thisEntity.target = enemies[RandomInt(1,#enemies)]

	return 1
end

function ApproachTarget()

	thisEntity.approach_target = thisEntity.target
	thisEntity:MoveToPosition(unit:GetOrigin())

	return 1
end
