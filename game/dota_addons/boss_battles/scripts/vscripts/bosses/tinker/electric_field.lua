electric_field = class({})

LinkLuaModifier( "electric_field_modifier", "bosses/tinker/modifiers/electric_field_modifier", LUA_MODIFIER_MOTION_NONE )

function electric_field:OnAbilityPhaseStart()
    if IsServer() then

        -- play voice line
        EmitSoundOn("techies_tech_suicidesquad_01", self:GetCaster())

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function electric_field:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()

        -- ( max radius / speed ) * 2
        local duration = ( 2500 / 1200 ) * 2

        caster:AddNewModifier(caster, self, "electric_field_modifier", {duration = duration} )

    end
end