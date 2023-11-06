m2_qop_direct_heal = class({})
LinkLuaModifier("ally_buff_heal", "player/queenofpain/modifiers/ally_buff_heal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("m2_qop_stacks", "player/queenofpain/modifiers/m2_qop_stacks", LUA_MODIFIER_MOTION_NONE)

function m2_qop_direct_heal:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function m2_qop_direct_heal:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end

---------------------------------------------------------------------------

function m2_qop_direct_heal:GetManaCost(level)
	local caster = self:GetCaster()
	local modifier = "m2_qop_stacks"
	local base_mana_cost = self.BaseClass.GetManaCost(self, level)

	local stacks = 0
	if caster:HasModifier(modifier) then
		stacks = caster:GetModifierStackCount(modifier, caster)
	end

	local mana_cost = base_mana_cost

    if stacks == 1 then
        mana_cost = mana_cost * 2
    elseif stacks == 2 then
        mana_cost = mana_cost * 4
    elseif stacks == 3 then
        mana_cost = mana_cost * 8
    end

	return mana_cost
end
---------------------------------------------------------------------------

function m2_qop_direct_heal:OnSpellStart()
    if IsServer() then

        -- init
        self.caster = self:GetCaster()

        local duration_buff = self:GetSpecialValueFor( "duration_main_buff" )
        local duration_debuff = self:GetSpecialValueFor( "duration_debuff" )
        local base_heal = self:GetSpecialValueFor( "base_heal" )

        -- heal calc
        local heal_amount = base_heal

        if self.caster:HasModifier("m2_stacks") then
            if self.caster:FindModifierByName("m2_stacks"):GetStackCount() == 2 then
                heal_amount = base_heal * 2
            elseif self.caster:FindModifierByName("m2_stacks"):GetStackCount() == 3 then
                heal_amount = base_heal * 4
            end
        end

        self:GetCursorTarget():Heal(heal_amount, self.caster)

        self:GetCursorTarget():AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "ally_buff_heal", -- modifier name
            { duration = duration_buff } -- kv
        )

        self.caster:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "m2_qop_stacks", -- modifier name
            { duration = duration_debuff } -- kv
        )

        if self.caster.arcana_equipped == true then
            local particle = "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_blink_end.vpcf"
            local particle_aoe_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetCursorTarget())
            ParticleManager:SetParticleControl(particle_aoe_fx, 0, self:GetCursorTarget():GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle_aoe_fx)
        else
            -- local particle
            local particle_aoe = "particles/qop/qop_omniknight_purification.vpcf"
            local particle_aoe_fx = ParticleManager:CreateParticle(particle_aoe, PATTACH_ABSORIGIN_FOLLOW, self:GetCursorTarget())
            ParticleManager:SetParticleControl(particle_aoe_fx, 0, self:GetCursorTarget():GetAbsOrigin())
            ParticleManager:SetParticleControl(particle_aoe_fx, 1, Vector(80, 1, 1))
            ParticleManager:ReleaseParticleIndex(particle_aoe_fx)
        end



        -- sound
        EmitSoundOnLocationWithCaster(self:GetCursorTarget():GetAbsOrigin(), "Hero_QueenOfPain.Blink_in", self.caster)

	end
end
----------------------------------------------------------------------------------------------------------------
