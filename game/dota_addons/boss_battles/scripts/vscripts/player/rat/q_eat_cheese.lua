q_eat_cheese = class({})
LinkLuaModifier("cheese_modifier", "player/rat/modifier/cheese_modifier", LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------

function q_eat_cheese:OnSpellStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.0)

        self:GetCaster():AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "cheese_modifier", -- modifier name
            { duration = 5 } -- kv
        )

        Timers:CreateTimer(self:GetSpecialValueFor( "duration" ), function()

            if self:GetCaster():HasModifier("cheese_modifier") then
                local stacks = self:GetCaster():GetModifierStackCount("cheese_modifier", self:GetCaster())
                if stacks > 0 then
                    self:GetCaster():SetModifierStackCount("cheese_modifier", self:GetCaster(), stacks -1)
                end
            end

            return false
        end)

        -- Play effects
        local sound_cast = "DOTA_Item.FaerieSpark.Activate"
        EmitSoundOn( sound_cast, self:GetCaster() )

    end
end