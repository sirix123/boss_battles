m2_icelance = class({})
LinkLuaModifier("shatter_modifier", "player/icemage/modifiers/shatter_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bonechill_modifier", "player/icemage/modifiers/bonechill_modifier", LUA_MODIFIER_MOTION_NONE)

function m2_icelance:OnAbilityPhaseStart()
    if IsServer() then

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.2)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
        })

        return true
    end
end
---------------------------------------------------------------------------

function m2_icelance:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function m2_icelance:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = self:GetSpecialValueFor( "proj_speed" )
        self.max_shatter_stacks = self:GetSpecialValueFor( "max_shatter_stacks" )
        self.radius = self:GetSpecialValueFor( "shatter_radius" )
        self.baseShatterDmg = self:GetSpecialValueFor( "base_shatter_dmg" )
        self.shatterDmg = self:GetSpecialValueFor( "shatter_dmg_xStacks" )

        -- set proj direction to mouse location
        local vTargetPos = nil
        vTargetPos = GameMode.mouse_positions[self.caster:GetPlayerID()]
        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

        local projectile = {
            EffectName = "particles/icemage/m2_icelance_mars_ti9_immortal_crimson_spear.vpcf",
            vSpawnOrigin = origin + Vector(0, 0, 100),
            fDistance = self:GetCastRange(Vector(0,0,0), nil),
            fUniqueRadius = self:GetSpecialValueFor( "hit_box" ),
            Source = self.caster,
            vVelocity = projectile_direction * projectile_speed,
            UnitBehavior = PROJECTILES_DESTROY,
            TreeBehavior = PROJECTILES_DESTROY,
            WallBehavior = PROJECTILES_DESTROY,
            GroundBehavior = PROJECTILES_NOTHING,
            fGroundOffset = 80,
            UnitTest = function(_self, unit)
                return unit:GetTeamNumber() ~= self.caster:GetTeamNumber()
            end,
            OnUnitHit = function(_self, unit)

                -- init icelance dmg table
                local dmgTable = {
                    victim = unit,
                    attacker = self.caster,
                    damage = self:GetSpecialValueFor( "dmg" ),
                    damage_type = self:GetAbilityDamageType(),
                }

                -- handles bonechill apply logic with shatter stacks
                self:ApplyBoneChill(unit)

                -- applys base dmg icelance regardles of stacks
                ApplyDamage(dmgTable)
                EmitSoundOn("hero_Crystal.projectileImpact", self.caster)

            end,
            OnFinish = function(_self, pos)
                -- add projectile explode particle effect here on the pos it finishes at
                local particle_cast = "particles/units/heroes/hero_crystalmaiden/maiden_base_attack_explosion.vpcf"
                local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
                ParticleManager:SetParticleControl(effect_cast, 0, pos)
                ParticleManager:SetParticleControl(effect_cast, 3, pos)
                ParticleManager:ReleaseParticleIndex(effect_cast)

                -- maybe add small ground aoe here as well if we decide icelance does a sml aoe for dmg
            end,
        }

        Projectiles:CreateProjectile(projectile)

	end
end
----------------------------------------------------------------------------------------------------------------

function m2_icelance:ApplyBoneChill(unit)

    if self.caster:FindModifierByNameAndCaster("shatter_modifier", self.caster) ~= nil then
        local nStackCount = self.caster:FindModifierByNameAndCaster("shatter_modifier", self.caster):GetStackCount()

        -- normal icelance use case 3 stacks burst = bonechill and dmg
        if nStackCount == self.max_shatter_stacks then

            local dmgShatterTable = {
                victim = unit,
                attacker = self.caster,
                damage = self.baseShatterDmg + ( nStackCount * self.shatterDmg ),
                damage_type = self:GetAbilityDamageType(),
            }

            ApplyDamage( dmgShatterTable )

            self:PlayMaxShatterEffect(unit)

            self.caster:AddNewModifier(self.caster, self, "bonechill_modifier", { duration = self:GetSpecialValueFor( "bone_chill_duration" ) })

            self.caster:RemoveModifierByNameAndCaster("shatter_modifier", self.caster)

        -- handle icefall applying more stacks and the mobs not bursting during the icefall
        elseif nStackCount > self.max_shatter_stacks then

            local dmgShatterTable = {
                victim = unit,
                attacker = self.caster,
                damage = self.baseShatterDmg + ( nStackCount * self.shatterDmg ),
                damage_type = self:GetAbilityDamageType(),
            }

            ApplyDamage( dmgShatterTable )

            self:PlayMaxShatterEffect(unit)

            self.caster:AddNewModifier(self.caster, self, "bonechill_modifier", { duration = self:GetSpecialValueFor( "bone_chill_duration" ) })
            self.caster:RemoveModifierByNameAndCaster("shatter_modifier", self.caster)
        end
    end
end
----------------------------------------------------------------------------

function m2_icelance:PlayMaxShatterEffect(unit)

    -- Get Resources
    local particle_cast = "particles/icemage/shatter_maxstacks_explode_maiden_crystal_nova.vpcf"
    local sound_cast = "Hero_Crystal.CrystalNova"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( effect_cast, 0, unit:GetAbsOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 2, self.radius ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    -- Create Sound
    EmitSoundOnLocationWithCaster( unit:GetAbsOrigin(), sound_cast, self:GetCaster() )
end
----------------------------------------------------------------------------