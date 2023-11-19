q_arcane_cage = class({})
LinkLuaModifier("q_arcane_cage_modifier", "player/templar/modifiers/q_arcane_cage_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("q_arcane_cage_modifier_templar", "player/templar/modifiers/q_arcane_cage_modifier_templar", LUA_MODIFIER_MOTION_NONE)

function q_arcane_cage:OnAbilityPhaseStart()
    if IsServer() then

        self.hTarget = self:GetCursorTarget()

        -- init
        self.caster = self:GetCaster()

        -- if caster == target return
        if self.caster == self.hTarget then
            return false
        else
            return true
        end
    end
end
---------------------------------------------------------------------------

function q_arcane_cage:OnAbilityPhaseInterrupted()
    if IsServer() then

    end
end

---------------------------------------------------------------------------

function q_arcane_cage:OnSpellStart()
    if IsServer() then
        self.hTarget:AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "q_arcane_cage_modifier", -- modifier name
            {duration = self:GetSpecialValueFor( "duration" )} -- kv
        )

        self.caster:AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "q_arcane_cage_modifier_templar", -- modifier name
            {duration = self:GetSpecialValueFor( "duration" )} -- kv
        )

        -- sound
        EmitSoundOnLocationWithCaster(self.hTarget:GetAbsOrigin(), "Hero_Huskar.Inner_Fire.Cast", self.caster)

	end
end
----------------------------------------------------------------------------------------------------------------
