m1_beam = class({})
LinkLuaModifier( "m1_beam_fire_rage", "player/fire_mage/modifiers/m1_beam_fire_rage", LUA_MODIFIER_MOTION_NONE )

function m1_beam:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_GENERIC_CHANNEL_1, 1.2)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = -1,
            bMovementLock = true,
            bTurnRateLimit = true,
        })

        return true
    end
end
---------------------------------------------------------------------------

function m1_beam:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function m1_beam:OnSpellStart()
    if IsServer() then

        if self.timer ~= nil then
            Timers:RemoveTimer(self.timer)
        end

        EmitSoundOn("Hero_Phoenix.SunRay.Cast", self:GetCaster())

        -- init
		self.caster = self:GetCaster()
        self.origin = self.caster:GetAbsOrigin()
        self.beam_width = 100
        local dmg = self:GetSpecialValueFor( "dmg" )

        local dmg_1 = dmg * self:GetSpecialValueFor( "dmg_reduction_stage_1" )
        local dmg_2 = dmg * self:GetSpecialValueFor( "dmg_reduction_stage_2" )
        local dmg_3 = dmg

        local dmg_1_buff = ( dmg * self:GetSpecialValueFor( "dmg_reduction_stage_1" ) )   + ( ( dmg * self:GetSpecialValueFor( "dmg_reduction_stage_1" ) ) * self.caster:FindAbilityByName("m2_meteor"):GetSpecialValueFor( "fire_weakness_dmg_increase" )  )
        local dmg_2_buff = ( dmg * self:GetSpecialValueFor( "dmg_reduction_stage_2" ) )   + ( ( dmg * self:GetSpecialValueFor( "dmg_reduction_stage_2" ) ) * self.caster:FindAbilityByName("m2_meteor"):GetSpecialValueFor( "fire_weakness_dmg_increase" )  )
        local dmg_3_buff = dmg             + ( dmg           * self.caster:FindAbilityByName("m2_meteor"):GetSpecialValueFor( "fire_weakness_dmg_increase" )  )

        local channel_time_buff = self:GetSpecialValueFor( "buff_channel_time" ) --timer runs at 0.5

        self.beam_point = Vector(0,0,0)
        local particleName = "particles/econ/items/phoenix/phoenix_solar_forge/phoenix_sunray_solar_forge.vpcf"
        self.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, self.caster )

        -- particle effect timer
        Timers:CreateTimer(function()
            if IsValidEntity(self.caster) == false then return false end

            if self.caster.left_mouse_up_down == 1 then
                self:GetCaster():RemoveModifierByName("casting_modifier_thinker")
                ParticleManager:DestroyParticle(self.pfx,true)
                return false
            end

            ParticleManager:SetParticleControl(self.pfx, 0, Vector( self.caster:GetAbsOrigin().x, self.caster:GetAbsOrigin().y, self.caster:GetAbsOrigin().z + 100 ))

            local beam_length = self:GetSpecialValueFor( "beam_length" )
            local caster_forward = self.caster:GetForwardVector()
            self.beam_point = self.origin + caster_forward * beam_length
            self.beam_point = GetGroundPosition( self.beam_point, nil )
            self.beam_point.z = self.beam_point.z + 100

            ParticleManager:SetParticleControl( self.pfx, 1, self.beam_point )

            return 0.01

        end)

        -- dmg timer
        local j = 0
        local i = 0
        self.timer = Timers:CreateTimer(function()
            if IsValidEntity(self.caster) == false then return false end

            if self.caster.left_mouse_up_down == 1 then
                j = 0
                i = 0
                self:GetCaster():FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
                return false
            end

            local units = FindUnitsInLine(
                        self:GetCaster():GetTeamNumber(),
                        self:GetCaster():GetAbsOrigin(),
                        self.beam_point,
                        nil,
                        self.beam_width,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NONE)

                    if units ~= nil and #units ~= 0 then
                        for _,unit in pairs(units) do

                            if i <= 1 then
                                self.caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_percent") * self:GetSpecialValueFor( "mana_reduction_stage_1" ))
                                if unit:HasModifier("m2_meteor_fire_weakness") then
                                    dmg = dmg_1_buff
                                else
                                    dmg = dmg_1
                                end
                            elseif i <= 5 then
                                self.caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_percent") * self:GetSpecialValueFor( "mana_reduction_stage_2" ))
                                if unit:HasModifier("m2_meteor_fire_weakness") then
                                    dmg = dmg_2_buff
                                else
                                    dmg = dmg_2
                                end
                            elseif i >= 5 then
                                self.caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_percent"))
                                if unit:HasModifier("m2_meteor_fire_weakness") then
                                    dmg = dmg_3_buff
                                else
                                    dmg = dmg_3
                                end
                            end

                            local damage = {
                                victim = unit,
                                attacker = self:GetCaster(),
                                damage = dmg,
                                damage_type = DAMAGE_TYPE_PHYSICAL,
                                ability = self
                            }
                            ApplyDamage( damage )
                        end
                    end

                    if j == channel_time_buff then
                        j = 0
                        --self.caster:AddNewModifier(self.caster,self,"m1_beam_fire_rage", { duration = self:GetSpecialValueFor( "buff_duration" ) })
                    end

            i = i + 0.5
            j = j + 0.5
            return 0.5
        end)

	end
end
----------------------------------------------------------------------------------------------------------------