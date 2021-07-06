space_evocate = class({})
LinkLuaModifier("evocate_modifier", "player/templar/modifiers/evocate_modifier", LUA_MODIFIER_MOTION_NONE)
---------------------------------------------------------------------------

function space_evocate:OnSpellStart()
    if IsServer() then

        --self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_GENERIC_CHANNEL_1, 1.0)

        --[[local reduction_per_charge = self:GetCaster():FindAbilityByName("templar_passive"):GetSpecialValueFor( "space_duration_reduction_per_power_charge" )
        local reduction_duration = 0

        local stacks = 0
        if self:GetCaster():HasModifier("templar_power_charge") then
            stacks = self:GetCaster():GetModifierStackCount("templar_power_charge", self:GetCaster())
        end

        reduction_duration = reduction_per_charge * stacks

        local duration = self:GetSpecialValueFor( "duration" ) - reduction_duration

        self:GetCaster():AddNewModifier(self:GetCaster(), self, "evocate_modifier", { duration = duration })

        if self:GetCaster():HasModifier("templar_power_charge") then
            self:GetCaster():RemoveModifierByName("templar_power_charge")
        end]]

        if self:GetCaster():GetHealth() > 100  then

            local dmgTable = {
                victim = self:GetCaster(),
                attacker = self:GetCaster(),
                damage =  100,
                damage_type = DAMAGE_TYPE_PURE,
                ability = self,
            }

            ApplyDamage(dmgTable)

            self:GetCaster():GiveMana(50)

            local nFXIndex = ParticleManager:CreateParticle( "particles/items3_fx/blink_overwhelming_start.vpcff", PATTACH_WORLDORIGIN, nil )
            ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetAbsOrigin() )
            ParticleManager:ReleaseParticleIndex(nFXIndex)

            local sound_cast = "Item_Desolator.Target"
            EmitSoundOn( sound_cast, self:GetCaster() )
        end

    end
end