gyro_call_down = class({})

function gyro_call_down:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_GENERIC_CHANNEL_1, 1.2)
        self.responses =
        {
            "gyrocopter_gyro_call_down_03",
            "gyrocopter_gyro_call_down_04",
            "gyrocopter_gyro_call_down_05",
            "gyrocopter_gyro_call_down_06",
            "gyrocopter_gyro_call_down_09"
        }

        EmitSoundOn("gyrocopter_gyro_call_down_03", self:GetCaster())

        self:GetCaster():AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_generic_arc_lua", -- modifier name
            {
                duration = self:GetChannelTime() + 3,
                height = 500,
                fix_height = true,
                activity = ACT_DOTA_RUN,
            } -- kv
        )

        return true
    end
end
---------------------------------------------------------------------------

function gyro_call_down:OnAbilityPhaseInterrupted()
    if IsServer() then

        self:GetCaster():RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)

    end
end
---------------------------------------------------------------------------

function gyro_call_down:OnChannelFinish(bInterrupted)
	if IsServer() then

        self:GetCaster():RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)

        local max_rings = self:GetSpecialValueFor("gap_between_rings")
        local ring_radius = self:GetSpecialValueFor("max_rings")
        local rocket_dmg_radius = max_rings * ring_radius

        --if bInterrupted ~= true then

            print("dropping the rocket")

            local calldown_first_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_calldown_first.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
            ParticleManager:SetParticleControl(calldown_first_particle, 0, self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_rocket1")))
            ParticleManager:SetParticleControl(calldown_first_particle, 1, GetGroundPosition(self:GetCaster():GetAbsOrigin(),self:GetCaster()))
            ParticleManager:SetParticleControl(calldown_first_particle, 5, Vector(rocket_dmg_radius, rocket_dmg_radius, rocket_dmg_radius))
            ParticleManager:ReleaseParticleIndex(calldown_first_particle)

            -- cast da calldown
            for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, rocket_dmg_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)) do

                ApplyDamage({
                    victim 			= enemy,
                    damage 			= self:GetSpecialValueFor("dmg"),
                    damage_type		= DAMAGE_TYPE_PHYSICAL,
                    attacker 		= self:GetCaster(),
                    ability 		= self
                })

                EmitSoundOn("gyrocopter_gyro_call_down_1"..RandomInt(1, 2), self:GetCaster())

            end
        --end
	end
end

function gyro_call_down:OnChannelThink( flinterval )
	if IsServer() then
	end
end

function gyro_call_down:OnSpellStart()
    if IsServer() then
        if not self:IsChanneling() then return end
	end
end
----------------------------------------------------------------------------------------------------------------