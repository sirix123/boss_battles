e_stim_pack = class({})
LinkLuaModifier("stim_pack_buff", "player/rat/modifier/stim_pack_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("stim_pack_debuff", "player/rat/modifier/stim_pack_debuff", LUA_MODIFIER_MOTION_NONE)
---------------------------------------------------------------------------

function e_stim_pack:OnSpellStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.0)

        self:GetCaster():AddNewModifier(self:GetCaster(), self, "stim_pack_buff", { duration = self:GetSpecialValueFor( "buff_duration") })

        -- Play effects
        local sound_cast = "Hero_Hoodwink.Scurry.Cast"
        EmitSoundOn( sound_cast, self:GetCaster() )

    end
end