space_chain_hook_modifier = class({})

function space_chain_hook_modifier:IsHidden()
	return true
end

function space_chain_hook_modifier:IsDebuff()
	return false
end

function space_chain_hook_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
function space_chain_hook_modifier:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
	}
	return funcs
end

function space_chain_hook_modifier:GetOverrideAnimation()
	return ACT_DOTA_OVERRIDE_ABILITY_4
end
function space_chain_hook_modifier:GetOverrideAnimationRate()
	return 1.0
end
---------------------------------------------------------------------------

function space_chain_hook_modifier:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        self.duration = kv.duration
        self.location = Vector( kv.target_x, kv.target_y, kv.target_z )
        self.latch_radius = kv.latch_radius
        self.speed = kv.speed

        self.distance = (self.location - self:GetCaster():GetAbsOrigin()):Normalized()

        if self:ApplyHorizontalMotionController() == false then
            self:Destroy()
        end

	end
end
---------------------------------------------------------------------------

function space_chain_hook_modifier:UpdateHorizontalMotion(me, dt)
    if IsServer() then

        self.distance	= (self.location - self:GetCaster():GetAbsOrigin()):Normalized()

        me:SetOrigin( me:GetAbsOrigin() + self.distance * self.speed * dt )

        if (self:GetCaster():GetAbsOrigin() - self.location):Length2D() <= self.latch_radius then
            FindClearSpaceForUnit(self:GetParent(), self.location - self.distance * (self:GetParent():GetHullRadius()), true)
            self:Destroy()
        end

    end
end
---------------------------------------------------------------------------

function space_chain_hook_modifier:OnDestroy( kv )
    if IsServer() then

        self:GetParent():RemoveHorizontalMotionController( self )
        self:GetCaster():EmitSound("Hero_Pudge.AttackHookImpact")
        self:GetCaster():StopSound("Hero_Pudge.AttackHookRetract")

	end
end
---------------------------------------------------------------------------

function space_chain_hook_modifier:OnHorizontalMotionInterrupted()
	self:Destroy()
end
---------------------------------------------------------------------------