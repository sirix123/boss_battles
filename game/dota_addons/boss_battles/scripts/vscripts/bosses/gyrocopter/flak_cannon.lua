flak_cannon = class({})
--flak cannon, same as vanilla?
-- This file really just applies the modifier, perhaps some other logic added later
function flak_cannon:OnSpellStart()
	-- print("flak_cannon:OnSpellStart()")
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor( "duration" )
	local stacks = self:GetSpecialValueFor( "stacks" )
	local radius = self:GetSpecialValueFor( "radius" )

	caster:AddNewModifier(caster, self, "flak_cannon_modifier", {duration = duration, stacks = stacks, radius = radius })
end