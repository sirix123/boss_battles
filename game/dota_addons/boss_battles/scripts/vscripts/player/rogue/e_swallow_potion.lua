e_swallow_potion = class({})

LinkLuaModifier( "e_swallow_potion_modifier", "player/rogue/modifiers/e_swallow_potion_modifier", LUA_MODIFIER_MOTION_NONE )

---------------------------------------------------------------------------

function e_swallow_potion:OnSpellStart()
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
            "e_swallow_potion_modifier", -- modifier name
            { duration = duration } -- kv
        )

        -- Play effects
        local sound_cast = "Hero_PhantomAssassin.Blur"
        EmitSoundOn( sound_cast, caster )

    end
end