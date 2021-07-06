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

        EmitSoundOn( "Hero_Razor.Storm.Cast", self:GetCaster() )

    end
end
--------------------------------------------------------------------------------
