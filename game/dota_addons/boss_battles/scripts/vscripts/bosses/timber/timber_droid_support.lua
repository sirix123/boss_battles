timber_droid_support = class({})
LinkLuaModifier( "timber_droid_support_thinker", "bosses/timber/timber_droid_support_thinker", LUA_MODIFIER_MOTION_NONE )

function timber_droid_support:OnSpellStart()

	-- number of cast locations per cast, level up every phase?
	self.numberLocations = self:GetSpecialValueFor( "numberLocations" )

	-- init
	local caster = self:GetCaster()
	local delay = 2

	self.tPositions = {}

	for i = 1, self.numberLocations, 1 do
		local vNewPositionX = RandomInt(6590, 10467)
		local vNewPositionY = RandomInt(11248, 15090)
		table.insert(self.tPositions, Vector(vNewPositionX, vNewPositionY, 255))
	end


	for i = 1, #self.tPositions, 1 do
		-- create modifier thinker
		CreateModifierThinker(
			caster,
			self,
			"timber_droid_support_thinker",
			{ duration = delay },
			self.tPositions[i],
			caster:GetTeamNumber(),
			false
		)
	end

	local sound_cast = "tinker_tink_ability_marchofthemachines_04"
	--sounds/vo/tinker/tink_rare_02.vsnd
	--sounds/vo/tinker/tink_cast_01.vsnd
	--sounds/vo/tinker/tink_cast_02.vsnd
	--sounds/vo/tinker/tink_ability_marchofthemachines_04.vsnd
	--sounds/vo/tinker/tink_ability_marchofthemachines_11.vsnd
	EmitSoundOn(sound_cast,self:GetCaster())

end