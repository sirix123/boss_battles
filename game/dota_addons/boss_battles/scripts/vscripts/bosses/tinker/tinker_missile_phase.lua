tinker_missile_phase = class({})
LinkLuaModifier("bird_puddle_thinker", "bosses/tinker/modifiers/bird_puddle_thinker", LUA_MODIFIER_MOTION_NONE)

function tinker_missile_phase:OnAbilityPhaseStart()
    if IsServer() then
        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function tinker_missile_phase:OnSpellStart()
    if IsServer() then

        -- animtion
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- init
		local caster = self:GetCaster()
        local origin = caster:GetAbsOrigin()

        EmitSoundOn( "Hero_Tinker.Heat-Seeking_Missile", self:GetCaster() )

        -- init locations for the projectiles
        local starting_point_edge = Vector(0,0,0) --comes from ai code (cursor target)
        local vCentre = Vector(0,0,0)
        local distance = ( vCentre - self.starting_point ):Length2D()

        -- if distance is......... > x then angle increment is smaller
        local angleIncrement = 1
        local currentAngle = 0

        -- init projectile params
        local speed = self:GetSpecialValueFor( "speed" ) --500
        self.dmg = self:GetSpecialValueFor( "dmg" )
        self.radius = self:GetSpecialValueFor( "radius" )
        self.dmg_interval = self:GetSpecialValueFor( "interval" )
        self.duration = self:GetSpecialValueFor( "duration" )

        local direction = (self.target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized()

        local projectile = {
            EffectName = "particles/tinker/red_tinker_missile.vpcf", --particles/tinker/iceshot__invoker_chaos_meteor.vpcf particles/tinker/blue_tinker_missile.vpcf
            vSpawnOrigin = origin + direction * 150,
            fDistance = 5000,
            fUniqueRadius = 200,
            Source = caster,
            vVelocity = direction * speed,
            UnitBehavior = PROJECTILES_NOTHING,
            TreeBehavior = PROJECTILES_NOTHING,
            WallBehavior = PROJECTILES_DESTROY,
            GroundBehavior = PROJECTILES_NOTHING,
            fGroundOffset = 80,
            UnitTest = function(_self, unit)
                return unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and CheckGlobalUnitTableForUnitName(unit) ~= true
            end,
            OnUnitHit = function(_self, unit)
            end,
            OnFinish = function(_self, pos)

                CreateModifierThinker(
                    self:GetCaster(),
                    self:GetCaster(),
                    "bird_puddle_thinker",
                    {
                        duration = -1,
                        target_x = unit:GetAbsOrigin().x,
                        target_y = unit:GetAbsOrigin().y,
                        target_z = unit:GetAbsOrigin().z,
                    },
                    unit:GetAbsOrigin(),
                    self:GetCaster():GetTeamNumber(),
                    false
                )

                EmitSoundOn( "Hero_Tinker.Heat-Seeking_Missile.Impact", unit )

                self:DestroyEffect(pos)
            end,
        }

        Projectiles:CreateProjectile(projectile)


	end
end
------------------------------------------------------------------------------------------------

function tinker_missile_phase:DestroyEffect(pos)
    if IsServer() then
        --print("runing?")
        local particle_cast = "particles/units/heroes/hero_crystalmaiden/maiden_base_attack_explosion.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(effect_cast, 0, pos)
        ParticleManager:SetParticleControl(effect_cast, 3, pos)
        ParticleManager:ReleaseParticleIndex(effect_cast)

    end
end
------------------------------------------------------------------------------------------------