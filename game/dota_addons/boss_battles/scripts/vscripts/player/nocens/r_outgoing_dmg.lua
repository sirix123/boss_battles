r_outgoing_dmg = class({})
LinkLuaModifier( "r_outgoing_dmg_buff", "player/nocens/modifiers/r_outgoing_dmg_buff", LUA_MODIFIER_MOTION_NONE )

function r_outgoing_dmg:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.0)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function r_outgoing_dmg:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function r_outgoing_dmg:OnSpellStart()
    if IsServer() then

        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        local caster = self:GetCaster()

        -- sound effect
        caster:EmitSound("Hero_Omniknight.Repel")

        caster:FindAbilityByName("q_armor_aura"):StartCooldown(caster:FindAbilityByName("q_armor_aura"):GetCooldown(1))
        caster:FindAbilityByName("e_regen_aura"):StartCooldown(caster:FindAbilityByName("e_regen_aura"):GetCooldown(1))
        caster:FindAbilityByName("r_outgoing_dmg"):StartCooldown(caster:FindAbilityByName("r_outgoing_dmg"):GetCooldown(1))

        --caster:AddNewModifier(caster, self, "r_outgoing_dmg_buff", {duration = self:GetSpecialValueFor( "duration" )})

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
                unit:AddNewModifier(caster, self, "r_outgoing_dmg_buff", {duration = self:GetSpecialValueFor( "duration" )})
            end
        end

    end
end
---------------------------------------------------------------------------

