modifier_sticky_bomb_fire = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_sticky_bomb_fire:IsHidden()
	return false
end

function modifier_sticky_bomb_fire:IsDebuff()
	return true
end

function modifier_sticky_bomb_fire:IsStunDebuff()
	return false
end

function modifier_sticky_bomb_fire:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_sticky_bomb_fire:OnCreated( kv )
	if not IsServer() then return end

end

function modifier_sticky_bomb_fire:OnRefresh( kv )
	if not IsServer() then return end

end

function modifier_sticky_bomb_fire:OnRemoved()
	if not IsServer() then return end

end

function modifier_sticky_bomb_fire:OnDestroy()
	if not IsServer() then return end

	EmitSoundOn("Hero_Techies.RemoteMine.Detonate", self:GetParent())

	-- create a modiifer that creates a dot on player
	CreateModifierThinker(
        self:GetCaster(),
        self,
        "fire_bomb_ground_modifier",
        {
			duration = 20,
			x = self:GetParent():GetAbsOrigin().x,
			y = self:GetParent():GetAbsOrigin().y,
			z = self:GetParent():GetAbsOrigin().z,
			radius = self:GetAbility():GetSpecialValueFor( "radius"),
			dmg = self:GetAbility():GetSpecialValueFor( "dmg"),
        },
        self:GetParent():GetAbsOrigin(),
        self:GetCaster():GetTeamNumber(),
        false )

end
--------------------------------------------------------------------------------

function modifier_sticky_bomb_fire:GetEffectName()
	return "particles/techies/techies_fire_bomb__remote_gyro_guided_missile_target.vpcf"
end

function modifier_sticky_bomb_fire:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end