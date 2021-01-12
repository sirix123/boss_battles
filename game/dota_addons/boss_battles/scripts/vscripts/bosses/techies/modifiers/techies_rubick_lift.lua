techies_rubick_lift = class({})

--------------------------------------------------------------------------------
-- Classifications
function techies_rubick_lift:IsHidden()
	return true
end

function techies_rubick_lift:IsDebuff()
	return true
end

function techies_rubick_lift:IsPurgable()
	return false
end

function techies_rubick_lift:RemoveOnDeath()
	return true
end

function techies_rubick_lift:IsMotionController()
    return true
end

function techies_rubick_lift:GetMotionControllerPriority()
    return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM
end

--------------------------------------------------------------------------------
-- Initializations
function techies_rubick_lift:OnCreated( kv )
    if not IsServer() then return end

    self.tele_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_rubick/rubick_telekinesis.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.tele_pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.tele_pfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(self.tele_pfx, 2, Vector(999,0,0))
    self:GetParent():EmitSound("Hero_Rubick.Telekinesis.Cast")
    self:GetParent():EmitSound("Hero_Rubick.Telekinesis.Target")

    self.z_height = 0

    self.frametime = FrameTime()

    self.duration = self:GetRemainingTime()

    self:StartIntervalThink(FrameTime())

end

function techies_rubick_lift:OnRefresh( kv )
	if not IsServer() then return end

end

function techies_rubick_lift:OnRemoved()
	if not IsServer() then return end

end

function techies_rubick_lift:OnDestroy()
    if not IsServer() then return end

	ParticleManager:DestroyParticle(self.tele_pfx,false)
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetGroundPosition(self:GetParent():GetAbsOrigin(),nil), true)

end
--------------------------------------------------------------------------------

function techies_rubick_lift:OnIntervalThink()
    if not IsServer() then return end

	self:VerticalMotion(self:GetParent(), self.frametime)

    --self:GetParent():SetUnitOnClearGround()

end

--------------------------------------------------------------------------------

function techies_rubick_lift:VerticalMotion(unit, dt)
	if IsServer() then

		local max_height = 250
		if max_height < self.z_height then
			self.z_height = self.z_height + ((dt / 0.2) * max_height)
			unit:SetAbsOrigin(GetGroundPosition(unit:GetAbsOrigin(), unit) + Vector(0,0,self.z_height))
		else
			return 999
		end

	end
end