r_explosive_arrow = class({})

function r_explosive_arrow:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 0.8)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            pMovespeedReduction = -50,
            bTurnRateLimit = true,
        })

        return true
    end
end
---------------------------------------------------------------------------

function r_explosive_arrow:OnAbilityPhaseInterrupted()
    if IsServer() then



    end
end
---------------------------------------------------------------------------

function r_explosive_arrow:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)
        local origin = self:GetCaster():GetAbsOrigin()

        local projectile_speed = 1000
        local vTargetPos = nil
        vTargetPos = Vector(self:GetCaster().mouse.x, self:GetCaster().mouse.y, self:GetCaster().mouse.z)
        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

        local projectile = {
            EffectName = "particles/ranger/m1_ranger_windrunner_base_attack.vpcf",
            vSpawnOrigin = self:GetCaster():GetAbsOrigin() + Vector(0, 0, 100),
            fDistance = self:GetCastRange(Vector(0,0,0), nil),
            fUniqueRadius = 100,
            Source = self:GetCaster(),
            vVelocity = projectile_direction * projectile_speed,
            UnitBehavior = PROJECTILES_DESTROY,
            TreeBehavior = PROJECTILES_DESTROY,
            WallBehavior = PROJECTILES_DESTROY,
            GroundBehavior = PROJECTILES_NOTHING,
            fGroundOffset = 80,
            UnitTest = function(_self, unit)
                return unit:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and CheckGlobalUnitTableForUnitName(unit) ~= true
            end,
            OnUnitHit = function(_self, unit)

            end,
            OnFinish = function(_self, pos)

            end,
        }

        Projectiles:CreateProjectile(projectile)


	end
end
----------------------------------------------------------------------------------------------------------------
