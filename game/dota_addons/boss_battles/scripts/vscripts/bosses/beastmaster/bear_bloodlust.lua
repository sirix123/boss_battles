
bear_bloodlust = class({})
LinkLuaModifier("bear_bloodlust_modifier", "bosses/beastmaster/bear_bloodlust_modifier", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function bear_bloodlust:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function bear_bloodlust:OnSpellStart()
	if IsServer() then

		local ms_bonus = self:GetSpecialValueFor( "bloodlust_speed" )
		local as_bonus = self:GetSpecialValueFor( "bloodlust_as_speed" )
		local damage_bonus = self:GetSpecialValueFor( "bloodlust_damage_bonus" )

		-- adds modifier to bear that increases as and ms
		-- add stack
		local stacks = 0
		if self:GetCaster():HasModifier("bear_bloodlust_modifier") then
			stacks = self:GetCaster():GetModifierStackCount("bear_bloodlust_modifier", self:GetCaster())
		end

		if stacks < 20 then
			self:GetCaster():AddNewModifier( self:GetCaster(), self, "bear_bloodlust_modifier", { duration = -1, ms_bonus = ms_bonus, as_bonus = as_bonus, damage_bonus = damage_bonus } )
			local hBuff = self:GetCaster():FindModifierByName( "bear_bloodlust_modifier" )
			hBuff:IncrementStackCount()
		else
			return
		end

		self:Effects(self:GetCaster())
		EmitSoundOn( "Hero_OgreMagi.Bloodlust.Target", self:GetCaster() )
	end
end

---------------------------------------------------------------------------

function bear_bloodlust:Effects(hTarget)
	local nFXIndex = ParticleManager:CreateParticle( "particles/beastmaster/bear_lust_ogre_magi_bloodlust_buff.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
end
