electric_turret_electric_charge = class({})
LinkLuaModifier("electric_turret_electric_charge_modifier", "bosses/clock/modifiers/electric_turret_electric_charge_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("electric_turret_effect_modifier", "bosses/clock/modifiers/electric_turret_effect_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("electric_turret_minion_buff", "bosses/clock/modifiers/electric_turret_minion_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("electric_turret_player_buff", "bosses/clock/modifiers/electric_turret_player_buff", LUA_MODIFIER_MOTION_NONE)

function electric_turret_electric_charge:OnSpellStart()
    if IsServer() then

        -- init
        local caster = self:GetCaster()
        self.radius = self:GetSpecialValueFor( "radius" )

        caster:AddNewModifier(caster, self, "electric_turret_electric_charge_modifier",{ duration = -1, radius = self.radius,})

        caster:AddNewModifier(caster, self, "electric_turret_effect_modifier", { duration = -1, radius = self.radius,})

	end
end
----------------------------------------------------------------------------------------------------------------