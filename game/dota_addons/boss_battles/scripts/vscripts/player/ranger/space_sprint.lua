space_sprint = class({})

LinkLuaModifier( "modifier_sprint", "player/ranger/modifiers/modifier_sprint", LUA_MODIFIER_MOTION_NONE )

---------------------------------------------------------------------------

function space_sprint:OnSpellStart()
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
            "modifier_sprint", -- modifier name
            { duration = duration } -- kv
        )
    
        -- Play effects
        local sound_cast = "Ability.Windrun"
        EmitSoundOn( sound_cast, caster )

    end
end