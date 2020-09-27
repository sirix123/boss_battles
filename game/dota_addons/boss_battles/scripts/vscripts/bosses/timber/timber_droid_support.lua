timber_droid_support = class({})
LinkLuaModifier( "timber_droid_support_thinker", "bosses/timber/timber_droid_support_thinker", LUA_MODIFIER_MOTION_NONE )

function timber_droid_support:OnSpellStart()

	-- number of cast locations per cast, level up every phase?
	self.droidsPerLocation = self:GetSpecialValueFor( "droidsPerLocation" )
	--print("droids per loc: ",self.droidsPerLocation)
	-- init
	local caster = self:GetCaster()
	local delay = 0.2

	self.tDroids = {"npc_smelter_droid", "npc_stun_droid"}

	local i = 0
	Timers:CreateTimer(delay, function()
		--print("i ", i)
		--print("droidsPerLocation ", self.droidsPerLocation)
		if i == self.droidsPerLocation then
			return false
		end
		
		local vTargetPos = Vector(RandomInt(8622,11441),RandomInt(-11882,-8917),130)
		--DebugDrawCircle(vTargetPos,Vector(255,255,255),128,60,true,60)
		local particle_cast = "particles/units/heroes/hero_rattletrap/rattletrap_cog_deploy.vpcf"
		local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(effect_cast, 0, vTargetPos)
		ParticleManager:ReleaseParticleIndex(effect_cast)

		-- sound effect
		local sound_cast = "Hero_Rattletrap.Power_Cogs"
		EmitSoundOn(sound_cast,self:GetCaster())

		CreateUnitByName(self.tDroids[RandomInt(1,#self.tDroids)], vTargetPos, true, self:GetCaster(), self:GetCaster():GetOwner(), caster:GetTeamNumber())

		i = i  +  1
		return delay
	end)

	local sound_cast = "tinker_tink_ability_marchofthemachines_04"
	--sounds/vo/tinker/tink_rare_02.vsnd
	--sounds/vo/tinker/tink_cast_01.vsnd
	--sounds/vo/tinker/tink_cast_02.vsnd
	--sounds/vo/tinker/tink_ability_marchofthemachines_04.vsnd
	--sounds/vo/tinker/tink_ability_marchofthemachines_11.vsnd
	EmitSoundOn(sound_cast,self:GetCaster())

end