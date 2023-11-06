e_regen_aura = class({})
LinkLuaModifier( "e_regen_aura_buff", "player/nocens/modifiers/e_regen_aura_buff", LUA_MODIFIER_MOTION_NONE )

function e_regen_aura:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function e_regen_aura:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end
---------------------------------------------------------------------------

function e_regen_aura:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        -- sound effect
        caster:EmitSound("Hero_Omniknight.Repel")
        caster:FindAbilityByName("q_armor_aura"):SetActivated(false)
		caster:FindAbilityByName("r_outgoing_dmg"):SetActivated(false)

        local units = FindUnitsInRadius(
            caster:GetTeam(),
            caster:GetAbsOrigin(),
            nil,
            9000,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_ANY_ORDER,
            false)

        if units ~= nil and #units ~= 0 then
            for _, unit in pairs(units) do
                if unit:GetUnitName() ~= "npc_rock_techies" then
                    unit:AddNewModifier(caster, self, "e_regen_aura_buff", {duration = self:GetSpecialValueFor( "duration" )})
                end
            end
        end

    end
end
---------------------------------------------------------------------------

