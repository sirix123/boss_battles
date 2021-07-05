arcane_surge = class({})
LinkLuaModifier( "arcane_surge_modifier", "player/templar/modifiers/arcane_surge_modifier", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function arcane_surge:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })


        return true
    end
end
---------------------------------------------------------------------------

function arcane_surge:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK_EVENT)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------
function arcane_surge:OnSpellStart()

    self:GetCaster():FadeGesture(ACT_DOTA_ATTACK_EVENT)

    self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    local caster = self:GetCaster()
    local point = nil
    point = Clamp(caster:GetAbsOrigin(), Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)


end
--------------------------------------------------------------------------------
