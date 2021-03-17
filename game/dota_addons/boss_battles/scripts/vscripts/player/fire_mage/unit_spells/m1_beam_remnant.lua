m1_beam_remnant = class({})

function m1_beam_remnant:OnAbilityPhaseStart()
    if IsServer() then

        local enemies = FindUnitsInRadius(
            self:GetCaster():GetOwner():GetTeamNumber(),
            self:GetCaster():GetAbsOrigin(),
            nil,
            900,
            DOTA_TEAM_BADGUYS,
            DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false )

        if #enemies == 0 or enemies == nil then
            --print("#enemies= 0, / cant find any")
            return false
        else
            for i = 1, #enemies, 1 do
                if CheckGlobalUnitTableForUnitName(enemies[i]) == nil then
                    self.create_particle = true
                    self.beam_point = Vector(0,0,0)
                    self.target = enemies[i]
                    --print("self.target ",self.target:GetUnitName())
                    return true
                else
                    --print("self.target ",self.target:GetUnitName())
                end
            end
        end
    end
end
---------------------------------------------------------------------------

function m1_beam_remnant:OnAbilityPhaseInterrupted()
    if IsServer() then

        self:GetCaster():FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)

    end
end
---------------------------------------------------------------------------

function m1_beam_remnant:OnChannelFinish(bInterrupted)
	if IsServer() then

        self:GetCaster():FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)

        if self.pfx ~= nil then
            ParticleManager:DestroyParticle(self.pfx,true)
        end

	end
end

function m1_beam_remnant:OnChannelThink( flinterval )
	if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_GENERIC_CHANNEL_1, 1.2)

        -- init
        self.caster = self:GetCaster()
        self.origin = self.caster:GetAbsOrigin()

        -- caster direction
        local caster_forward = ( self.target:GetAbsOrigin() - self.origin ):Normalized()
        self:GetCaster():SetForwardVector( caster_forward )
        self:GetCaster():FaceTowards( caster_forward )

        -- ref
        -- dmg
        local dmg = self:GetCaster():GetOwner():FindAbilityByName("m1_beam"):GetSpecialValueFor( "dmg" )
        local dmg_buff = dmg + ( dmg * self:GetCaster():GetOwner():FindAbilityByName("m2_meteor"):GetSpecialValueFor( "fire_weakness_dmg_increase" ) )

        -- beam
        self.beam_width = 100
        local beam_length = self:GetCaster():GetOwner():FindAbilityByName("m1_beam"):GetSpecialValueFor( "beam_length" )

        -- beam particle and movement
        if self.create_particle == true then
            --EmitSoundOn("Hero_Phoenix.SunRay.Cast", self:GetCaster())

            local particleName = "particles/econ/items/phoenix/phoenix_solar_forge/phoenix_sunray_solar_forge.vpcf"
            self.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, self:GetCaster() )
            self.create_particle = false
        end

        ParticleManager:SetParticleControl(self.pfx, 0, Vector( self.caster:GetAbsOrigin().x, self.caster:GetAbsOrigin().y, self.caster:GetAbsOrigin().z + 100 ))

        caster_forward = ( self.target:GetAbsOrigin() - self.origin ):Normalized()
        self.beam_point = self.origin + caster_forward * beam_length
        self.beam_point = GetGroundPosition( self.beam_point, nil )
        self.beam_point.z = self.beam_point.z + 100

        --DebugDrawCircle(self.beam_point,Vector(255,0,0),128,100,true,60)

        ParticleManager:SetParticleControl( self.pfx, 1, self.beam_point )

        -- dmg
        self.time = (self.time or 0) + flinterval
        if self.time < 0.5 then
            return
        else
            local units = FindUnitsInLine(
                        self:GetCaster():GetOwner():GetTeamNumber(),
                        self:GetCaster():GetAbsOrigin(),
                        self.beam_point,
                        nil,
                        self.beam_width,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NONE)

                    if units ~= nil and #units ~= 0 then
                        for _,unit in pairs(units) do
                            if unit:HasModifier("m2_meteor_fire_weakness") then
                                dmg = dmg_buff
                            else
                                dmg = dmg
                            end

                            local damage = {
                                victim = unit,
                                attacker = self:GetCaster():GetOwner(),
                                damage = dmg,
                                damage_type = DAMAGE_TYPE_PHYSICAL,
                                ability = self:GetCaster():GetOwner():FindAbilityByName("e_fireball")
                            }
                            ApplyDamage( damage )
                        end
                    end

            self.time = 0
        end

	end
end

function m1_beam_remnant:OnSpellStart()
    if IsServer() then

        if not self:IsChanneling() then return end

	end
end
----------------------------------------------------------------------------------------------------------------