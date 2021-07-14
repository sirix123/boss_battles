rat_passive = class({})

LinkLuaModifier("rat_passive_modifier", "player/rat/modifier/rat_passive", LUA_MODIFIER_MOTION_NONE)

function rat_passive:GetIntrinsicModifierName()
	return "rat_passive_modifier"
end

rat_passive_modifier = class({})

LinkLuaModifier("rat_stacks", "player/rat/modifier/rat_stacks", LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

function rat_passive_modifier:IsHidden()
	return true
end

function rat_passive_modifier:OnCreated( params )
    if IsServer() then

        -- check if rat is moving and what buffs she has
        self:StartIntervalThink(FrameTime())

        self.has_stim_pack_buff = false

        -- gaining rat stacks
        Timers:CreateTimer(self:GetCaster():FindAbilityByName("rat_passive"):GetSpecialValueFor( "rat_stack_generate_time" ), function()

            if self:GetParent():HasModifier("stim_pack_debuff") == true then return self:GetCaster():FindAbilityByName("rat_passive"):GetSpecialValueFor( "rat_stack_generate_time" ) end
            if self:GetParent():HasModifier("stim_pack_buff") == true then return self:GetCaster():FindAbilityByName("rat_passive"):GetSpecialValueFor( "rat_stack_generate_time" ) end

            if self.rat_moving == false or self:GetParent():HasModifier("casting_modifier_thinker") == true or self:GetParent():HasModifier("burrow_modifier") == true then

                self:GetParent():AddNewModifier(
                    self:GetParent(), -- player source
                    self:GetAbility(), -- ability source
                    "rat_stacks", -- modifier name
                    { duration = -1 } -- kv
                )
            end

            return self:GetCaster():FindAbilityByName("rat_passive"):GetSpecialValueFor( "rat_stack_generate_time" )
        end)

        -- losing rat stacks while moving
        Timers:CreateTimer(self:GetCaster():FindAbilityByName("rat_passive"):GetSpecialValueFor( "rat_stack_generate_time" ) / 2 , function()

            if self:GetParent():HasModifier("stim_pack_debuff") == true then return self:GetCaster():FindAbilityByName("rat_passive"):GetSpecialValueFor( "rat_stack_generate_time" ) end
            if self:GetParent():HasModifier("stim_pack_buff") == true then return self:GetCaster():FindAbilityByName("rat_passive"):GetSpecialValueFor( "rat_stack_generate_time" ) end

            if self.rat_moving == true then
                if self:GetParent():HasModifier("rat_stacks") and self:GetParent():HasModifier("casting_modifier_thinker") == false then
                    self:GetParent():FindModifierByName("rat_stacks"):DecrementStackCount()
                end
            end

            return self:GetCaster():FindAbilityByName("rat_passive"):GetSpecialValueFor( "rat_stack_generate_time" ) / 2
        end)
    end
end

function rat_passive_modifier:OnIntervalThink()
    if not IsServer() then return end

    local parent = self:GetParent()

    if self:GetParent():HasModifier("stim_pack_buff") == true then
        self.rat_moving = false

        if self:GetParent():HasModifier("stim_pack_buff") == true and self.has_stim_pack_buff == false then

            self.has_stim_pack_buff = true

            local modifier = self:GetParent():AddNewModifier(
                self:GetParent(), -- player source
                self:GetAbility(), -- ability source
                "rat_stacks", -- modifier name
                { duration = -1 } -- kv
            )
            if modifier then
                modifier:SetStackCount(5)
            end
        end

        return
    end

    self.has_stim_pack_buff = false

    if self:GetParent():HasModifier("stim_pack_debuff") == true then
        self.rat_moving = false
        self:GetParent():RemoveModifierByName("rat_stacks")
        return
    end

	if parent.direction.x ~= 0 or parent.direction.y ~= 0 then
		if parent:IsStunned() or parent:IsCommandRestricted() or parent:IsRooted() then
            --print("rat is not moving")
            self.rat_moving = false
		else
            --print("rat is moving")
            self.rat_moving = true
		end
	else
        --print("rat is not moving")
        self.rat_moving = false
	end
end
