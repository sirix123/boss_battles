r_metamorph = class({})
LinkLuaModifier( "r_metamorph_modifier", "player/ranger/modifiers/r_metamorph_modifier", LUA_MODIFIER_MOTION_NONE )

function r_metamorph:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_TELEPORT, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            bMovementLock = true,
        })

        -- effect
        self.nfx = "particles/ranger/r_metamorph_terrorblade_metamorphosis_transform.vpcf"
        local effect_cast = ParticleManager:CreateParticle(self.nfx, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(effect_cast, 0, Vector(0,0,0))
        ParticleManager:ReleaseParticleIndex(effect_cast)

        return true
    end
end
---------------------------------------------------------------------------

function r_metamorph:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_TELEPORT)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function r_metamorph:OnSpellStart()
    if IsServer() then
        self:GetCaster():FadeGesture(ACT_DOTA_TELEPORT)

        self.caster = self:GetCaster()

        local flManaMultiplier = self:GetSpecialValueFor( "mana_multiplier_duration" )
        local nMana = self.caster:GetMana()
        local duration = nMana * flManaMultiplier

        -- add modifier to handle transform
        if self.caster:GetManaPercent() < 49 then
            print("min mana req not met")
        else
            self.caster:AddNewModifier(self.caster, self, "r_metamorph_modifier", {duration = duration})
        end
    end
end