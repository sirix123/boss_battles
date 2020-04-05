modifier_beastmaster_net_dot = class({})

------------------------------------------------------------------
function modifier_beastmaster_net_dot:IsHidden()
	return false
end

-----------------------------------------------------------------------------
function modifier_beastmaster_net_dot:IsDebuff()
	return true
end

---------------------------------------------------------------------
function modifier_beastmaster_net_dot:OnCreated( kv )
	self.dmgBear = self:GetAbility():GetSpecialValueFor( "damage_bear" )
    self.interval = 0.5

    if IsServer() then
        self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.dmgBear ,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self, --Optional.
		}

		self:StartIntervalThink( self.interval )
		self:OnIntervalThink()

		self.sound_target = "hero_Crystal.frostbite"
		EmitSoundOn( self.sound_target, self:GetParent() )
	end
end

---------------------------------------------------------------------
function modifier_beastmaster_net_dot:OnRefresh( kv )
    self.dmgBear = self:GetAbility():GetSpecialValueFor( "damage_bear" )
	self.interval = 0.5

	if IsServer() then
		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.dmgBear ,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
			ability = self, --Optional.
		}

		self:StartIntervalThink( self.interval )
		self:OnIntervalThink()

		self.sound_target = "hero_Crystal.frostbite"
		EmitSoundOn( self.sound_target, self:GetParent() )
	end
end

---------------------------------------------------------------------
function modifier_beastmaster_net_dot:OnIntervalThink()
    ApplyDamage( self.damageTable )
end

--------------------------------------------------------------------------------
function modifier_beastmaster_net_dot:GetEffectName()
	return "particles/econ/items/batrider/batrider_ti8_immortal_mount/batrider_ti8_immortal_firefly.vpcf"
end

-----------------------------------------------------------------------------
function modifier_beastmaster_net_dot:GetStatusEffectName()
	return "particles/econ/items/batrider/batrider_ti8_immortal_mount/batrider_ti8_immortal_firefly.vpcf"
end


