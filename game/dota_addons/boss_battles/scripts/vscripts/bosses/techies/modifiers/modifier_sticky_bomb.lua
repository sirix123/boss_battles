modifier_sticky_bomb = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_sticky_bomb:IsHidden()
	return false
end

function modifier_sticky_bomb:IsDebuff()
	return true
end

function modifier_sticky_bomb:IsStunDebuff()
	return false
end

function modifier_sticky_bomb:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_sticky_bomb:OnCreated( kv )
	if not IsServer() then return end

	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	-- precache damage
	self.damage = self.damage
	self.damageTable = {
		attacker = self:GetCaster(),
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(),
	}

end

function modifier_sticky_bomb:OnRefresh( kv )
	if not IsServer() then return end

end

function modifier_sticky_bomb:OnRemoved()
	if not IsServer() then return end

end

function modifier_sticky_bomb:OnDestroy()
	if not IsServer() then return end

	-- explode dealing damage, divided by number of enemies
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		self:GetParent():GetAbsOrigin(),
		nil,
		self.radius,	
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		self.damageTable.damage = self.damage/#enemies
		ApplyDamage( self.damageTable )
	end

end
--------------------------------------------------------------------------------

function modifier_sticky_bomb:GetEffectName()
	return "particles/techies/techies_remote_gyro_guided_missile_target.vpcf"
end

function modifier_sticky_bomb:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end