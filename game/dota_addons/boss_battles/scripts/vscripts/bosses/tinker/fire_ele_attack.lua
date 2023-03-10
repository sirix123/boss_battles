fire_ele_attack = class({})

LinkLuaModifier("fire_ele_melt_debuff", "bosses/tinker/modifiers/fire_ele_melt_debuff", LUA_MODIFIER_MOTION_NONE)

function fire_ele_attack:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.2)

        self.vTargetPos = self:GetCursorTarget()

        if self:GetCursorTarget() == nil then
            return false
        end

        --self:GetCaster():SetForwardVector(self.vTargetPos:GetAbsOrigin())
        --self:GetCaster():FaceTowards(self.vTargetPos:GetAbsOrigin())

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function fire_ele_attack:OnAbilityPhaseInterrupted()
    if IsServer() then

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function fire_ele_attack:OnSpellStart()
    if IsServer() then
        self.caster = self:GetCaster()

        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)

        --self:GetCaster():SetForwardVector(self.vTargetPos:GetAbsOrigin())
        --self:GetCaster():FaceTowards(self.vTargetPos:GetAbsOrigin())

        -- references
        self.speed = self:GetSpecialValueFor( "speed" ) --600 -- special value
        self.damage = self:GetSpecialValueFor( "damage" ) -- 40
        self.max_stacks = self:GetSpecialValueFor( "max_stacks" ) --5
        self.duration = self:GetSpecialValueFor( "duration" )

        -- create projectile
        local info = {
            EffectName = "particles/units/heroes/hero_invoker/invoker_forged_spirit_projectile.vpcf",
            Ability = self,
            iMoveSpeed = self.speed,
            Source = self.caster,
            Target = self.vTargetPos,
            bDodgeable = false,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bProvidesVision = true,
            iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
            iVisionRadius = 300,
        }

        EmitSoundOn( "Hero_Invoker.ForgeSpirit", self:GetCaster() )

        -- shoot proj
        ProjectileManager:CreateTrackingProjectile( info )

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function fire_ele_attack:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        if hTarget:IsAlive() == true then
            -- initial hit
            local dmgTable =
            {
                victim = hTarget,
                attacker = self.caster,
                damage = self.damage,
                damage_type = DAMAGE_TYPE_PHYSICAL,
            }

            ApplyDamage(dmgTable)

            local hBuff = hTarget:AddNewModifier( self:GetCaster(), self, "fire_ele_melt_debuff", { duration = self.duration } )
            if hTarget:HasModifier("fire_ele_melt_debuff") == true and hBuff:GetStackCount() < self.max_stacks  then
                hBuff:IncrementStackCount()
            end
        end
    end
end
