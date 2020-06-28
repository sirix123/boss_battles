r_frostbomb = class({})
--LinkLuaModifier( "r_frostbomb_modifier_thinker", "player/icemage/modifiers/r_frostbomb_modifier_thinker", LUA_MODIFIER_MOTION_NONE )

function r_frostbomb:OnAbilityPhaseStart()
    if IsServer() then

        self.caster = self:GetCaster()

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint() + self:GetChannelTime(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function r_frostbomb:OnSpellStart()

    local point = nil
    point = Clamp(self.caster:GetOrigin(), GameMode.mouse_positions[self.caster:GetPlayerID()], self:GetCastRange(Vector(0,0,0), nil), 0)



end
---------------------------------------------------------------------------

function r_frostbomb:OnAbilityPhaseInterrupted()
    if IsServer() then
        self.caster:RemoveModifierByName("casting_modifier_thinker")
    end
end
---------------------------------------------------------------------------
