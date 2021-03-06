e_regen_aura = class({})
LinkLuaModifier( "e_regen_aura_buff", "player/nocens/modifiers/e_regen_aura_buff", LUA_MODIFIER_MOTION_NONE )

function e_regen_aura:OnAbilityPhaseStart()
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

function e_regen_aura:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function e_regen_aura:OnSpellStart()
    if IsServer() then

        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        local caster = self:GetCaster()

        -- sound effect
        caster:EmitSound("Hero_Omniknight.Repel")

        --caster:AddNewModifier(caster, self, "e_regen_aura_buff", {duration = self:GetSpecialValueFor( "duration" )})

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
                unit:AddNewModifier(caster, self, "e_regen_aura_buff", {duration = self:GetSpecialValueFor( "duration" )})
            end
        end

    end
end
---------------------------------------------------------------------------

