bear_charge_pushback_modifier = bear_charge_pushback_modifier or class({})

function bear_charge_pushback_modifier:IsDebuff() return false end
function bear_charge_pushback_modifier:IsHidden() return false end
function bear_charge_pushback_modifier:IsStunDebuff() return true end
function bear_charge_pushback_modifier:IsMotionController()  return true end
function bear_charge_pushback_modifier:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function bear_charge_pushback_modifier:OnCreated()
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

	self.distance =  500 --/ ( self:GetDuration() / FrameTime()) --self:GetAbility():GetSpecialValueFor("push_length")
end

function bear_charge_pushback_modifier:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
end

function bear_charge_pushback_modifier:OnIntervalThink()

	self:HorizontalMotion(self:GetParent(), FrameTime())
end

function bear_charge_pushback_modifier:HorizontalMotion(unit, time)
	if not IsServer() then return end


	local distance = (unit:GetOrigin() - self.angle):Normalized()
	unit:SetOrigin( unit:GetOrigin() + distance * 800 * time )

end
