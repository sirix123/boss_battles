-- Test. 
beastmaster_mark = class({})
LinkLuaModifier("beastmaster_mark_modifier", "bosses/beastmaster/beastmaster_mark_modifier", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function beastmaster_mark:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function beastmaster_mark:OnSpellStart()
	if IsServer() then

		EmitSoundOn( "beastmaster_beas_ability_callwild_04", self:GetCaster() )

		-- get duration
		self.duration = self:GetSpecialValueFor("duration")

		-- gets target for ability
		local markTarget = self:GetCursorTarget()
 		if markTarget == nil then
 			return
 		end

		-- adds mark to target
		markTarget:AddNewModifier( self:GetCaster(), self, "beastmaster_mark_modifier", { duration = self.duration } )
	end
end
