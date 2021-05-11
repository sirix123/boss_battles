e_fireball_remnant = class({})

function e_fireball_remnant:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_GENERIC_CHANNEL_1, 1.2)

        local enemies = FindUnitsInRadius(
            self:GetCaster():GetOwner():GetTeamNumber(),
            self:GetCaster():GetAbsOrigin(),
            nil,
            self:GetCastRange(Vector(0,0,0), nil),
            DOTA_TEAM_BADGUYS,
            DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false )

        if #enemies == 0 or enemies == nil then
            return false
        else
            self.target = enemies[1]

            if CheckGlobalUnitTableForUnitName(self.target) == nil then
                self.tProjs = {}
                self.target = enemies[1]
                return true
            else
                local attempts_to_find_target = 5
                local count = 0
                while ( CheckGlobalUnitTableForUnitName(self.target) == true ) do
                    self.target = enemies[RandomInt(1, #enemies)]
                    if attempts_to_find_target >= count then
                        return false
                    end
                    count = count + 1
                end

                if self.target ~= nil then
                    self.tProjs = {}
                    return true
                else
                    return false
                end
            end
        end
    end
end
---------------------------------------------------------------------------

function e_fireball_remnant:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)


    end
end
---------------------------------------------------------------------------

function e_fireball_remnant:OnChannelFinish(bInterrupted)
	if IsServer() then

        --[[for _, proj in pairs(self.tProjs) do
            proj:RemoveSelf()
        end]]

        self:GetCaster():FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)

	end
end

function e_fireball_remnant:OnChannelThink( flinterval )
	if IsServer() then

        -- init
        self.caster = self:GetCaster()
        self.origin = self.caster:GetAbsOrigin()

        local caster_forward = ( self.target:GetAbsOrigin() - self.origin ):Normalized()
        self:GetCaster():SetForwardVector( caster_forward )
        self:GetCaster():FaceTowards( caster_forward )

        local dmg = self:GetCaster():GetOwner():FindAbilityByName("e_fireball"):GetSpecialValueFor( "dmg" )

        -- dmg
        self.time = (self.time or 0) + flinterval
        if self.time < self:GetCaster():GetOwner():FindAbilityByName("e_fireball"):GetSpecialValueFor( "interval" ) then
            self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)
            return
        else

            self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.2)

            local projectile = {
                EffectName = "particles/fire_mage/linear_lina_base_attack.vpcf",
                vSpawnOrigin = self.origin + Vector(0, 0, 100),
                fDistance = self:GetCastRange(Vector(0,0,0), nil),
                fUniqueRadius = self:GetCaster():GetOwner():FindAbilityByName("e_fireball"):GetSpecialValueFor( "hit_box" ),
                Source = self.caster,
                vVelocity = caster_forward * self:GetCaster():GetOwner():FindAbilityByName("e_fireball"):GetSpecialValueFor( "speed" ),
                UnitBehavior = PROJECTILES_DESTROY,
                TreeBehavior = PROJECTILES_DESTROY,
                WallBehavior = PROJECTILES_DESTROY,
                GroundBehavior = PROJECTILES_NOTHING,
                fGroundOffset = 80,
                UnitTest = function(_self, unit)
                    return unit:GetTeamNumber() ~= self:GetCaster():GetOwner():GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and CheckGlobalUnitTableForUnitName(unit) ~= true
                end,
                OnUnitHit = function(_self, unit)

                    if unit:IsInvulnerable() ~= true then

                        if unit:HasModifier("m2_meteor_fire_weakness") then
                            dmg = dmg + ( dmg * self:GetCaster():GetOwner():FindAbilityByName("m2_meteor"):GetSpecialValueFor( "fire_weakness_dmg_increase" ) )
                        end

                        local damage = {
                            victim = unit,
                            attacker = self:GetCaster():GetOwner(),
                            damage = dmg,
                            damage_type = DAMAGE_TYPE_PHYSICAL,
                            ability = self:GetCaster():GetOwner():FindAbilityByName("m1_beam")
                        }
                        ApplyDamage( damage )

                    end

                    EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "hero_Crystal.projectileImpact", self.caster)

                end,
                OnFinish = function(_self, pos)
                    -- add projectile explode particle effect here on the pos it finishes at
                    local particle_cast = "particles/units/heroes/hero_lina/lina_base_attack_explosion.vpcf"
                    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
                    ParticleManager:SetParticleControl(effect_cast, 0, pos)
                    ParticleManager:SetParticleControl(effect_cast, 3, pos)
                    ParticleManager:ReleaseParticleIndex(effect_cast)
                end,
            }

            table.insert(self.tProjs,Projectiles:CreateProjectile(projectile))

            self.time = 0
        end

	end
end

function e_fireball_remnant:OnSpellStart()
    if IsServer() then

        if not self:IsChanneling() then return end

	end
end
----------------------------------------------------------------------------------------------------------------