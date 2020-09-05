r_frostbomb = class({})
LinkLuaModifier( "r_frostbomb_modifier_thinker", "player/icemage/modifiers/r_frostbomb_modifier_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "r_frostbomb_modifier", "player/icemage/modifiers/r_frostbomb_modifier", LUA_MODIFIER_MOTION_NONE )

function r_frostbomb:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 0.6)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            bMovementLock = true,
        })

        return true
    end
end
---------------------------------------------------------------------------

function r_frostbomb:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function r_frostbomb:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function r_frostbomb:OnSpellStart()

    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_2)

    self.caster = self:GetCaster()

    local point = nil
    point = Clamp(self.caster:GetOrigin(), Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z), self:GetCastRange(Vector(0,0,0), nil), 0)

    -- init 
    self.dot_duration = 0
    self.nStackCount = 0

    -- frostbomb duration referecnes and calc
    self.fb_base_duration = self:GetSpecialValueFor("fb_base_duration")
    self.fb_bonechill_extra_duration = self:GetSpecialValueFor("fb_bonechill_extra_duration")

    if self.caster:FindModifierByNameAndCaster("bonechill_modifier", self.caster) ~= nil then
        self.dot_duration = self.fb_base_duration + self.fb_bonechill_extra_duration
        self.caster:RemoveModifierByNameAndCaster("bonechill_modifier", self.caster)
    else
        self.dot_duration = self.fb_base_duration
    end

    -- frostbomb damage referecnes and calc
    self.fb_bse_dmg = self:GetSpecialValueFor("fb_bse_dmg")
    self.damage_interval = self:GetSpecialValueFor("damage_interval")
    self.fb_dmg_per_shatter_stack = self:GetSpecialValueFor("fb_dmg_per_shatter_stack")
    self.damageType = self:GetAbilityDamageType()

    -- grab shatter stacks and remove shatter
    if self.caster:FindModifierByNameAndCaster("shatter_modifier", self.caster) ~= nil then
        self.nStackCount = self.caster:FindModifierByNameAndCaster("shatter_modifier", self.caster):GetStackCount()
        self.caster:RemoveModifierByNameAndCaster("shatter_modifier", self.caster)
    end

    CreateModifierThinker(
        self.caster,
        self,
        "r_frostbomb_modifier_thinker",
        {
            duration = self:GetSpecialValueFor( "delay" ),
            fb_bse_dmg = self.fb_bse_dmg,
            damage_interval = self.damage_interval,
            nStackCount = self.nStackCount,
            fb_dmg_per_shatter_stack = self.fb_dmg_per_shatter_stack,
            damage_type = self.damageType,
            dot_duration = self.dot_duration
        },
        point,
        self.caster:GetTeamNumber(),
        false
    )

end
---------------------------------------------------------------------------
