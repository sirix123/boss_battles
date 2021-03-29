
test_oil_watergun_debug = class({})
LinkLuaModifier( "oil_drop_thinker", "bosses/gyrocopter/oil_drop_thinker", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function test_oil_watergun_debug:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end

--------------------------------------------------------------------------------

function test_oil_watergun_debug:OnAbilityPhaseInterrupted()
	if IsServer() then

    end
end
--------------------------------------------------------------------------------

function test_oil_watergun_debug:OnSpellStart()
	if IsServer() then

        -- dorp oil timer
        self.timer = Timers:CreateTimer(function()
            if IsValidEntity(self:GetCaster()) == false then
                return false
            end

            if self:GetCaster():IsAlive() == false then
                return false
            end

            -- create the modifier thinker
           CreateModifierThinker(
            self:GetCaster(),
                self,
                "oil_drop_thinker",
                {
                    target_x = self:GetCaster().x,
                    target_y = self:GetCaster().y,
                    target_z = self:GetCaster().z,
                },
                self:GetCaster():GetAbsOrigin(),
                self:GetCaster():GetTeamNumber(),
                false
            )
            return 0.5
        end)

	end
end
