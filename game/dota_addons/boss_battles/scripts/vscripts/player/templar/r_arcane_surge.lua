r_arcane_surge = class({})
LinkLuaModifier( "arcane_surge_modifier", "player/templar/modifiers/arcane_surge_modifier", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function r_arcane_surge:OnSpellStart()
    if IsServer() then

        self:GetCaster():AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "arcane_surge_modifier", -- modifier name
            {
                duration = self:GetSpecialValueFor( "duration" ),
            } -- kv
        )

        -- makes stacks drop off individually
        Timers:CreateTimer(self:GetSpecialValueFor( "duration" ), function()

            if self:GetCaster():HasModifier("arcane_surge_modifier") then
                local stacks = self:GetCaster():GetModifierStackCount("arcane_surge_modifier", self:GetCaster())
                if stacks > 0 then
                    self:GetCaster():SetModifierStackCount("arcane_surge_modifier", self:GetCaster(), stacks -1)	
                end
            end

            return false
        end)

        self:GetCaster():AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "templar_power_charge", -- modifier name
            {duration = -1} -- kv
        )

        EmitSoundOn( "Hero_Razor.Storm.Cast", self:GetCaster() )

    end
end
--------------------------------------------------------------------------------
