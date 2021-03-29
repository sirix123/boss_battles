flak_cannon = class({})
LinkLuaModifier( "modifier_flak_cannon", "bosses/gyrocopter/modifier_flak_cannon", LUA_MODIFIER_MOTION_NONE )

function flak_cannon:OnAbilityPhaseStart()
    if IsServer() then

        -- play sound
        self:GetCaster():EmitSound("Hero_Gyrocopter.FlackCannon.Activate")

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function flak_cannon:OnSpellStart()
    if IsServer() then

        local caster = self:GetCaster()

        caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_flak_cannon", -- modifier name
            {
                duration = self:GetSpecialValueFor("duration"),
            })

        caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_rooted", -- modifier name
            {
                duration = self:GetSpecialValueFor("duration"),
            })

    end
end