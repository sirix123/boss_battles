m2_icefall = class({})
LinkLuaModifier( "m2_icefall_modifier_thinker", "player/icemage/modifiers/m2_icefall_modifier_thinker", LUA_MODIFIER_MOTION_NONE )

_G.stopApplyDamageTimer = false

function m2_icefall:OnAbilityPhaseStart()
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

function m2_icefall:OnSpellStart()

    local point = nil
    point = Clamp(self.caster:GetOrigin(), Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

    self.modifier = CreateModifierThinker(
        self.caster,
        self,
        "m2_icefall_modifier_thinker",
        {
            duration = self:GetChannelTime(),
            target_x = point.x,
            target_y = point.y,
            target_z = point.z,
        },
        self.caster:GetOrigin(),
        self.caster:GetTeamNumber(),
        false
    )

end
---------------------------------------------------------------------------

function m2_icefall:OnAbilityPhaseInterrupted()
    if IsServer() then
        self.caster:RemoveModifierByName("casting_modifier_thinker")
    end
end
---------------------------------------------------------------------------

function m2_icefall:OnChannelFinish( bInterrupted )
    if IsServer() then
        if bInterrupted == true then
            _G.stopApplyDamageTimer = true
            self.modifier:Destroy()
        end

        self.caster:RemoveModifierByName("casting_modifier_thinker")
    end
end
---------------------------------------------------------------------------
