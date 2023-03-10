m2_serratedarrow_metamorph = class({})
LinkLuaModifier("m2_serratedarrow_modifier", "player/ranger/modifiers/m2_serratedarrow_modifier", LUA_MODIFIER_MOTION_NONE)

function m2_serratedarrow_metamorph:OnAbilityPhaseStart()
    if IsServer() then

        self.caster = self:GetCaster()

        EmitSoundOnLocationForAllies(self:GetCaster():GetAbsOrigin(), "Ability.PowershotPull", self:GetCaster())

        self.nfx = ParticleManager:CreateParticle("particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_channel_ti6.vpcf", PATTACH_POINT, self.caster)
        ParticleManager:SetParticleControl(self.nfx, 0, self.caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(self.nfx, 1, self.caster:GetAbsOrigin())
        ParticleManager:SetParticleControlForward(self.nfx, 1, self.caster:GetForwardVector())

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 0.8)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            bMovementLock = true,
        })

        return true
    end
end
---------------------------------------------------------------------------

function m2_serratedarrow_metamorph:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

        -- destroy channel particle
        ParticleManager:DestroyParticle( self.nfx, true )

    end
end
---------------------------------------------------------------------------

function m2_serratedarrow_metamorph:OnSpellStart()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)

        -- destroy channel particle
        ParticleManager:DestroyParticle( self.nfx, true )

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = self:GetSpecialValueFor( "proj_speed" )

        -- play sound
        EmitSoundOn("Ability.Powershot", self.caster)

        -- set proj direction to mouse location
        local vTargetPos = nil
        vTargetPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
        local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

        local projectile = {
            EffectName = "particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_ti6.vpcf",
            vSpawnOrigin = origin + Vector(0, 0, 100),
            fDistance = self:GetCastRange(Vector(0,0,0), nil),
            fUniqueRadius = self:GetSpecialValueFor( "hit_box" ),
            Source = self.caster,
            vVelocity = projectile_direction * projectile_speed,
            UnitBehavior = PROJECTILES_NOTHING,
            TreeBehavior = PROJECTILES_DESTROY,
            WallBehavior = PROJECTILES_DESTROY,
            GroundBehavior = PROJECTILES_NOTHING,
            fGroundOffset = 80,
            UnitTest = function(_self, unit)
                return unit:GetTeamNumber() ~= self.caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl"
            end,
            OnUnitHit = function(_self, unit)

                -- init dmg table
                local dmgTable = {
                    victim = unit,
                    attacker = self.caster,
                    damage = self:GetSpecialValueFor( "dmg" ),
                    damage_type = self:GetAbilityDamageType(),
                }

                -- play hit sound
                StartSoundEvent( "Hero_Windrunner.PowershotDamage", unit )

                -- applys base dmg icelance regardles of stacks
                ApplyDamage(dmgTable)

                -- apply bleed/serrated arrow to target
                unit:AddNewModifier(self.caster, self, "m2_serratedarrow_modifier", { duration = self:GetSpecialValueFor( "serrated_arrow_duration") })

            end,
            OnFinish = function(_self, pos)
                -- add projectile explode particle effect here on the pos it finishes at
                --[[ currently this isnt working
                local particle_cast = "particles/econ/items/windrunner/windrunner_weapon_rainmaker/windrunner_spell_powershot_destruction_sparkles.vpcf"
                local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
                ParticleManager:SetParticleControl(effect_cast, 0, pos)
                ParticleManager:SetParticleControl(effect_cast, 3, pos)
                ParticleManager:ReleaseParticleIndex(effect_cast)]]
            end,
        }

        -- create projectile and launch it
        Projectiles:CreateProjectile(projectile)
	end
end
----------------------------------------------------------------------------------------------------------------