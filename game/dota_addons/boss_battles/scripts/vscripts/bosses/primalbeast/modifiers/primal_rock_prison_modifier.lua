primal_rock_prison_modifier = class({})

--------------------------------------------------------------------------------
-- Classifications
function primal_rock_prison_modifier:IsHidden()
	return false
end

function primal_rock_prison_modifier:IsDebuff()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function primal_rock_prison_modifier:OnCreated( kv )
	if not IsServer() then return end

	self.caster = self:GetCaster()
	self.parent = self:GetParent()

	self.radius = kv.radius

	self:PlayEffects()
	self:SpawnRockRing()
end

function primal_rock_prison_modifier:OnIntervalThink()
    if not IsServer() then return end

end

function primal_rock_prison_modifier:OnDestroy()
	if not IsServer() then return end

	for _, rock in pairs(self.tRocks) do
		if rock:IsNull() == false then
			rock:RemoveSelf()
		end
	end

end


function primal_rock_prison_modifier:PlayEffects()
	self.sound_cast = "Hero_EarthShaker.Gravelmaw.Cast"
	EmitSoundOn(self.sound_cast, self.parent)

end

function primal_rock_prison_modifier:SpawnRockRing()

	local nRocks = 25 --self:GetSpecialValueFor( "nCogs" )
	local vRockSpawn = GetGroundPosition(self.parent:GetAbsOrigin() + Vector(0, self.radius, 0), nil)
	self.tRocks = {}

	for i = 1, nRocks do

		-- create cog
		local rock = CreateUnitByName("npc_rock_primal", vRockSpawn, true, self.caster, self.caster, self.caster:GetTeamNumber())
		-- local randomVector = Vector( RandomInt(-1,1), RandomInt(-1,1), 0)
		-- rock:SetForwardVector(randomVector)


		local explosion_particle = "particles/units/heroes/hero_ursa/ursa_dust_hit.vpcf"
		local particle = ParticleManager:CreateParticle(explosion_particle, PATTACH_WORLDORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(particle, 0, vRockSpawn)

		-- set cog hull radius
		rock:SetHullRadius(80)

		-- rotate cog vector to spawn next one
		vRockSpawn = RotatePosition(self.parent:GetAbsOrigin(), QAngle(0, 360 / nRocks, 0), vRockSpawn)

		-- insert cogs into a table to use them later
		table.insert(self.tRocks,rock)

	end

end