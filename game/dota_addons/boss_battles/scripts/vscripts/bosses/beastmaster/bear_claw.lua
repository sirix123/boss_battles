
bear_claw = class({})
LinkLuaModifier("bear_claw_modifier", "bosses/beastmaster/bear_claw_modifier", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function bear_claw:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function bear_claw:OnSpellStart()
	if IsServer() then
		--print("bear has started casting claw")

		-- get bear claw ability stats from npc abilities custom text file
		self.base_damage = self:GetSpecialValueFor("base_damage")
		self.slow_percent = self:GetSpecialValueFor("slow_percent")
		self.slow_duration = self:GetSpecialValueFor("slow_duration")

		-- gets target for ability
		local aggroTarget = self:GetCursorTarget()
		--print("bear has aqquired claw target")
 		if aggroTarget == nil then
 			--print("bear_claw could not get aggro target, getting first available")
 			return
 		end

		local damageInfo = 
		{
			victim = aggroTarget,
			attacker = self:GetCaster(),
			damage = self.base_damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self,
		}

		-- adds particle effect and sound
		ParticleManager:CreateParticle( "particles/econ/items/lifestealer/ls_ti9_immortal/ls_ti9_open_wounds_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, aggroTarget )
		--EmitSoundOn( "n_creep_Ursa.Clap", self:GetCaster() )

		-- applies claw dmg
		--print("bear_claw target_damage: " .. self.base_damage .. " slow_percent: " .. self.slow_percent)
		ApplyDamage( damageInfo )

		-- adds slows modifier to player that was hit by claw
		aggroTarget:AddNewModifier( self:GetCaster(), self, "bear_claw_modifier", { duration = self.slow_duration } )
		
	end
end
