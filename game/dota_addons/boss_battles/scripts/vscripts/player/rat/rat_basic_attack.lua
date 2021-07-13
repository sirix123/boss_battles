rat_basic_attack = class({})

function rat_basic_attack:GetCastPoint()
	local caster = self:GetCaster()
    local ability_cast_point = self.BaseClass.GetCastPoint(self)

    self.stacks = 0
	if caster:HasModifier("rat_stacks") then
		self.stacks = caster:GetModifierStackCount("rat_stacks", caster)
	end

    local rat_stack_cp_reduction = self:GetCaster():FindAbilityByName("rat_passive"):GetSpecialValueFor( "castpoint_reduction" ) / 100

    if self.stacks > 0 then

        if caster:HasModifier("e_whirling_winds_modifier") == true then
            ability_cast_point = ability_cast_point - ( ability_cast_point * 0.25 ) --flWHIRLING_WINDS_CAST_POINT_REDUCTION = 0.25 -- globals don't work here
        end

        ability_cast_point = ability_cast_point / (( self.stacks * rat_stack_cp_reduction ) + 1 )

        return ability_cast_point
    else
        return ability_cast_point
    end
end
--------------------------------------------------------------------------------

function rat_basic_attack:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.2)

        self.nMaxProj = 3

        if self.stacks ~= nil then
            if self.stacks > 0 then
                self.fBetweenProj = self:GetCastPoint() / self.nMaxProj
            else
                self.fBetweenProj = self:GetCastPoint() / self.nMaxProj
            end
        else
            self.fBetweenProj = self:GetCastPoint() / self.nMaxProj
        end

        if self:GetCaster():HasModifier("stim_pack_buff") == true then
            -- add casting modifier
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
            {
                duration = self:GetCastPoint(),
                pMovespeedReduction = 0,
            })
        else
            -- add casting modifier
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
            {
                duration = self:GetCastPoint(),
                bMovementLock = true,
                pMovespeedReduction = 0,
            })
        end


        --print("cast_point ",self:GetCastPoint())

        return true
    end
end
---------------------------------------------------------------------------

function rat_basic_attack:OnAbilityPhaseInterrupted()
    if IsServer() then

        -- remove casting animation
        self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- remove casting modifier
        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
---------------------------------------------------------------------------

function rat_basic_attack:OnSpellStart()
    if IsServer() then

        -- when spell starts fade gesture
        --self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = self:GetSpecialValueFor( "proj_speed" )

        self.dmg = self:GetSpecialValueFor( "dmg" )

        if self.caster:HasModifier("e_whirling_winds_modifier") then
            projectile_speed = projectile_speed + ( projectile_speed * flWHIRLING_WINDS_PROJ_SPEED_BONUS )
        end

        local nProj = 0
        local nProjHit = 0
        self.pseudoseed = 1--RandomInt( 1, 100 )
        self.chance_to_gain_rat_crystal = 50

        Timers:CreateTimer(function()

            EmitSoundOnLocationWithCaster(self.caster:GetAbsOrigin(), "Hero_Hoodwink.Attack", self.caster)

            -- set proj direction to mouse location
            local vTargetPos = nil
            vTargetPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
            local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

            -- end timer logic
            if nProj == self.nMaxProj then
                self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)
				return false
            end

            local projectile = {
                EffectName = "particles/rat/rat_hoodwink_base_attack.vpcf",
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
                    return unit:GetTeamNumber() ~= self.caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and CheckGlobalUnitTableForUnitName(unit) ~= true
                end,
                OnUnitHit = function(_self, unit)

                    if unit:IsInvulnerable() ~= true then

                        local dmgTable = {
                            victim = unit,
                            attacker = self.caster,
                            damage = self.dmg,
                            damage_type = self:GetAbilityDamageType(),
                            ability = self,
                        }

                        ApplyDamage(dmgTable)

                    end

                    EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "Hero_Hoodwink.ProjectileImpact", self.caster)


                    --[[if RollPseudoRandomPercentage(self.chance_to_gain_rat_crystal, self.pseudoseed, self.caster) then
                        self.caster:ManaOnHit(1)
                    end]]

                    --nProjHit = nProjHit + 1

                    --if nProjHit == 3 then
                        self.caster:GiveMana(self:GetSpecialValueFor( "mana_gain_percent" ))
                    --end

                end,
                OnFinish = function(_self, pos)
                    -- add projectile explode particle effect here on the pos it finishes at
                    local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_base_attack_explosion.vpcf"
                    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
                    ParticleManager:SetParticleControl(effect_cast, 0, pos)
                    ParticleManager:SetParticleControl(effect_cast, 3, pos)
                    ParticleManager:ReleaseParticleIndex(effect_cast)
                end,
            }

            nProj = nProj + 1

            Projectiles:CreateProjectile(projectile)

            return self.fBetweenProj
        end)

	end
end
----------------------------------------------------------------------------------------------------------------
