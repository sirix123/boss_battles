m2_qop_direct_heal = class({})
LinkLuaModifier("ally_buff_heal", "player/queenofpain/modifiers/ally_buff_heal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("m2_qop_stacks", "player/queenofpain/modifiers/m2_qop_stacks", LUA_MODIFIER_MOTION_NONE)

function m2_qop_direct_heal:OnAbilityPhaseStart()
    if IsServer() then

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            Clamp(self:GetCaster():GetOrigin(), Vector(self:GetCaster().mouse.x, self:GetCaster().mouse.y, self:GetCaster().mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0),
            nil,
            200,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_CLOSEST,
            false)

        if units == nil or #units == 0 then
            --FireGameEvent("dota_hud_error_message", { reason = 80, message = "Out of range or no target" })
            return false
        else

            self.target = units[1]

            self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.0)

            local particle_cast = "particles/units/heroes/hero_omniknight/omniknight_purification_cast.vpcf"
            local particle_cast_fx = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
            ParticleManager:SetParticleControlEnt(particle_cast_fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
            ParticleManager:SetParticleControl(particle_cast_fx, 1, self.target:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle_cast_fx)

            return true
        end
    end
end
---------------------------------------------------------------------------

function m2_qop_direct_heal:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

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

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

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

        self.target:Heal(heal_amount, self.caster)

        self.target:AddNewModifier(
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

        -- local particle
        local particle_aoe = "particles/qop/qop_omniknight_purification.vpcf"
        local particle_aoe_fx = ParticleManager:CreateParticle(particle_aoe, PATTACH_ABSORIGIN_FOLLOW, self.target)
        ParticleManager:SetParticleControl(particle_aoe_fx, 0, self.target:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_aoe_fx, 1, Vector(80, 1, 1))
        ParticleManager:ReleaseParticleIndex(particle_aoe_fx)

        -- sound
        EmitSoundOnLocationWithCaster(self.target:GetAbsOrigin(), "Hero_QueenOfPain.Blink_in", self.caster)

	end
end
----------------------------------------------------------------------------------------------------------------
