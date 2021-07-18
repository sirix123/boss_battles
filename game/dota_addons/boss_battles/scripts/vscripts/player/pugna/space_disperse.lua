space_disperse = class({})

LinkLuaModifier( "space_disperse_modifier", "player/pugna/modifiers/space_disperse_modifier", LUA_MODIFIER_MOTION_NONE )

---------------------------------------------------------------------------

function space_disperse:OnSpellStart()
    if IsServer() then

        -- remove casting animation
        --self:GetCaster():RemoveGesture(ACT_DOTA_FLAIL)

        local caster = self:GetCaster()

        -- load data
        local duration = self:GetSpecialValueFor( "duration" )

        -- add modifier
        caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "space_disperse_modifier", -- modifier name
            { duration = duration } -- kv
        )

        -- Play effects
        local sound_cast = "Hero_Pugna.Decrepify"
        EmitSoundOn( sound_cast, caster )

    end
end