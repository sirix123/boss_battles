m1_beam = class({})
LinkLuaModifier( "m1_beam_fire_rage", "player/fire_mage/modifiers/m1_beam_fire_rage", LUA_MODIFIER_MOTION_NONE )

function m1_beam:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_GENERIC_CHANNEL_1, 1.2)

        if self.pfx then
            ParticleManager:DestroyParticle(self.pfx,true)
        end
        
        self:GetCaster():FindAbilityByName("m2_meteor"):SetActivated(false)
        self:GetCaster():FindAbilityByName("q_fire_bubble"):SetActivated(false)
        self:GetCaster():FindAbilityByName("r_remnant"):SetActivated(false)
        self:GetCaster():FindAbilityByName("e_fireball"):SetActivated(false)

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

        if self.pfx then
            ParticleManager:DestroyParticle(self.pfx,true)
        end

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

        --EmitSoundOn("Hero_Phoenix.SunRay.Cast", self:GetCaster())

        -- init
		self.caster = self:GetCaster()
        self.origin = self.caster:GetAbsOrigin()
        self.beam_width = 100
        local dmg = self:GetSpecialValueFor( "dmg" )
        local dmg_buff = self.caster:FindAbilityByName("m2_meteor"):GetSpecialValueFor( "fire_weakness_dmg_increase" )

        local beam_length = self:GetSpecialValueFor( "beam_length" )
        local caster_forward = self.caster:GetForwardVector()
        self.beam_point = self.origin + caster_forward * beam_length

        --self.beam_point = Vector(0,0,0)
        local particleName = "particles/fire_mage/lina_phoenix_sunray_solar_forge.vpcf"
        self.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, self.caster )

        if self.caster:HasModifier("m1_beam_fire_rage") then
            local modifier = self.caster:FindModifierByNameAndCaster("m1_beam_fire_rage",self.caster)
            modifier:SetDuration(self:GetSpecialValueFor( "buff_duration" ),true)
        end

        -- particle effect timer
        Timers:CreateTimer(function()
            if IsValidEntity(self.caster) == false then
                self:CleanUp()
                return false
            end

            if self.caster.left_mouse_up_down == 1 or self.caster:IsStunned() or self.caster:IsSilenced() then
                self:CleanUp()
                return false
            end

            ParticleManager:SetParticleControl(self.pfx, 0, Vector( self.caster:GetAbsOrigin().x, self.caster:GetAbsOrigin().y, self.caster:GetAbsOrigin().z + 100 ))

            caster_forward = self.caster:GetForwardVector()
            self.beam_point = self.origin + caster_forward * beam_length
            self.beam_point = GetGroundPosition( self.beam_point, nil )
            self.beam_point.z = self.beam_point.z + 100

            ParticleManager:SetParticleControl( self.pfx, 1, self.beam_point )

            return 0.01

        end)

        -- dmg timer
        local i = 0
        self.timer = Timers:CreateTimer(function()
            if IsValidEntity(self.caster) == false then
                self:CleanUp()
                return false
            end

            if self.caster.left_mouse_up_down == 1 or self.caster:IsStunned() or self.caster:HasModifier("modifier_stomp_push") or self.caster:IsAlive() == false or self.caster:IsSilenced() then
                self:CleanUp()
                i = 0
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

                            if i >= 1.5 then
                                self.caster:AddNewModifier(self.caster,self,"m1_beam_fire_rage", { duration = self:GetSpecialValueFor( "buff_duration" ) })
                                i = 0
                            end

                            local stacks = 0
                            if self.caster:HasModifier("m1_beam_fire_rage") then
                                stacks = self.caster:GetModifierStackCount("m1_beam_fire_rage", self.caster)
                            end

                            if stacks == 1 or stacks == 0 then
                                self.caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_percent") / 3)
                                if unit:HasModifier("m2_meteor_fire_weakness") then
                                    dmg = ( dmg + ( dmg  * dmg_buff ) ) / 3
                                else
                                    dmg = dmg / 3
                                end
                            elseif stacks == 2 then
                                self.caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_percent") / 2)
                                if unit:HasModifier("m2_meteor_fire_weakness") then
                                    dmg = ( dmg + ( dmg  * dmg_buff ) ) / 2
                                else
                                    dmg = dmg / 2
                                end
                            elseif stacks == 3 then
                                self.caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_percent"))
                                if unit:HasModifier("m2_meteor_fire_weakness") then
                                    dmg = ( dmg + ( dmg  * dmg_buff ) )
                                else
                                    dmg = dmg
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

                            dmg = self:GetSpecialValueFor( "dmg" )
                        end
                    end

            i = i + 0.5
            return 0.5
        end)

	end
end
----------------------------------------------------------------------------------------------------------------

function m1_beam:CleanUp()
    if IsServer() then
        self:GetCaster():FindAbilityByName("m2_meteor"):SetActivated(true)
        self:GetCaster():FindAbilityByName("r_remnant"):SetActivated(true)
        self:GetCaster():FindAbilityByName("e_fireball"):SetActivated(true)
        self:GetCaster():FindAbilityByName("q_fire_bubble"):SetActivated(true)
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")
        ParticleManager:DestroyParticle(self.pfx,true)
        self:GetCaster():FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
        --StopSound("Hero_Phoenix.SunRay.Cast")
    end
end