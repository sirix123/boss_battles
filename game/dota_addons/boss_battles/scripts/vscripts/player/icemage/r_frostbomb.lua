r_frostbomb = class({})
LinkLuaModifier( "r_frostbomb_modifier_thinker", "player/icemage/modifiers/r_frostbomb_modifier_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "r_frostbomb_modifier", "player/icemage/modifiers/r_frostbomb_modifier", LUA_MODIFIER_MOTION_NONE )

function r_frostbomb:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function r_frostbomb:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function r_frostbomb:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function r_frostbomb:OnSpellStart()

    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_2)

    self.caster = self:GetCaster()

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
        --self.caster:RemoveModifierByNameAndCaster("shatter_modifier", self.caster)
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
        self:GetCursorPosition(),
        self.caster:GetTeamNumber(),
        false
    )

end
---------------------------------------------------------------------------
