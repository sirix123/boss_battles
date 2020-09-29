modifier_beastmaster_net_dot_player = class({})

------------------------------------------------------------------
function modifier_beastmaster_net_dot_player:IsHidden()
	return false
end

-----------------------------------------------------------------------------
function modifier_beastmaster_net_dot_player:IsDebuff()
	return true
end

---------------------------------------------------------------------
function modifier_beastmaster_net_dot_player:OnCreated( kv )
	self.dmg = self:GetAbility():GetSpecialValueFor( "player_dot_damage" )
    self.interval = 0.5

    if IsServer() then
        self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.dmg ,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self, 
		}

		self:StartIntervalThink( self.interval )
		self:OnIntervalThink()

		self.sound_target = "hero_Crystal.frostbite"
		EmitSoundOn( self.sound_target, self:GetParent() )
	end
end

---------------------------------------------------------------------
function modifier_beastmaster_net_dot_player:OnRefresh( kv )
    self.dmg = self:GetAbility():GetSpecialValueFor( "player_dot_damage" )
	self.interval = 0.5

	if IsServer() then
		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.dmg ,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
			ability = self, 
		}

		self:StartIntervalThink( self.interval )
		self:OnIntervalThink()

		self.sound_target = "hero_Crystal.frostbite"
		EmitSoundOn( self.sound_target, self:GetParent() )
	end
end

---------------------------------------------------------------------
function modifier_beastmaster_net_dot_player:OnIntervalThink()
    ApplyDamage( self.damageTable )
end

--------------------------------------------------------------------------------
function modifier_beastmaster_net_dot_player:GetEffectName()
	return "particles/econ/items/batrider/batrider_ti8_immortal_mount/batrider_ti8_immortal_firefly.vpcf"
end

-----------------------------------------------------------------------------
function modifier_beastmaster_net_dot_player:GetStatusEffectName()
	return "particles/econ/items/batrider/batrider_ti8_immortal_mount/batrider_ti8_immortal_firefly.vpcf"
end


