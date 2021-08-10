space_angel_mode = class({})
LinkLuaModifier("space_angel_mode_modifier", "player/priest/modifiers/space_angel_mode_modifier", LUA_MODIFIER_MOTION_NONE)

function space_angel_mode:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- init
        self.caster = self:GetCaster()
        local duration = self:GetSpecialValueFor( "duration" )

        self.caster:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "space_angel_mode_modifier", -- modifier name
            { duration = duration } -- kv
        )

	end
end
----------------------------------------------------------------------------------------------------------------
