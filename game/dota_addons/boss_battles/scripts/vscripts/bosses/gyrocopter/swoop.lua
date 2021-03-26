
swoop = class({})
LinkLuaModifier( "modifier_generic_arc_lua", "player/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )

--------------------------------------------------------------------------------

function swoop:OnAbilityPhaseStart()
    if IsServer() then

        self.hTargetPos = nil
		if self:GetCursorTarget() then
			self.hTarget = self:GetCursorTarget()
		end

        if self.hTarget then

            -- shoot the fast zap proj

            -- create modifier on them (stunned with electrical particle effect)

        end

        print("phase start")

        return true
    end
end

--------------------------------------------------------------------------------

function swoop:OnAbilityPhaseInterrupted()
	if IsServer() then

    end
end
--------------------------------------------------------------------------------

function swoop:OnSpellStart()
	if IsServer() then

        print("on spell start")

        -- dorp oil timer
        self.timer = Timers:CreateTimer(function()
            if IsValidEntity(self:GetCaster()) == false then
                return false
            end

            if self:GetCaster():IsAlive() == false then
                return false
            end

            -- create the modifier thinker

            return 0.2
        end)

        -- movement
        local arc = self:GetCaster():AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_generic_arc_lua", -- modifier name
            {
                target_x = self.hTarget.x,
                target_y = self.hTarget.y,
                speed = self:GetSpecialValueFor("charge_speed"),
                distance = ( self:GetCaster():GetAbsOrigin() - self.hTargetPos:GetAbsOrigin() ):Length2D(),
                fix_end = true,
                isStun = true,
                activity = ACT_DOTA_RUN,
                isForward = true,
            } -- kv
        )

        arc:SetEndCallback( function()

            Timers:RemoveTimer(self.timer)

            -- add the gyro q modifier

            -- play small slam particle effect
            local nfx = ParticleManager:CreateParticle('particles/units/heroes/hero_centaur/centaur_warstomp.vpcf', PATTACH_ABSORIGIN, self:GetCaster())
            ParticleManager:SetParticleControl(nfx, 1, Vector(400,400,400))
            ParticleManager:SetParticleControl(nfx, 2, self:GetCaster():GetOrigin())
            ParticleManager:SetParticleControl(nfx, 3, self:GetCaster():GetOrigin())
            ParticleManager:SetParticleControl(nfx, 4, self:GetCaster():GetOrigin())
            ParticleManager:SetParticleControl(nfx, 5, self:GetCaster():GetOrigin())
            ParticleManager:ReleaseParticleIndex(nfx)
            self:GetCaster():EmitSound('Hero_Centaur.HoofStomp')

        end)
	end
end
