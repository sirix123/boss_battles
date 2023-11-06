priest_inner_fire = class({})
LinkLuaModifier("priest_inner_fire_modifier", "player/priest/modifiers/priest_inner_fire_modifier", LUA_MODIFIER_MOTION_NONE)

function priest_inner_fire:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function priest_inner_fire:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function priest_inner_fire:OnSpellStart()
    if IsServer() then

        -- init
        self.caster = self:GetCaster()
        local duration = self:GetSpecialValueFor( "duration" )

        self.modifier = self:GetCursorTarget():AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "priest_inner_fire_modifier", -- modifier name
            { duration = duration } -- kv
        )

	end
end
----------------------------------------------------------------------------------------------------------------
