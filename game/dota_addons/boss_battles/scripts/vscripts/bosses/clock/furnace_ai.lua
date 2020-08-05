furnace_ai = class({})

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

	thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
	--MODIFIER_STATE_NO_UNIT_COLLISION
	--MODIFIER_STATE_OUT_OF_GAME

	thisEntity.radius = 150
	thisEntity.furnaceActivated = false

    thisEntity:SetContextThink( "ActivateFurnace", ActivateFurnace, 0.5 )

end
--------------------------------------------------------------------------------

function ActivateFurnace()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

    local units = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil,
		thisEntity.radius,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false )

	local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil,
		thisEntity.radius,
		DOTA_TEAM_GOODGUYS,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false )

	local furnaceDroidCounter = 0
	if units ~= nil or #units ~= 0 then
		for _,unit in pairs(units) do

			-- if 4 droids in furnace activate
			--if furnaceDroidCounter >= 4 and thisEntity.furnaceActivated == false and unit:GetUnitName() == "furnace_droid" then
			if unit:GetUnitName() == "npc_dota_hero_templar_assassin" and thisEntity.furnaceActivated == false then -- test code
				thisEntity.furnaceActivated = true

				local particleName = "particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre.vpcf"
				local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, thisEntity )

				local forward = thisEntity:GetForwardVector()
				ParticleManager:SetParticleControl( pfx, 0, thisEntity:GetAbsOrigin() - forward * thisEntity.radius)
				ParticleManager:SetParticleControl( pfx, 1, thisEntity:GetAbsOrigin() )
				ParticleManager:SetParticleControl( pfx, 2, Vector( 5, 0, 0 ) )
				ParticleManager:SetParticleControl( pfx, 3, thisEntity:GetAbsOrigin() + forward * thisEntity.radius)
			end

			-- count droids entering the furnace
			if unit:GetUnitName() == "furnace_droid" and unit:HasModifier("electric_turret_electric_charge_modifier") then
				furnaceDroidCounter = furnaceDroidCounter + 1
			end

			if thisEntity.furnaceActivated == true and unit:GetUnitName() == "furnace_droid" then
				-- furance droid kills
				unit:ForceKill(false)
			end

		end
	end

	if enemies ~= nil or #enemies ~= 0 then
		for _,player in pairs(enemies) do
			local dmgTable = {
                victim = player,
                attacker = thisEntity,
                damage = 1,
                damage_type = DAMAGE_TYPE_PHYSICAL,
            }

            ApplyDamage(dmgTable)
		end
	end


	return 0.5
end

--------------------------------------------------------------------------------