space_dive = class({})
--LinkLuaModifier( "space_dive_modifier", "player/fire_mage/modifiers/space_dive_modifier", LUA_MODIFIER_MOTION_NONE )

function space_dive:OnAbilityPhaseStart()
    if IsServer() then
        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function space_dive:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function space_dive:OnSpellStart()
    if IsServer() then

        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")


	end
end
----------------------------------------------------------------------------------------------------------------