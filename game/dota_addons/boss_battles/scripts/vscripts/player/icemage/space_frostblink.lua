space_frostblink = class({})
--LinkLuaModifier( "space_frostblink_modifier_thinker", "player/icemage/modifiers/space_frostblink_modifier_thinker", LUA_MODIFIER_MOTION_NONE )

function space_frostblink:OnAbilityPhaseStart()
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

function space_frostblink:OnSpellStart()

    local point = nil
    point = Clamp(self.caster:GetOrigin(), GameMode.mouse_positions[self.caster:GetPlayerID()], self:GetCastRange(Vector(0,0,0), nil), 0)



end
---------------------------------------------------------------------------

function space_frostblink:OnAbilityPhaseInterrupted()
    if IsServer() then
        self.caster:RemoveModifierByName("casting_modifier_thinker")
    end
end
---------------------------------------------------------------------------
