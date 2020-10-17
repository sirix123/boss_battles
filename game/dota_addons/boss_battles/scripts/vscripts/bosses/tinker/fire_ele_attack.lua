fire_ele_attack = class({})

LinkLuaModifier("fire_ele_melt_debuff", "bosses/tinker/modifiers/fire_ele_melt_debuff", LUA_MODIFIER_MOTION_NONE)

function fire_ele_attack:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 7.0)

        self.vTargetPos = self:GetCursorTarget()

        if self:GetCursorTarget() == nil then
            return false
        end

        self:GetCaster():SetForwardVector(self.vTargetPos:GetAbsOrigin())
        self:GetCaster():FaceTowards(self.vTargetPos:GetAbsOrigin())

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

        self:GetCaster():SetForwardVector(self.vTargetPos:GetAbsOrigin())
        self:GetCaster():FaceTowards(self.vTargetPos:GetAbsOrigin())

        -- references
        self.speed = 600 -- special value
        self.damage = 40

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
        -- initial hit
        local dmgTable =
        {
            victim = hTarget,
            attacker = self.caster,
            damage = self.damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
        }

        ApplyDamage(dmgTable)

        local hBuff = hTarget:AddNewModifier( self:GetCaster(), self, "fire_ele_melt_debuff", { duration = 5 } )
        hBuff:IncrementStackCount()

    end
end
