flame_thrower = class({})

function flame_thrower:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.4)


        return true

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function flame_thrower:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)

    end
end
---------------------------------------------------------------------------

function flame_thrower:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)
    self.caster = self:GetCaster()

    -- indicator
    --ParticleManager:DestroyParticle(self.particleNfx,true)

    -- spell
    local effect = "particles/units/heroes/hero_shredder/shredder_flame_thrower.vpcf"
    local nfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, self.caster)
    ParticleManager:SetParticleControlEnt(nfx, 3, self.caster, PATTACH_ABSORIGIN_FOLLOW, "", self.caster:GetAbsOrigin(), false)

end