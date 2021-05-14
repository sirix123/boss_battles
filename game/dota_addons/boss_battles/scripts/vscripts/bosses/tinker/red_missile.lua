red_missile = class({})
LinkLuaModifier("bird_puddle_thinker", "bosses/tinker/modifiers/bird_puddle_thinker", LUA_MODIFIER_MOTION_NONE)

function red_missile:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.0)

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team numbers
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return false
        else
            for _, unit in pairs(units) do
                if unit:GetUnitName() == "npc_crystal" then
                    self.target = unit

                    self:GetCaster():SetForwardVector(self.target:GetAbsOrigin())
                    self:GetCaster():FaceTowards(self.target:GetAbsOrigin())
                    return true
                end
            end
        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function red_missile:OnSpellStart()
    if IsServer() then

        -- animtion 
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        -- init
		local caster = self:GetCaster()
        local origin = caster:GetAbsOrigin()

        self.stack_count = 0

        if caster:HasModifier("beam_counter") then
            self.stack_count = caster:FindModifierByName("beam_counter"):GetStackCount()
        end

        EmitSoundOn( "Hero_Tinker.Heat-Seeking_Missile", self:GetCaster() )

        self:GetCaster():SetForwardVector(self.target:GetAbsOrigin())
        self:GetCaster():FaceTowards(self.target:GetAbsOrigin())

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
            UnitBehavior = PROJECTILES_DESTROY,
            TreeBehavior = PROJECTILES_NOTHING,
            WallBehavior = PROJECTILES_DESTROY,
            GroundBehavior = PROJECTILES_NOTHING,
            fGroundOffset = 80,
            UnitTest = function(_self, unit)
                return unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and CheckGlobalUnitTableForUnitName(unit) ~= true
            end,
            OnUnitHit = function(_self, unit)

                EmitSoundOn( "Hero_Tinker.ProjectileImpact", unit )

                if unit:GetUnitName() == "npc_crystal" then
                    self:HitCrystal( unit )
                    if self.stack_count == 0 then
                        unit:GiveMana(10)
                        BossNumbersOnTarget(unit, 10, Vector(75,75,255))
                    else
                        unit:GiveMana(10)
                        BossNumbersOnTarget(unit, 10, Vector(75,75,255))
                    end
                else
                    -- fire puddle on ground
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

                end

                self:DestroyEffect(unit:GetAbsOrigin())

                EmitSoundOn( "Hero_Tinker.Heat-Seeking_Missile.Impact", unit )

            end,
            OnFinish = function(_self, pos)
                self:DestroyEffect(pos)
            end,
        }

        Projectiles:CreateProjectile(projectile)


	end
end
------------------------------------------------------------------------------------------------

function red_missile:DestroyEffect(pos)
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

function red_missile:HitCrystal( crystal )
    if IsServer() then

        local max_proj = 10
        local nProj = 0

        -- references
        self.speed = self:GetSpecialValueFor( "speed" ) --600 -- special value
        self.damage = self:GetSpecialValueFor( "damage" ) -- 40

        Timers:CreateTimer(0.2, function()
            if IsValidEntity(self:GetCaster()) == false then return false end
            if nProj == max_proj then return false end

            local centre_point = Vector(-10633,11918,130.33)
            local radius = 1800
            local x = RandomInt(centre_point.x - radius - 100, centre_point.x + radius + 100)
            local y = RandomInt(centre_point.y - radius - 100, centre_point.y + radius + 100)

            --DebugDrawCircle(Vector(x,y,centre_point.z),Vector(255,255,255),128,100,true,60)

            self.dummy = CreateUnitByName("npc_dummy_unit", Vector(x,y,centre_point.z), false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())

            -- create projectile
            local info = {
                EffectName = "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare.vpcf",
                Ability = self,
                iMoveSpeed = self.speed,
                Source = crystal,
                Target = self.dummy,
                bDodgeable = false,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                bProvidesVision = true,
                iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                iVisionRadius = 300,
            }

            EmitSoundOn( "Hero_Invoker.ForgeSpirit", self:GetCaster() )

            -- shoot proj
            ProjectileManager:CreateTrackingProjectile( info )

            self.dummy:ForceKill(false)

            nProj = nProj + 1
            return 0.1
        end)
    end
end

function red_missile:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        CreateModifierThinker(
            self:GetCaster(),
            self:GetCaster(),
            "bird_puddle_thinker",
            {
                duration = -1,
                target_x = vLocation.x,
                target_y = vLocation.y,
                target_z = vLocation.z,
            },
            vLocation,
            self:GetCaster():GetTeamNumber(),
            false
        )

    end
end