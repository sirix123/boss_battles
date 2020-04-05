
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

		self:Effects(self:GetCaster())
		EmitSoundOn( "sounds/weapons/hero/ogre_magi/bloodlust_target.vsnd", self:GetCaster() )
	end
end

---------------------------------------------------------------------------

function bear_bloodlust:Effects(hTarget)
	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
end
