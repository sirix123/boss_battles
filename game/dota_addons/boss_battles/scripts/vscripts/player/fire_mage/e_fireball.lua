e_fireball = class({})
LinkLuaModifier( "cast_fireball_modifier", "player/fire_mage/modifiers/cast_fireball_modifier", LUA_MODIFIER_MOTION_NONE )

function e_fireball:OnAbilityPhaseStart()
    if IsServer() then
        self.onceoff = true
        return true
    end
end
---------------------------------------------------------------------------

function e_fireball:OnAbilityPhaseInterrupted()
    if IsServer() then

    end
end
---------------------------------------------------------------------------

function e_fireball:OnChannelFinish(bInterrupted)
	if IsServer() then
        local remnant = self:FindRemnant()
        if remnant ~= nil then
            remnant:RemoveModifierByName("cast_fireball_modifier")
        end
	end
end

function e_fireball:OnChannelThink( flinterval )
	if IsServer() then

        -- init
        self.caster = self:GetCaster()
        self.origin = self.caster:GetAbsOrigin()

        local vTargetPos = nil
        vTargetPos = self:GetCursorPosition()
        local projectile_direction = (Vector( vTargetPos.x - self.origin.x, vTargetPos.y - self.origin.y, 0 )):Normalized()

        local dmg = self:GetSpecialValueFor( "dmg" )

        -- do this once
        if self.onceoff == true then
            local remnant = self:FindRemnant()
            if remnant ~= nil then
                remnant:AddNewModifier(remnant, nil, "cast_fireball_modifier",{ duration = -1, })
            end
            self.onceoff = false
        end

        -- end channel if lina gets gripped
        if self.caster:HasModifier("space_leap_of_grip_modifier") then
            return false
        end

        -- dmg
        self.time = (self.time or 0) + flinterval
        if self.time < self:GetSpecialValueFor( "interval" ) then
            self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)
            return false
        else

            self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.2)

            local projectile = {
                EffectName = "particles/fire_mage/linear_lina_base_attack.vpcf",
                vSpawnOrigin = self.origin + Vector(0, 0, 100),
                fDistance = self:GetCastRange(Vector(0,0,0), nil),
                fUniqueRadius = self:GetSpecialValueFor( "hit_box" ),
                Source = self.caster,
                vVelocity = projectile_direction * self:GetSpecialValueFor( "speed" ),
                UnitBehavior = PROJECTILES_DESTROY,
                TreeBehavior = PROJECTILES_DESTROY,
                WallBehavior = PROJECTILES_DESTROY,
                GroundBehavior = PROJECTILES_NOTHING,
                fGroundOffset = 80,
                UnitTest = function(_self, unit)
                    return unit:GetTeamNumber() ~= self.caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and CheckGlobalUnitTableForUnitName(unit) ~= true
                end,
                OnUnitHit = function(_self, unit)

                    if unit:IsInvulnerable() ~= true then

                        if unit:HasModifier("m2_meteor_fire_weakness") then
                            dmg = dmg + ( dmg * self.caster:FindAbilityByName("m2_meteor"):GetSpecialValueFor( "fire_weakness_dmg_increase" ))
                        end

                        local damage = {
                            victim = unit,
                            attacker = self:GetCaster(),
                            damage = dmg,
                            damage_type = DAMAGE_TYPE_PHYSICAL,
                            ability = self
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

            Projectiles:CreateProjectile(projectile)

            self.time = 0
        end

	end
end

function e_fireball:OnSpellStart()
    if IsServer() then

        if not self:IsChanneling() then return end

	end
end
----------------------------------------------------------------------------------------------------------------

function e_fireball:FindRemnant()
    if IsServer() then

        local result = nil
        local previous_result = nil
        local unit_name = ""

        while unit_name ~= "npc_lina_remant" do
            if previous_result == nil then
                result = Entities:FindByClassnameWithin(nil, "npc_dota_creature", self.caster:GetAbsOrigin(), 9000)
            else
                result = Entities:FindByClassnameWithin(previous_result, "npc_dota_creature", self.caster:GetAbsOrigin(), 9000)
            end

            if result ~= nil then
                previous_result = result
                unit_name = result:GetUnitName()
                if unit_name == "npc_lina_remant" then
                    local unit = result
                    return unit
                end
            elseif result == nil then
                break
            end
        end

	end
end