modifier_roar = modifier_roar or class({})

function modifier_roar:IsDebuff() return false end
function modifier_roar:IsHidden() return false end
function modifier_roar:IsStunDebuff() return true end
function modifier_roar:IsMotionController()  return true end
function modifier_roar:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_roar:OnCreated()
	if not IsServer() then return end

	local particle_name = "particles/items_fx/force_staff.vpcf"

	self.pfx = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	--self:GetParent():StartGesture(ACT_DOTA_FLAIL)
	self:StartIntervalThink(FrameTime())
	--self.angle = self:GetParent():GetForwardVector():Normalized()

	--regardless of parents angle send them x units away from the centre of the parent
	self.angle = self:GetCaster():GetAbsOrigin()
	self:GetParent():FaceTowards(self.angle * (-1))
	self:GetParent():SetForwardVector((self:GetParent():GetAbsOrigin() - self.angle):Normalized())

	self.distance =  110 --/ ( self:GetDuration() / FrameTime()) --self:GetAbility():GetSpecialValueFor("push_length")
end

function modifier_roar:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
end

function modifier_roar:OnIntervalThink()

	self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_roar:HorizontalMotion(unit, time)
	if not IsServer() then return end


	local distance = (unit:GetOrigin() - self.angle):Normalized()
	unit:SetOrigin( unit:GetOrigin() + distance * 800 * time )

end

function modifier_roar:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
-----------------------------------------------------------------------------

function modifier_roar:GetModifierMoveSpeedBonus_Percentage( params )
	return -70
end
--------------------------------------------------------------------------------