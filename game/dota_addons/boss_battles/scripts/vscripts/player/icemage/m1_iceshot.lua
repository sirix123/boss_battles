m1_iceshot = class({})

function m1_iceshot:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.2)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function m1_iceshot:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

local tProjectileData = {}

function m1_iceshot:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = 800

        -- set proj direction to mouse location
        local vTargetPos = nil
        vTargetPos = GameMode.mouse_positions[self.caster:GetPlayerID()]
        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

        local projectile = {
            EffectName = "particles/icemage/icemage_m1_maiden_base_attack.vpcf",
            vSpawnOrigin = origin + Vector(0, 0, 100),
            fDistance = self:GetCastRange(Vector(0,0,0), nil),
            fUniqueRadius = 50,
            Source = self.caster,
            vVelocity = projectile_direction * projectile_speed,
            UnitBehavior = PROJECTILES_DESTROY,
            TreeBehavior = PROJECTILES_DESTROY,
            WallBehavior = PROJECTILES_DESTROY,
            GroundBehavior = PROJECTILES_NOTHING,
            fGroundOffset = 80,
            UnitTest = function(_self, unit) return unit:GetTeamNumber() ~= self.caster:GetTeamNumber() end,
            OnUnitHit = function(_self, unit)
                local dmgTable = {
                    victim = unit,
                    attacker = self.caster,
                    damage = self:GetSpecialValueFor( "dmg" ),
                    damage_type = self:GetAbilityDamageType(),
                }

                ApplyDamage(dmgTable)
                EmitSoundOn("hero_Crystal.projectileImpact", self.caster)
            end,
            OnFinish = function(_self, pos)

            end,
        }

        Projectiles:CreateProjectile(projectile)

	end
end
----------------------------------------------------------------------------------------------------------------
