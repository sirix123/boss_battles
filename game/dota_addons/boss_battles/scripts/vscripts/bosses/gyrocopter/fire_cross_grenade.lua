
fire_cross_grenade = class({})
LinkLuaModifier( "fire_cross_grenade_thinker", "bosses/gyrocopter/fire_cross_grenade_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "fire_cross_grenade_debuff", "bosses/gyrocopter/fire_cross_grenade_debuff", LUA_MODIFIER_MOTION_NONE )

function fire_cross_grenade:OnAbilityPhaseStart()
    if IsServer() then

        return true
    end
end
---------------------------------------------------------------------------

function fire_cross_grenade:OnAbilityPhaseInterrupted()
	if IsServer() then

    end
end
---------------------------------------------------------------------------

function fire_cross_grenade:OnSpellStart()
	if IsServer() then

        local origin = Vector(-12278,1557,132)

        local spawn = Vector( origin.x + RandomInt(-1000,1000), origin.y + RandomInt(-1000,1000), origin.z )

        CreateModifierThinker(
                self:GetCaster(),
                self,
                "fire_cross_grenade_thinker",
                {
                    target_x = spawn.x,
                    target_y = spawn.y,
                    target_z = spawn.z,
                },
                spawn,
                self:GetCaster():GetTeamNumber(),
                false
            )

	end
end
---------------------------------------------------------------------------
