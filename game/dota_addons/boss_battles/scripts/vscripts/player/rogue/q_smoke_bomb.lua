q_smoke_bomb = class({})

LinkLuaModifier( "q_smoke_bomb_modifier", "player/rogue/modifiers/q_smoke_bomb_modifier", LUA_MODIFIER_MOTION_NONE )

---------------------------------------------------------------------------

function q_smoke_bomb:OnSpellStart()
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
            "q_smoke_bomb_modifier", -- modifier name
            { duration = duration } -- kv
        )

        -- Play effects
        local sound_cast = "Hero_PhantomAssassin.Blur"
        EmitSoundOn( sound_cast, caster )

    end
end