furnace_ai = class({})
LinkLuaModifier( "inside_furnace_modifier", "bosses/clock/modifiers/inside_furnace_modifier", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then return end

	thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )
	--MODIFIER_STATE_NO_UNIT_COLLISION
	--MODIFIER_STATE_OUT_OF_GAME

	thisEntity.radius = 300
	thisEntity.furnaceActivated = false

    thisEntity:SetContextThink( "ActivateFurnace", ActivateFurnace, 0.5 )

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

    local units = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil,
		thisEntity.radius,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
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

			-- count droids entering the furnace
			if unit:GetUnitName() == "furnace_droid" and unit:HasModifier("electric_turret_electric_charge_modifier") then
				furnaceDroidCounter = furnaceDroidCounter + 1
			end

			-- if 4 droids in furnace activate
			if furnaceDroidCounter >= 4 and thisEntity.furnaceActivated == false and unit:GetUnitName() == "furnace_droid" then
			--if unit:GetUnitName() == "npc_dota_hero_templar_assassin" and thisEntity.furnaceActivated == false then -- test code
				thisEntity.furnaceActivated = true
				--DebugDrawCircle(thisEntity:GetAbsOrigin(), Vector(0,0,255), 128, thisEntity.radius, true, 60)
				local particleName = "particles/clock/furnace_activate_jakiro_ti10_macropyre.vpcf"
				thisEntity.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, thisEntity )

				local forward = thisEntity:GetForwardVector()
				ParticleManager:SetParticleControl( thisEntity.pfx, 0, thisEntity:GetAbsOrigin() - forward * thisEntity.radius)
				ParticleManager:SetParticleControl( thisEntity.pfx, 1, thisEntity:GetAbsOrigin() )
				ParticleManager:SetParticleControl( thisEntity.pfx, 2, Vector( 5, 0, 0 ) )
				ParticleManager:SetParticleControl( thisEntity.pfx, 3, thisEntity:GetAbsOrigin() + forward * thisEntity.radius)

				-- sound effect
				thisEntity:EmitSound("Hero_OgreMagi.Fireblast.Target")
			end

			-- if furance droids enter an activated furnace they die
			if thisEntity.furnaceActivated == true and unit:GetUnitName() == "furnace_droid" then
				-- furance droid kills
				unit:ForceKill(false)
			elseif thisEntity.furnaceActivated == true and unit:GetUnitName() == "npc_clock" then
				unit:AddNewModifier(thisEntity, nil, "inside_furnace_modifier", {duration = 2})
			end

			-- if furnace is activated apply modifier, clock AI checks for this modifier to detect furnaces that are active
			if thisEntity.furnaceActivated == true then
				thisEntity:AddNewModifier(thisEntity, nil, "inside_furnace_modifier", {duration = 2})
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