whirlwind_burn_modifier = class({})


-----------------------------------------------------------------------------
-- Classifications
function whirlwind_burn_modifier:IsHidden()
	return false
end

function whirlwind_burn_modifier:IsDebuff()
	return true
end

function whirlwind_burn_modifier:IsStunDebuff()
	return false
end

function whirlwind_burn_modifier:IsPurgable()
	return false
end


-----------------------------------------------------------------------------
-- debuff effect on npc
-- these probably need to be like... stack count above the hero and... 'mob starts getting incased in ice?'
function whirlwind_burn_modifier:GetEffectName()
	--print("whirlwind_burn_modifier:GetEffectName()")
	--return "particles/units/heroes/hero_grimstroke/grimstroke_phantom_marker.vpcf"--"particles/items4_fx/nullifier_mute_debuff.vpcf"--"particles/units/heroes/hero_arc_warden/arc_warden_flux_tgt.vpcf"
end

function whirlwind_burn_modifier:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function whirlwind_burn_modifier:GetStatusEffectName()
	return
end


-----
function whirlwind_burn_modifier:OnCreated(kv)
	if IsServer() then
		self:IncrementStackCount()
	    self.parent = self:GetParent() -- parent is the unit the modifier is on. 
	    self.caster = self:GetCaster()
	    -- read these values from parent kv files; whirlwind and whirlwind_attack
	    self.duration = self:GetCaster():FindAbilityByName( "whirlwind" ):GetSpecialValueFor("burn_duration")
	    self.dps = self:GetCaster():FindAbilityByName( "whirlwind" ):GetSpecialValueFor("burn_dps")
	    self.interval = self:GetCaster():FindAbilityByName( "whirlwind" ):GetSpecialValueFor("burn_damage_interval")
		self:PlayEffects()
		self:StartIntervalThink(self.interval)
	end
end

--------------------------------------------------------------------------------

--each tick, apply dmg to self:GetParent() and then check if any nearby units, to spread to. 
function whirlwind_burn_modifier:OnIntervalThink()
	--print("OnIntervalThink()")
	local stacks = self:GetStackCount()
	if stacks == 0 then
		self:Destroy()
	end

	local baseDmgPerTick = self.dps * self.interval
	local dmgPerTick = baseDmgPerTick * stacks
	if IsServer() then
		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = dmgPerTick,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			ability = self,
		}
		ApplyDamage( self.damageTable )

		--TODO: check if any units nearby to spread fire too


		--Clean up when all players are dead
		local areAllHeroesDead = true --start on true, then set to false if you find one hero alive.
		local heroes = HERO_LIST--HeroList:GetAllHeroes()
		for _, hero in pairs(heroes) do
			if hero.playerLives > 0 then
				areAllHeroesDead = false
				break
			end
		end
		if areAllHeroesDead then
			--print("all heroes are dead. cleaning up whirlwindburn")
			self:Destroy()
		end
	end
end

function whirlwind_burn_modifier:PlayEffects()
	--TODO: play some sort of burning/fire effect on the target
end

function whirlwind_burn_modifier:OnDestroy( )
	if IsServer() then
		self:StartIntervalThink(-1)
		--TODO any other cleanup needed?
	end
end

