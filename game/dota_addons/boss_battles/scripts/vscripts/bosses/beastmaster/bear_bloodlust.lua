
bear_bloodlust = class({})
LinkLuaModifier("bear_bloodlust_modifier", "bosses/beastmaster/bear_bloodlust_modifier", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function bear_bloodlust:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function bear_bloodlust:OnSpellStart()
	if IsServer() then
		-- adds modifier to bear that increases as and ms
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "bear_bloodlust_modifier", { duration = self:GetSpecialValueFor("duration") } )
		-- add stack
		local hBuff = self:GetCaster():FindModifierByName( "bear_bloodlust_modifier" )
		hBuff:IncrementStackCount()
	end
end

--------------------------------------------------------------------------------

