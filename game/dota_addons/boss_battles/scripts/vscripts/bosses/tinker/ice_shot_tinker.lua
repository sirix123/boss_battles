ice_shot_tinker = class({})

LinkLuaModifier( "biting_frost_modifier_debuff", "bosses/tinker/modifiers/biting_frost_modifier_debuff", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "biting_frost_modifier_buff_elec", "bosses/tinker/modifiers/biting_frost_modifier_buff_elec", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "biting_frost_modifier_buff_fire", "bosses/tinker/modifiers/biting_frost_modifier_buff_fire", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "biting_frost_modifier_buff", "bosses/tinker/modifiers/biting_frost_modifier_buff", LUA_MODIFIER_MOTION_NONE  )

function ice_shot_tinker:OnAbilityPhaseStart()
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

function ice_shot_tinker:OnSpellStart()
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
            EffectName = "particles/tinker/blue_tinker_missile.vpcf", --particles/tinker/iceshot__invoker_chaos_meteor.vpcf particles/tinker/blue_tinker_missile.vpcf
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
                return unit:GetModelName() ~= "models/development/invisiblebox.vmdl" and CheckGlobalUnitTableForUnitName(unit) ~= true and unit:GetTeamNumber() ~= caster:GetTeamNumber() or unit:GetUnitName() == "npc_crystal" 
            end,
            OnUnitHit = function(_self, unit)

                EmitSoundOn( "Hero_Tinker.ProjectileImpact", unit )

                if unit:GetUnitName() == "npc_crystal" then
                    if self.stack_count == 0 then
                        unit:GiveMana(10)
                        BossNumbersOnTarget(unit, 10, Vector(75,75,255))
                    else
                        unit:GiveMana(5)
                        BossNumbersOnTarget(unit, 5, Vector(75,75,255))
                    end
                    self:HitCrystal( unit )
                elseif unit:GetTeamNumber() == DOTA_UNIT_TARGET_TEAM_ENEMY then
                    local particle_cast = "particles/units/heroes/hero_lich/lich_frost_nova.vpcf"
                    local sound_target = "Ability.FrostNova"
        
                    -- Create Particle
                    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, unit )
                    ParticleManager:SetParticleControl( effect_cast, 1, Vector( 150, 150, 150 ) )
                    ParticleManager:ReleaseParticleIndex( effect_cast )
        
                    -- Create Sound
                    EmitSoundOn( sound_target, unit )
        
                    unit:AddNewModifier(self:GetCaster(), self, "biting_frost_modifier_debuff",
                        {
                            duration = self.duration,
                            dmg = self.dmg,
                            radius = self.radius,
                            interval = self.dmg_interval,
                        })
                elseif unit:GetUnitName() == "npc_ice_ele" then
                    self:HitEle(unit)
                elseif unit:GetUnitName() == "npc_fire_ele" then
                    self:HitEle(unit)
                elseif unit:GetUnitName() == "npc_elec_ele" then
                    self:HitEle(unit)
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

function ice_shot_tinker:DestroyEffect(pos)
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

function ice_shot_tinker:HitCrystal( crystal )
    if IsServer() then

        -- Create Particle
        local particle_cast = "particles/units/heroes/hero_lich/lich_frost_nova.vpcf"
        local effect_cast_2 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, crystal )
        ParticleManager:SetParticleControl( effect_cast_2, 1, Vector( 1000, 1000, 1000 ) )
        ParticleManager:ReleaseParticleIndex( effect_cast_2 )

        EmitSoundOn( "Hero_Rubick.Attack", crystal )

        Timers:CreateTimer(0.5, function()

            -- find all players
            local units = FindUnitsInRadius(
                self:GetCaster():GetTeamNumber(),	-- int, your team number
                crystal:GetAbsOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                3000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
                0,	-- int, order filter
                false	-- bool, can grow cache
            )

            if units ~= nil and #units ~= 0 then
                for _, unit in pairs(units) do

                        -- references
                        self.speed = 900 -- special value
                        --print("unit:GetUnitName() ", unit:GetUnitName())
                        -- create projectile
                        local info = {
                            EffectName = "particles/tinker/tracking_blue_tinker_missile.vpcf",
                            Ability = self,
                            iMoveSpeed = self.speed,
                            Source = crystal,
                            Target = unit,
                            bDodgeable = false,
                            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                            bProvidesVision = true,
                            iVisionTeamNumber = crystal:GetTeamNumber(),
                            iVisionRadius = 300,
                        }

                        -- shoot proj
                        ProjectileManager:CreateTrackingProjectile( info )
                end
            end

            return false

        end)


    end
end


function ice_shot_tinker:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        if hTarget then
            local particle_cast = "particles/units/heroes/hero_lich/lich_frost_nova.vpcf"
            local sound_target = "Ability.FrostNova"

            -- Create Particle
            local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, hTarget )
            ParticleManager:SetParticleControl( effect_cast, 1, Vector( 150, 150, 150 ) )
            ParticleManager:ReleaseParticleIndex( effect_cast )

            -- Create Sound
            EmitSoundOn( sound_target, hTarget )

            hTarget:AddNewModifier(self:GetCaster(), self, "biting_frost_modifier_debuff",
                {
                    duration = self.duration,
                    dmg = self.dmg,
                    radius = self.radius,
                    interval = self.dmg_interval,
                })

            return true
        end
    end
end
------------------------------------------------------------------------------------------------