
flee_v2 = class({})
LinkLuaModifier( "modifier_generic_arc_lua", "player/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "oil_drop_thinker", "bosses/gyrocopter/oil_drop_thinker", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function flee_v2:OnAbilityPhaseStart()
    if IsServer() then

        if self:GetCursorPosition() then
			self.vTargetPos = self:GetCursorPosition()
		end

        return true
    end
end

--------------------------------------------------------------------------------

function flee_v2:OnAbilityPhaseInterrupted()
	if IsServer() then

    end
end
--------------------------------------------------------------------------------

function flee_v2:OnSpellStart()
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
           local puddle = CreateModifierThinker(
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

            table.insert(_G.Oil_Puddles, puddle)

            return self:GetSpecialValueFor("oil_drop_freq")
        end)

        -- movement
        local arc = self:GetCaster():AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_generic_arc_lua", -- modifier name
            {
                target_x = self.vTargetPos.x,
                target_y = self.vTargetPos.y,
                speed = self:GetSpecialValueFor("speed"),
                distance = ( self:GetCaster():GetAbsOrigin() - self.vTargetPos ):Length2D(),
                fix_end = true,
                isStun = true,
                activity = ACT_DOTA_RUN,
                isForward = true,
            } -- kv
        )

        arc:SetEndCallback( function()

            Timers:RemoveTimer(self.timer)

        end)
	end
end
