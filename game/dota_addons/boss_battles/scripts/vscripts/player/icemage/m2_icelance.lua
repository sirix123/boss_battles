m2_icelance = class({})
LinkLuaModifier("shatter_modifier", "player/icemage/modifiers/shatter_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bonechill_modifier", "player/icemage/modifiers/bonechill_modifier", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier( "modifier_target_indicator_line", "player/generic/modifier_target_indicator_line", LUA_MODIFIER_MOTION_NONE )


function m2_icelance:OnAbilityPhaseStart()
    if IsServer() then

        self.nMaxProj = self:GetSpecialValueFor( "max_proj" )
        self.fBetweenProj = self:GetSpecialValueFor( "time_between_proj" )
        self.caster = self:GetCaster()

        -- attach iceorbs around caster
        -- this particple effect can only handle 4 orbs total if maxproj is > 4 only 4 orbs will show
        local particleName = "particles/icemage/icemage_icelance_phoenix_fire_spirits.vpcf"
        self.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, self.caster )

        ParticleManager:SetParticleControl( self.pfx, 1, Vector( self.nMaxProj, 0, 0 ) )

        for i=1, self.nMaxProj do
            ParticleManager:SetParticleControl( self.pfx, 8+i, Vector( 1, 0, 0 ) )
        end

        -- start casting animation
        -- the 1 below is imporant if set incorrectly the animation will stutter (second variable in startgesture is the playback override)
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.5)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint() + ((self.nMaxProj * self.fBetweenProj) - self.fBetweenProj),
            bMovementLock = true,
        })

        --[[ add targeting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_target_indicator_line",
        {
            duration = -1,
            cast_range = self:GetCastRange(Vector(0,0,0), nil),
        })]]

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

        -- remove orbs
        if self.pfx then
            ParticleManager:DestroyParticle( self.pfx, false )
            ParticleManager:ReleaseParticleIndex( self.pfx )
        end

        --[[if self:GetCaster():HasModifier("modifier_target_indicator_line") == true then
            self:GetCaster():RemoveModifierByName("modifier_target_indicator_line")
        end]]

    end
end
---------------------------------------------------------------------------

function m2_icelance:OnSpellStart()
    if IsServer() then

        -- init
		self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()
        local projectile_speed = self:GetSpecialValueFor( "proj_speed" )
        self.max_shatter_stacks = self:GetSpecialValueFor( "max_shatter_stacks" )
        self.radius = self:GetSpecialValueFor( "shatter_radius" )
        self.baseShatterDmg = self:GetSpecialValueFor( "base_shatter_dmg" )
        self.shatterDmg = self:GetSpecialValueFor( "shatter_dmg_xStacks" )
        self.mana_regen = self:GetSpecialValueFor( "mana_regen" )

        local nProj = 0
        local currentOrbs = self.nMaxProj

        -- start timer
        Timers:CreateTimer(0, function()

            -- set proj direction to mouse location
            local vTargetPos = nil
            vTargetPos = Vector(self.caster.mouse.x, self.caster.mouse.y, self.caster.mouse.z)
            local projectile_direction = (Vector( vTargetPos.x - origin.x, vTargetPos.y - origin.y, 0 )):Normalized()

            -- end timer logic
            if nProj == self.nMaxProj then
                -- sstop animation when spell finishes
                self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_1)

                --[[if self:GetCaster():HasModifier("modifier_target_indicator_line") == true then
                    self:GetCaster():RemoveModifierByName("modifier_target_indicator_line")
                end]]

				return false
            end

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
                    return unit:GetTeamNumber() ~= self.caster:GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl"
                end,
                OnUnitHit = function(_self, unit)

                    -- init icelance dmg table
                    local dmgTable = {
                        victim = unit,
                        attacker = self.caster,
                        damage = self:GetSpecialValueFor( "dmg" ),
                        damage_type = self:GetAbilityDamageType(),
                    }

                    -- give mana
                    --self.caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_percent"))

                    -- handles bonechill apply logic with shatter stacks
                    self:ApplyBoneChill(unit)

                    -- applys base dmg icelance regardles of stacks
                    ApplyDamage(dmgTable)
                    EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), "hero_Crystal.projectileImpact", self.caster)

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

            -- destroy one orb
            currentOrbs = currentOrbs - 1
            ParticleManager:SetParticleControl( self.pfx, 1, Vector( currentOrbs, 0, 0 ) )
            for i=1, self.nMaxProj, 1 do
                local radius = 0

                if i <= currentOrbs then
                    radius = 1
                end

                ParticleManager:SetParticleControl( self.pfx, 8+i, Vector( radius, 0, 0 ) )
            end

            -- inc local stack count
            nProj = nProj + 1

            -- create projectile and launch it
            Projectiles:CreateProjectile(projectile)

            return self.fBetweenProj
        end)
	end
end
----------------------------------------------------------------------------------------------------------------

function m2_icelance:ApplyBoneChill(unit)

    if self.caster:FindModifierByNameAndCaster("shatter_modifier", self.caster) ~= nil then
        local nStackCount = self.caster:FindModifierByNameAndCaster("shatter_modifier", self.caster):GetStackCount()

        if nStackCount >= self.max_shatter_stacks then

            local tEnemies = self:AoeDmg(unit)

            for _, enemy in pairs(tEnemies) do
                local dmgShatterTable = {
                    victim = enemy,
                    attacker = self.caster,
                    damage = self.baseShatterDmg + ( nStackCount * self.shatterDmg ),
                    damage_type = self:GetAbilityDamageType(),
                }

                ApplyDamage( dmgShatterTable )
            end


            self:PlayMaxShatterEffect(unit)

            self.caster:AddNewModifier(self.caster, self, "bonechill_modifier", { duration = self:GetSpecialValueFor( "bone_chill_duration" ), mana_regen = self.mana_regen })

            self.caster:RemoveModifierByNameAndCaster("shatter_modifier", self.caster)

        elseif nStackCount ~= 0 and nStackCount < self.max_shatter_stacks then

            local tEnemies = self:AoeDmg(unit)

            for _, enemy in pairs(tEnemies) do
                local dmgShatterTable = {
                    victim = enemy,
                    attacker = self.caster,
                    damage = self.baseShatterDmg + ( nStackCount * self.shatterDmg ),
                    damage_type = self:GetAbilityDamageType(),
                }

                ApplyDamage( dmgShatterTable )
            end

            self.caster:RemoveModifierByNameAndCaster("shatter_modifier", self.caster)
        end
    end
end
----------------------------------------------------------------------------

function m2_icelance:AoeDmg(unit)

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),	-- int, your team number
        unit:GetAbsOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        0,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    return enemies
end

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