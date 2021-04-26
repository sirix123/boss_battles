flame_thrower = class({})
LinkLuaModifier( "modifier_generic_npc_reduce_turnrate", "core/modifier_generic_npc_reduce_turnrate", LUA_MODIFIER_MOTION_NONE )

function flame_thrower:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.4)
        self.create_particle = true

        EmitSoundOn( "gyrocopter_gyro_homing_missile_fire_04", self:GetCaster() )

        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            self:GetCaster():GetAbsOrigin(),
            nil,
            5000,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_CLOSEST,
            false )

        if #enemies == 0 or enemies == nil then
            print("no enemy found for flame")
            return false
        else
            print("enemy found for flame thwoers")
            _G.global_hTarget = enemies[RandomInt(1,#enemies)]
            self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_generic_npc_reduce_turnrate",
            {
                duration = -1,
                target = true,
            })

            self.nfx_indicator = ParticleManager:CreateParticle( "particles/gyrocopter/gyro_flame_debuff.vpcf", PATTACH_OVERHEAD_FOLLOW, global_hTarget )
            ParticleManager:SetParticleControl( self.nfx_indicator, 0, global_hTarget:GetAbsOrigin() )
            ParticleManager:SetParticleControl( self.nfx_indicator, 3, global_hTarget:GetAbsOrigin() )
            ParticleManager:SetParticleControl( self.nfx_indicator, 4, Vector(self:GetSpecialValueFor("duration") + 1,0,0) )
            --ParticleManager:ReleaseParticleIndex(self.nfx_indicator)

            return true
        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function flame_thrower:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)

        self:GetCaster():RemoveModifierByName("modifier_generic_npc_reduce_turnrate")

        if self.nfx_indicator ~= nil then
            ParticleManager:DestroyParticle(self.nfx_indicator,true)
        end

    end
end
---------------------------------------------------------------------------

function flame_thrower:OnSpellStart( )
    if not IsServer() then return end

    if self.timer ~= nil then
        Timers:RemoveTimer(self.timer)
    end

    self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)
    self.caster = self:GetCaster()

    local radius = 280

    if self.create_particle == true then
        local effect = "particles/gyrocopter/gyro_shredder_flame_thrower.vpcf"
        self.nfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, self.caster)
        ParticleManager:SetParticleControlEnt(self.nfx, 3, self.caster, PATTACH_ABSORIGIN_FOLLOW, "attach_missile", self.caster:GetAbsOrigin(), false)
        self.create_particle = false
    end

    local i = 0
    Timers:CreateTimer(function()
        if IsValidEntity(self.caster) == false then
            if self.nfx ~= nil then
                ParticleManager:DestroyParticle(self.nfx,true)
            end
            if self.nfx_indicator ~= nil then
                ParticleManager:DestroyParticle(self.nfx_indicator,true)
            end
            i = 0
            return false
        end

        if self.caster:IsAlive() == false or i >= self:GetSpecialValueFor( "duration") or self:GetCaster():HasModifier("modifier_generic_npc_reduce_turnrate") == false then
            if self.nfx ~= nil then
                ParticleManager:DestroyParticle(self.nfx,true)
            end
            self:StartCooldown(self:GetCooldown(self:GetLevel()))
            if self:GetCaster():HasModifier("modifier_generic_npc_reduce_turnrate") == true then
                self:GetCaster():RemoveModifierByName("modifier_generic_npc_reduce_turnrate")
            end

            if self.nfx_indicator ~= nil then
                ParticleManager:DestroyParticle(self.nfx_indicator,true)
            end
            i = 0
            return false
        end

        -- find units in cone and hurt em
        local enemies = FindUnitsInCone(
            self.caster:GetTeamNumber(),
            self.caster:GetForwardVector(),
            self.caster:GetOrigin(),
            5,
            radius,
            1550,
            nil,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0,
            FIND_ANY_ORDER,
            false)

        for _, enemy in pairs(enemies) do

            local dmgTable = {
                victim = enemy,
                attacker = self.caster,
                damage = self:GetSpecialValueFor( "dmg"),
                damage_type = self:GetAbilityDamageType(),
                ability = self,
            }

            ApplyDamage(dmgTable)
        end

        i = i + 0.1
        return 0.1
    end)
end
