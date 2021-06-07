assistant_enchant_totem = class({})

--------------------------------------------------------------------------------
-- Classifications
function assistant_enchant_totem:IsHidden()
	return false
end

function assistant_enchant_totem:IsDebuff()
	return false
end

function assistant_enchant_totem:IsPurgable()
	return true
end

--[[function assistant_enchant_totem:GetOverrideAnimation()
	return ACT_DOTA_EARTHSHAKER_TOTEM_ATTACK
end]]

--------------------------------------------------------------------------------
-- Initializations
function assistant_enchant_totem:OnCreated( kv )
	-- references
	self.bonus = 750
	self.range = 200 -- special value
	if IsServer() then
		self:PlayEffects()
	end
end

function assistant_enchant_totem:OnRefresh( kv )
	-- references
	self.bonus = 750
	self.range = 200 -- special value
end

function assistant_enchant_totem:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function assistant_enchant_totem:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        --MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}

	return funcs
end

function assistant_enchant_totem:GetActivityTranslationModifiers()
	return "enchant_totem"
end

-- disabled
function assistant_enchant_totem:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end

function assistant_enchant_totem:GetModifierBaseDamageOutgoing_Percentage()
	return self.bonus
end

function assistant_enchant_totem:GetModifierProcAttack_Feedback( params )
	if IsServer() then
		-- effects
		local sound_cast = "Hero_EarthShaker.Totem.Attack"
		EmitSoundOn( sound_cast, params.target )

		self:Destroy()
	end
end

function assistant_enchant_totem:GetModifierAttackRangeBonus()
	return self.range
end

--------------------------------------------------------------------------------
-- Status Effects
function assistant_enchant_totem:CheckState()
	local state = {
		[MODIFIER_STATE_CANNOT_MISS] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function assistant_enchant_totem:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/techies/bigger_earthshaker_totem_buff.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self:GetParent() )

	local attach = "attach_attack1"
	if self:GetCaster():ScriptLookupAttachment( "attach_totem" )~=0 then attach = "attach_totem" end
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		attach,
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	-- buff particle
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)


	local effect_cast = ParticleManager:CreateParticle( self:GetParent().enchant_totem_cast_pfx or "particles/units/heroes/hero_earthshaker/earthshaker_totem_cast.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:ReleaseParticleIndex(effect_cast)
end