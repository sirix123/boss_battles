green_beam = class({})

--LinkLuaModifier( "green_beam_modifier", "bosses/techies/modifiers/green_beam_modifier", LUA_MODIFIER_MOTION_BOTH  )
LinkLuaModifier("beam_counter", "bosses/tinker/modifiers/beam_counter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("beam_phase", "bosses/tinker/modifiers/beam_phase", LUA_MODIFIER_MOTION_NONE)

function green_beam:OnAbilityPhaseStart()
    if IsServer() then

        -- find tinker and get the direction from tinker to the crystral, use this as the starting direction vector for the beam
        local friendlies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        for _, friend in pairs(friendlies) do
            if friend:GetUnitName() == "npc_tinker" then
                friend:AddNewModifier( caster, self, "beam_phase", { duration = -1 } )
            end
        end

        local beam_length = self:GetSpecialValueFor( "beam_length" ) -- 2700
        local randomDirection = RandomVector(5):Normalized()
        self.direction_l = self:GetCaster():GetAbsOrigin() + randomDirection * beam_length
        self.beam_point = ( RotatePosition(self:GetCaster():GetAbsOrigin(), QAngle(0,-150,0), self.direction_l ) )

        local particle = "particles/custom/ui_mouseactions/range_finder_cone_body_only_v3.vpcf"
        self.nPreviewFXIndex = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self:GetCaster():GetAbsOrigin() )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, self.beam_point)
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, self:GetCaster():GetAbsOrigin() );
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 3, Vector( 150, 150, 0 ) );
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 4, Vector( 255, 0, 0 ) );
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 6, Vector( 1, 0, 0 ) );

        -- play voice line
        EmitSoundOn("Hero_Phoenix.SunRay.Cast", self:GetCaster())

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function green_beam:OnSpellStart()
    if IsServer() then

        ParticleManager:DestroyParticle(self.nPreviewFXIndex,true)

        local caster = self:GetCaster()
        local radius = self:GetSpecialValueFor( "radius" ) --30
        local dmg = self:GetSpecialValueFor( "damage" ) --10
        self.wave_dmg = self:GetSpecialValueFor( "wave_dmg" ) --10
        local angleIncrement = self:GetSpecialValueFor( "beam_speed_angle_increment" ) -- 0.6

        local currentAngle = 1
        self.stopFireWave = false

        -- start a timer that fires the blast wave projectile every x seconds, look at the endpos var every timer run
        Timers:CreateTimer(0.5, function()
            if self.stopFireWave == true or caster:IsAlive() == false then

                EmitSoundOn("Hero_Phoenix.SunRay.Stop", self:GetCaster())

                return false
            end

            EmitSoundOn("Hero_Phoenix.SunRay.Loop", self:GetCaster())

            if self.end_pos ~= nil and self.end_pos ~= 0 then
                --print("self.end_pos ",self.end_pos)
                local blastwaveDirection = -( self:GetCaster():GetAbsOrigin() - self.end_pos ):Normalized()
                blastwaveDirection.z = 0
                self:FireBlastWave(blastwaveDirection)
            end

            return 0.5
        end)

        local beam_point = self.beam_point
        --DebugDrawCircle(beam_point, Vector(155,0,0),128,50,true,60)

        -- create particle effect
        local particleName = "particles/tinker/green_phoenix_sunray.vpcf"
        self.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
        caster:SetContextThink( DoUniqueString( "updateSunRay" ), function ( )

            if caster:IsAlive() == false then
                return -1
            end

            --print("caster:SetContextThink( DoUniqueString")

            ParticleManager:SetParticleControl(self.pfx, 0, Vector( caster:GetAbsOrigin().x,caster:GetAbsOrigin().y, caster:GetAbsOrigin().z + 100 ))

            self.end_pos = ( RotatePosition(caster:GetAbsOrigin(), QAngle(0,currentAngle,0), beam_point ) )
			self.end_pos = GetGroundPosition( self.end_pos, nil )
			self.end_pos.z = caster:GetAbsOrigin().z + 100
            --DebugDrawCircle(self.end_pos, Vector(0,155,0),128,50,true,60)

            ParticleManager:SetParticleControl( self.pfx, 1, self.end_pos )

            local units = FindUnitsInLine(
                caster:GetTeamNumber(),
				caster:GetAbsOrigin(),
				self.end_pos,
				nil,
				radius,
				DOTA_UNIT_TARGET_TEAM_BOTH,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE)

            if units ~= nil and #units ~= 0 then
                for _,unit in pairs(units) do
                    --print(unit:GetUnitName())
                    if unit:GetUnitName() == "npc_tinker" then
                        self.stopFireWave = true

                        EmitSoundOn("tinker_tink_death_03", self:GetCaster())

                        -- this code holds the beam on tinker until the timer after this function ends
                        ParticleManager:SetParticleControl( self.pfx, 1, Vector( unit:GetAbsOrigin().x,unit:GetAbsOrigin().y, unit:GetAbsOrigin().z + 100 ))

                        Timers:CreateTimer(5, function()

                            -- remove beam phase modifier 
                            unit:RemoveModifierByName("beam_phase")

                            -- explode shield particle

                            -- explode wave that goes through the arena

                            ParticleManager:DestroyParticle(self.pfx, false)

                            -- clean up remaining rocks
                            self:CleanUpRemainingRocks()

                            -- everytime tinker is hit by the beam inc the stack on the modifier
                            self.hBuff = unit:AddNewModifier( self:GetCaster(), self, "beam_counter", { duration = -1 } )
                            if unit:HasModifier("beam_counter") == true and self.hBuff:GetStackCount() < 5 then
                                --print("self.hBuff:GetStackCount() ",self.hBuff:GetStackCount() )
                                self.hBuff:IncrementStackCount()
                            end
                        end)

                        return -1
                    end

                    --[[if unit:GetUnitName() == "npc_rock" then

                        --particles/econ/items/tiny/tiny_prestige/tiny_prestige_lvl4_death_rocks.vpcf
                        local particle_destroy = "particles/tinker/tinker_tiny_prestige_lvl4_death_rocks.vpcf"
                        local particle_effect = ParticleManager:CreateParticle( particle_destroy, PATTACH_WORLDORIGIN, nil )
                        ParticleManager:SetParticleControl(particle_effect, 0, unit:GetAbsOrigin() )
                        ParticleManager:ReleaseParticleIndex(particle_effect)

                        local particle_destroy_2 = "particles/econ/items/rubick/rubick_force_ambient/rubick_telekinesis_force_dust.vpcf"
                        local particle_effect_2 = ParticleManager:CreateParticle( particle_destroy_2, PATTACH_WORLDORIGIN, nil )
                        ParticleManager:SetParticleControl(particle_effect_2, 0, unit:GetAbsOrigin() )
                        ParticleManager:ReleaseParticleIndex(particle_effect_2)

                        unit:RemoveSelf()
                    end]]
                end
            end

            -- handles dmging players
            local units_2 = FindUnitsInLine(
                caster:GetTeamNumber(),
				caster:GetAbsOrigin(),
				self.end_pos,
				nil,
				radius,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                0)

                if units_2 ~= nil and #units_2 ~= 0 then
                    for _,unit in pairs(units_2) do
                        local damage = {
                            victim = unit,
                            attacker = self:GetCaster(),
                            damage = dmg,
                            damage_type = DAMAGE_TYPE_PHYSICAL,
                            ability = self
                        }
                        ApplyDamage( damage )
                    end
                end

            if currentAngle == 360 then
                currentAngle = 0
            end

            currentAngle = currentAngle + angleIncrement
            --print("currentAngle ",currentAngle)
            return 0.01
        end, 0.0 )

    end
