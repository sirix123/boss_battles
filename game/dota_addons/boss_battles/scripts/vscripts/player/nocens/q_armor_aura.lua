q_armor_aura = class({})
LinkLuaModifier( "q_armor_aura_buff", "player/nocens/modifiers/q_armor_aura_buff", LUA_MODIFIER_MOTION_NONE )

function q_armor_aura:OnAbilityPhaseStart()
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

function q_armor_aura:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function q_armor_aura:OnSpellStart()
    if IsServer() then

        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        local caster = self:GetCaster()

        -- sound effect
        caster:EmitSound("Hero_Omniknight.Repel")

        --caster:AddNewModifier(caster, self, "q_armor_aura_buff", {duration = self:GetSpecialValueFor( "duration" )})

        --caster:FindAbilityByName("q_armor_aura"):StartCooldown(caster:FindAbilityByName("q_armor_aura"):GetCooldown(1))
        --caster:FindAbilityByName("e_regen_aura"):StartCooldown(caster:FindAbilityByName("e_regen_aura"):GetCooldown(1))
        --caster:FindAbilityByName("r_outgoing_dmg"):StartCooldown(caster:FindAbilityByName("r_outgoing_dmg"):GetCooldown(1))

        caster:FindAbilityByName("e_regen_aura"):SetActivated(false)
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
                    unit:AddNewModifier(caster, self, "q_armor_aura_buff", {duration = self:GetSpecialValueFor( "duration" )})
                end
            end
        end

    end
end
---------------------------------------------------------------------------

