q_pen = class({})
LinkLuaModifier("ally_buff_heal", "player/queenofpain/modifiers/ally_buff_heal", LUA_MODIFIER_MOTION_NONE)

function q_pen:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1.0)

        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = -1,
            pMovespeedReduction = 0,
            bFaceTarget = true,
            target = self:GetCursorTarget():GetEntityIndex(),
        })

        --[[self:GetCaster():FindAbilityByName("m2_meteor"):SetActivated(false)
        self:GetCaster():FindAbilityByName("q_fire_bubble"):SetActivated(false)
        self:GetCaster():FindAbilityByName("r_remnant"):SetActivated(false)
        self:GetCaster():FindAbilityByName("e_fireball"):SetActivated(false)]]

        return true
    end
end
---------------------------------------------------------------------------

function q_pen:OnAbilityPhaseInterrupted()
    if IsServer() then

        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

        --[[self:GetCaster():FindAbilityByName("m2_meteor"):SetActivated(false)
        self:GetCaster():FindAbilityByName("q_fire_bubble"):SetActivated(false)
        self:GetCaster():FindAbilityByName("r_remnant"):SetActivated(false)
        self:GetCaster():FindAbilityByName("e_fireball"):SetActivated(false)]]

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)

    end
end
---------------------------------------------------------------------------

function q_pen:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)

        -- init
        self.caster = self:GetCaster()
        self.target = self:GetCursorTarget()

        local base_heal = self:GetSpecialValueFor( "base_heal" )
        local max_ticks = self:GetSpecialValueFor( "max_ticks" )
        local tick_rate = self:GetSpecialValueFor( "tick_rate" )
        self.dmg        = self:GetSpecialValueFor( "dmg" )
        self.duration_buff = self:GetSpecialValueFor( "duration_main_buff" )

        -- heal calc
        local current_ticks = 0
        self.heal_amount = base_heal

        Timers:CreateTimer(tick_rate,function()
            if IsValidEntity(self.caster) == false then
                self:CleanUp()
                return false
            end

            if self.caster:IsAlive() == false or self.target:IsAlive() == false then
                self:CleanUp()
                return false
            end

            if current_ticks == max_ticks then
                self:CleanUp()
                return false
            end

            local info = {
                EffectName = "particles/qop/qop_necrolyte_pulse_friend.vpcf",
                Ability = self,
                iMoveSpeed = 2000,
                Source = self.caster,
                Target = self.target,
                bDodgeable = false,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                bProvidesVision = true,
                iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                iVisionRadius = 300,
            }

            ProjectileManager:CreateTrackingProjectile( info )

            current_ticks = current_ticks + 1
            return tick_rate
        end)
	end
end
----------------------------------------------------------------------------------------------------------------

function q_pen:OnProjectileHit( hTarget, vLocation)
    if IsServer() then
        if hTarget == nil then return end

        if hTarget:GetTeam() == DOTA_TEAM_GOODGUYS then

            hTarget:Heal(self.heal_amount, self.caster)

            hTarget:AddNewModifier(
                self.caster, -- player source
                self, -- ability source
                "ally_buff_heal", -- modifier name
                { duration = self.duration_buff } -- kv
            )

        elseif hTarget:GetTeam() == DOTA_TEAM_BADGUYS then

            local dmgTable = {
                victim = hTarget,
                attacker = self.caster,
                damage = self.dmg,
                damage_type = self:GetAbilityDamageType(),
                ability = self,
            }

            ApplyDamage(dmgTable)
        end

		EmitSoundOn("Hero_Zuus.ArcLightning.Target", hTarget)

    end
end
---------------------------------------------------------------------------

function q_pen:CleanUp()
    if IsServer() then
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")
        --[[self:GetCaster():FindAbilityByName("m2_meteor"):SetActivated(true)
        self:GetCaster():FindAbilityByName("r_remnant"):SetActivated(true)
        self:GetCaster():FindAbilityByName("e_fireball"):SetActivated(true)
        self:GetCaster():FindAbilityByName("q_fire_bubble"):SetActivated(true)
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")
        ParticleManager:DestroyParticle(self.pfx,true)]]
    end
end