end
------------------------------------------------------------------------------------------------------------------------------

function green_beam:FireBlastWave(direction)
    if IsServer() then
        local projectile_speed = 700

        local projectile = {
            EffectName = "particles/tinker/tinker_napalm_wave_basedtidehuntergushupgrade.vpcf",
            vSpawnOrigin = self:GetCaster():GetAbsOrigin() + Vector(0, 0, 0),
            fDistance = 5000,
            fStartRadius = 200,
			fEndRadius = 200,
            Source = self:GetCaster(),
            vVelocity = direction * projectile_speed,
            UnitBehavior = PROJECTILES_NOTHING,
            bMultipleHits = false,
            TreeBehavior = PROJECTILES_DESTROY,
            WallBehavior = PROJECTILES_DESTROY,
            GroundBehavior = PROJECTILES_NOTHING,
            fGroundOffset = 80,
            draw = false,
            UnitTest = function(_self, unit)
                if unit == nil then
                    return false
                end
                return unit:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and unit:GetModelName() ~= "models/development/invisiblebox.vmdl" --and CheckGlobalUnitTableForUnitName(unit) ~= true
            end,
            OnUnitHit = function(_self, unit)
                --print("running on hit?")

                --print("unit ", unit:GetUnitName())

                local dmgTable = {
                    victim = unit,
                    attacker = self:GetCaster(),
                    damage = self.wave_dmg,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                }
                ApplyDamage( dmgTable )

            end,
            OnFinish = function(_self, pos)
            end,
        }

        Projectiles:CreateProjectile(projectile)
    end
end
------------------------------------------------------------------------------------------------------------------------------

function green_beam:CleanUpRemainingRocks()
    if IsServer() then
        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            self:GetCaster():GetAbsOrigin(),
            nil,
            5000,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_ANY_ORDER,
            false )

        if units ~= nil and #units ~= 0 then
            for _,unit in pairs(units) do
                if unit:GetUnitName() == "npc_rock" then

                    --particles/econ/items/tiny/tiny_prestige/tiny_prestige_lvl4_death_rocks.vpcf
                    local particle_destroy = "particles/tinker/tinker_tiny_prestige_lvl4_death_rocks.vpcf"
                    local particle_effect = ParticleManager:CreateParticle( particle_destroy, PATTACH_WORLDORIGIN, nil )
                    ParticleManager:SetParticleControl(particle_effect, 0, unit:GetAbsOrigin() )
                    ParticleManager:ReleaseParticleIndex(particle_effect)

                    unit:RemoveSelf()
                end
            end
        end

    end
end
------------------------------------------------------------------------------------------------------------------------------