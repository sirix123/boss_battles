r_outgoing_dmg = class({})
LinkLuaModifier( "r_outgoing_dmg_buff", "player/nocens/modifiers/r_outgoing_dmg_buff", LUA_MODIFIER_MOTION_NONE )

function r_outgoing_dmg:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function r_outgoing_dmg:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function r_outgoing_dmg:OnSpellStart()
    if IsServer() then

        local caster = self:GetCaster()

        -- sound effect
        caster:EmitSound("Hero_Omniknight.Repel")
        caster:FindAbilityByName("q_armor_aura"):SetActivated(false)
		caster:FindAbilityByName("e_regen_aura"):SetActivated(false)

        local units = FindUnitsInRadius(
            caster:GetTeam(),
            caster:GetAbsOrigin(),
            nil,
            9000,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_ANY_ORDER,
            false)

        if units ~= nil and #units ~= 0 then
            for _, unit in pairs(units) do
                unit:AddNewModifier(caster, self, "r_outgoing_dmg_buff", {duration = self:GetSpecialValueFor( "duration" )})
            end
        end

    end
end
---------------------------------------------------------------------------

