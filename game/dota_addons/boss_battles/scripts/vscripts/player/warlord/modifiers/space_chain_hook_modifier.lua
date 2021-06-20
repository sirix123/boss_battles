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
	return 61--ACT_DOTA_FLAIL
end
function space_chain_hook_modifier:GetOverrideAnimationRate()
	return 1.0
end

function space_chain_hook_modifier:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}

	return state
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

        --if self.caster:HasModifier("r_whirlwind_modifier") == false then
            self.caster:FindAbilityByName("m1_sword_slash"):SetActivated(true)
            self.caster:FindAbilityByName("m2_sword_slam"):SetActivated(true)
            self.caster:FindAbilityByName("q_conq_shout"):SetActivated(true)
            self.caster:FindAbilityByName("e_warlord_shout"):SetActivated(true)
            self.caster:FindAbilityByName("r_blade_vortex"):SetActivated(true)
            self.caster:FindAbilityByName("space_chain_hook"):SetActivated(true)
        --end

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