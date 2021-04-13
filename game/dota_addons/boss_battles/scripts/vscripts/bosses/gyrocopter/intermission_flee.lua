
intermission_flee = class({})
LinkLuaModifier( "modifier_generic_arc_lua", "player/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "oil_drop_thinker", "bosses/gyrocopter/oil_drop_thinker", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function intermission_flee:OnAbilityPhaseStart()
    if IsServer() then

        if self:GetCursorPosition() then
			self.vTargetPos = self:GetCursorPosition()
		end

        self.effect_indicator = ParticleManager:CreateParticle( "particles/econ/events/new_bloom/dragon_cast_dust.vpcf", PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( self.effect_indicator, 0, self:GetCaster():GetAbsOrigin() )
        ParticleManager:ReleaseParticleIndex(self.effect_indicator)

        return true
    end
end

--------------------------------------------------------------------------------

function intermission_flee:OnAbilityPhaseInterrupted()
	if IsServer() then

    end
end
--------------------------------------------------------------------------------

function intermission_flee:OnSpellStart()
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
                    target_z = GetGroundPosition(self:GetCaster():GetAbsOrigin(),self:GetCaster()).z,
                },
                GetGroundPosition(self:GetCaster():GetAbsOrigin(),self:GetCaster()),
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
                height = 500,
                fix_end = true,
                isStun = true,
                activity = ACT_DOTA_RUN,
                isForward = true,
            } -- kv
        )

        arc:SetEndCallback( function()

            self.effect_indicator = ParticleManager:CreateParticle( "particles/econ/events/new_bloom/dragon_cast_dust.vpcf", PATTACH_WORLDORIGIN, nil )
            ParticleManager:SetParticleControl( self.effect_indicator, 0, self:GetCaster():GetAbsOrigin() )
            ParticleManager:ReleaseParticleIndex(self.effect_indicator)

            Timers:RemoveTimer(self.timer)

        end)
	end
end
