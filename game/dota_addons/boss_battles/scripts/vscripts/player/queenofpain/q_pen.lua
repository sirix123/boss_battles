q_pen = class({})
LinkLuaModifier("ally_buff_heal", "player/queenofpain/modifiers/ally_buff_heal", LUA_MODIFIER_MOTION_NONE)

function q_pen:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------

function q_pen:OnAbilityPhaseInterrupted()
    if IsServer() then
    end
end

function q_pen:OnChannelFinish(bInterrupted)
	if IsServer() then
	end
end

function q_pen:OnSpellStart()
    if IsServer() then

        if not self:IsChanneling() then return end

	end
end
---------------------------------------------------------------------------

function q_pen:OnChannelThink( flinterval )
    if IsServer() then

        -- init
        self.caster = self:GetCaster()

        local base_heal = self:GetSpecialValueFor( "base_heal" )
        local max_ticks = self:GetSpecialValueFor( "max_ticks" )
        local tick_rate = self:GetSpecialValueFor( "tick_rate" )
        self.dmg        = self:GetSpecialValueFor( "dmg" )
        self.duration_buff = self:GetSpecialValueFor( "duration_main_buff" )

        -- heal calc
        self.heal_amount = base_heal

        self.time = (self.time or 0) + flinterval
        if self.time < self:GetSpecialValueFor( "tick_rate" ) then
            return false
        else
            local info = {
                EffectName = "particles/qop/qop_necrolyte_pulse_friend.vpcf",
                Ability = self,
                iMoveSpeed = 2000,
                Source = self.caster,
                Target = self:GetCursorTarget(),
                bDodgeable = false,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                bProvidesVision = true,
                iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                iVisionRadius = 300,
            }

            ProjectileManager:CreateTrackingProjectile( info )

            self.time = 0
        end

        -- Timers:CreateTimer(tick_rate,function()
        --     if IsValidEntity(self.caster) == false then
        --         self:CleanUp()
        --         return false
        --     end

        --     if self.caster:IsAlive() == false or self:GetCursorTarget():IsAlive() == false then
        --         self:CleanUp()
        --         return false
        --     end

        --     if current_ticks == max_ticks then
        --         self:CleanUp()
        --         return false
        --     end

        --     local info = {
        --         EffectName = "particles/qop/qop_necrolyte_pulse_friend.vpcf",
        --         Ability = self,
        --         iMoveSpeed = 2000,
        --         Source = self.caster,
        --         Target = self:GetCursorTarget(),
        --         bDodgeable = false,
        --         iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
        --         bProvidesVision = true,
        --         iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
        --         iVisionRadius = 300,
        --     }

        --     ProjectileManager:CreateTrackingProjectile( info )

        --     current_ticks = current_ticks + 1
        --     return tick_rate
        -- end)
	end
end
----------------------------------------------------------------------------------------------------------------


function q_pen:OnProjectileHit( hTarget, vLocation)
    if IsServer() then
        if hTarget == nil then return end

        --self.caster:Heal(self.heal_amount, self.caster)

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
    end
end