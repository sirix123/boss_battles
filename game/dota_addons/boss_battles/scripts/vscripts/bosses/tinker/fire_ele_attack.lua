fire_ele_attack = class({})

LinkLuaModifier("fire_ele_melt_debuff", "bosses/tinker/modifiers/fire_ele_melt_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("fire_ele_encase_rocks_debuff", "bosses/tinker/modifiers/fire_ele_encase_rocks_debuff", LUA_MODIFIER_MOTION_NONE)

function fire_ele_attack:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 7.0)

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
        self.speed = 600 -- special value
        self.damage = 40
        self.max_stacks = 5

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

            local hBuff = hTarget:AddNewModifier( self:GetCaster(), self, "fire_ele_melt_debuff", { duration = 7 } )
            if hTarget:HasModifier("fire_ele_melt_debuff") == true and hBuff:GetStackCount() < self.max_stacks  then
                hBuff:IncrementStackCount()

                -- check stack count, if >x then encase in rocks
                local stackCount = hBuff:GetStackCount()

                if stackCount == self.max_stacks and hTarget:HasModifier("fire_ele_encase_rocks_debuff") ~= true then
                    local hRocks = CreateUnitByName( "npc_encase_rocks", vLocation, false, nil, nil, DOTA_TEAM_BADGUYS)
                    hRocks:AddNewModifier( nil, nil, "modifier_phased", { duration = -1 })

                    hTarget:AddNewModifier( self:GetCaster(), self, "fire_ele_encase_rocks_debuff", { duration = -1 } )
                    hTarget:AddNewModifier( self:GetCaster(), self, "modifier_rooted", { duration = -1 } )
                end
            end
        end
    end
end
