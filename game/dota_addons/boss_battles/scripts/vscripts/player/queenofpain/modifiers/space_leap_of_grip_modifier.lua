space_leap_of_grip_modifier = class({})

function space_leap_of_grip_modifier:IsHidden()
	return true
end

function space_leap_of_grip_modifier:IsDebuff()
	return false
end

function space_leap_of_grip_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
function space_leap_of_grip_modifier:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
	}
	return funcs
end

function space_leap_of_grip_modifier:GetOverrideAnimation()
	return ACT_DOTA_OVERRIDE_ABILITY_4
end
function space_leap_of_grip_modifier:GetOverrideAnimationRate()
	return 1.0
end

function space_leap_of_grip_modifier:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

---------------------------------------------------------------------------

function space_leap_of_grip_modifier:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        self.duration = kv.duration
        self.target = self.caster:GetAbsOrigin()
        self.speed = kv.speed

        self.distance = (self.target - self.parent:GetAbsOrigin()):Normalized()

        if self:ApplyHorizontalMotionController() == false then
            self:Destroy()
        end

	end
end
---------------------------------------------------------------------------

function space_leap_of_grip_modifier:UpdateHorizontalMotion(me, dt)
    if IsServer() then

        self.distance	= (self.target  - self.parent:GetAbsOrigin()):Normalized()

        me:SetOrigin( me:GetAbsOrigin() + self.distance * self.speed * dt )

        if (self.parent:GetAbsOrigin() - self.target ):Length2D() <= 50 then
            FindClearSpaceForUnit(self:GetParent(), self.target - self.distance * (self:GetParent():GetHullRadius()), true)
            self:Destroy()
        end

    end
end
---------------------------------------------------------------------------

function space_leap_of_grip_modifier:OnDestroy( kv )
    if IsServer() then

        --[[if self.caster:HasModifier("r_whirlwind_modifier") == false then
            self.caster:FindAbilityByName("m1_sword_slash"):SetActivated(true)
            self.caster:FindAbilityByName("m2_sword_slam"):SetActivated(true)
            self.caster:FindAbilityByName("q_conq_shout"):SetActivated(true)
            self.caster:FindAbilityByName("e_warlord_shout"):SetActivated(true)
            self.caster:FindAbilityByName("r_blade_vortex"):SetActivated(true)
            self.caster:FindAbilityByName("space_chain_hook"):SetActivated(true)
        end]]

        self:GetParent():RemoveHorizontalMotionController( self )
	end
end
---------------------------------------------------------------------------

function space_leap_of_grip_modifier:OnHorizontalMotionInterrupted()
	self:Destroy()
end
---------------------------------------------------------------------------