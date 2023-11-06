m1_beam = class({})
LinkLuaModifier( "m1_beam_fire_rage", "player/fire_mage/modifiers/m1_beam_fire_rage", LUA_MODIFIER_MOTION_NONE )

function m1_beam:GetChannelAnimation()
	return ACT_DOTA_GENERIC_CHANNEL_1
end

function m1_beam:OnAbilityPhaseStart()
    if IsServer() then

        if self.pfx then
            ParticleManager:DestroyParticle(self.pfx,true)
        end

        return true
    end
end
---------------------------------------------------------------------------


function m1_beam:OnSpellStart()
    if IsServer() then

        EmitSoundOn("Hero_Phoenix.SunRay.Cast", self:GetCaster())

        self.caster = self:GetCaster()
        self.origin = self.caster:GetAbsOrigin()
        self.hTarget = self:GetCursorTarget()

        self.tickInit = 0
        self.tick = self:GetSpecialValueFor( "interval" )
        self.dmg = self:GetSpecialValueFor( "dmg" )
        self.beam_width = self:GetSpecialValueFor( "beam_width" )
        self.stack_gain_interval = self:GetSpecialValueFor( "stack_gain_interval" )

        local particleName = "particles/fire_mage/lina_phoenix_sunray_solar_forge.vpcf"
        self.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW , self.caster )
        ParticleManager:SetParticleControl(self.pfx, 0, Vector( self.caster:GetAbsOrigin().x, self.caster:GetAbsOrigin().y, self.caster:GetAbsOrigin().z + 100 ))

        self.dmg_buff = self.caster:FindAbilityByName("m2_meteor"):GetSpecialValueFor( "fire_weakness_dmg_increase" )
	end
end
----------------------------------------------------------------------------------------------------------------


function m1_beam:OnChannelThink(interval)
    if not IsServer() then
        return
    end

    self.tickInit = interval + self.tickInit
    ParticleManager:SetParticleControl( self.pfx, 1, Vector( self.hTarget:GetAbsOrigin().x, self.hTarget:GetAbsOrigin().y,self.hTarget:GetAbsOrigin().z + 100 ) )

    if self.tickInit >= self.tick then
        self.tickInit = 0
        self:DamageUnitsAlongBeam()
    end
end

function m1_beam:DamageUnitsAlongBeam()
    
    local stacks = 0
    if self.caster:HasModifier("m1_beam_fire_rage") then
        stacks = self.caster:GetModifierStackCount("m1_beam_fire_rage", self.caster)
    end
    
    local units = FindUnitsInLine(
            self:GetCaster():GetTeamNumber(),
            self:GetCaster():GetAbsOrigin(),
            self.hTarget:GetAbsOrigin(),
            nil,
            self.beam_width,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE)
    
    if units ~= nil and #units ~= 0 then
        if self.caster:HasModifier("m1_beam_fire_rage") then
            local modifier = self.caster:FindModifierByNameAndCaster("m1_beam_fire_rage",self.caster)
            modifier:SetDuration(self:GetSpecialValueFor( "buff_duration" ),true)
        end

        self.caster:AddNewModifier(self.caster,self,"m1_beam_fire_rage", { duration = self:GetSpecialValueFor( "buff_duration" ) })

        for _,unit in pairs(units) do
            if stacks == 1 or stacks == 0 then
                self.caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_percent") / 3)
                if unit:HasModifier("m2_meteor_fire_weakness") then
                    self.dmg = ( self.dmg + ( self.dmg  * self.dmg_buff ) ) / 3
                else
                    self.dmg = self.dmg / 3
                end
            elseif stacks == 2 then
                self.caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_percent") / 2)
                if unit:HasModifier("m2_meteor_fire_weakness") then
                    self.dmg = ( self.dmg + ( self.dmg  * self.dmg_buff ) ) / 2
                else
                    self.dmg = self.dmg / 2
                end
            elseif stacks == 3 then
                self.caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_percent"))
                if unit:HasModifier("m2_meteor_fire_weakness") then
                    self.dmg = ( self.dmg + ( self.dmg  * self.dmg_buff ) )
                else
                    self.dmg = self.dmg
                end
            end

            local damage = {
                victim = unit,
                attacker = self:GetCaster(),
                damage = self.dmg,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability = self
            }
            ApplyDamage( damage )

            self.dmg = self:GetSpecialValueFor( "dmg" )
        end
    end
end

----------------------------------------------------------------------------------------------------------------

function m1_beam:CleanUp()
    if IsServer() then
        if self.pfx then
            ParticleManager:DestroyParticle(self.pfx,true)
        end
    end
end


function m1_beam:OnAbilityPhaseInterrupted()
    if IsServer() then
        self:CleanUp()
    end
end

function m1_beam:OnChannelFinish( bInterrupted )
    if IsServer() then
        self:CleanUp()
    end
end
---------------------------------------------------------------------------