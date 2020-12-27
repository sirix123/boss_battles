
electric_turret_ai = class({})

LinkLuaModifier("electric_turret_effect_modifier", "bosses/clock/modifiers/electric_turret_effect_modifier", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then return end

	thisEntity:AddNewModifier( thisEntity, thisEntity, "electric_turret_effect_modifier", { duration = -1,} )

    thisEntity.summon_furnace_droid = thisEntity:FindAbilityByName( "summon_furnace_droid" )
	thisEntity.summon_furnace_droid:StartCooldown(5)

	thisEntity:StartGestureWithPlaybackRate(ACT_DOTA_IDLE, 1.0)

	local particle = "particles/econ/items/ursa/ursa_ti10/ursa_ti10_enrage_head_flames.vpcf"
	thisEntity.nfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, thisEntity)
	ParticleManager:SetParticleControl(thisEntity.nfx, 3, thisEntity:GetAbsOrigin() )

	thisEntity:SetContextThink( "ElectricTurretThinker", ElectricTurretThinker, 3 )

end
--------------------------------------------------------------------------------

function ElectricTurretThinker()
	if not IsServer() then return end

	if ( not thisEntity:IsAlive() ) then
		ParticleManager:DestroyParticle(thisEntity.nfx, true)
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
    end

    if thisEntity.summon_furnace_droid:IsFullyCastable() and thisEntity.summon_furnace_droid:IsCooldownReady() then
		return CastSummonFurnaceDroid()
	end

	return 0.5
end

--------------------------------------------------------------------------------

function CastSummonFurnaceDroid()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.summon_furnace_droid:entindex(),
		Queue = 0,
	})
	return 0.5
end
--------------------------------------------------------------------------------
