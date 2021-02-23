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
        local particle = "particles/custom/ui_mouseactions/range_finder_cone_body_only_v3.vpcf"

        -- start direction
        local randomVector = RandomVector(5):Normalized()

        local direction_1 = (self:GetCaster():GetAbsOrigin() + randomVector):Normalized()
        --local direction_2 = (self:GetCaster():GetAbsOrigin() + Vector(0,1,0)):Normalized()
        --local direction_3 = (self:GetCaster():GetAbsOrigin() + Vector(-1,0,0)):Normalized()
        --local direction_4 = (self:GetCaster():GetAbsOrigin() + Vector(0,-1,0)):Normalized()

        self.beam_end_point_1 = self:GetCaster():GetAbsOrigin() + direction_1 * beam_length
        --self.beam_end_point_2 = self:GetCaster():GetAbsOrigin() + direction_2 * beam_length
        --self.beam_end_point_3 = self:GetCaster():GetAbsOrigin() + direction_3 * beam_length
        --self.beam_end_point_4 = self:GetCaster():GetAbsOrigin() + direction_4 * beam_length

        self.beam_point_1 = self.beam_end_point_1
        self.beam_point_2 = ( RotatePosition(self:GetCaster():GetAbsOrigin() + randomVector, QAngle(0,90,0), self.beam_end_point_1 ) )
        self.beam_point_3 = ( RotatePosition(self:GetCaster():GetAbsOrigin() + randomVector, QAngle(0,180,0), self.beam_end_point_1 ) )
        self.beam_point_4 = ( RotatePosition(self:GetCaster():GetAbsOrigin() + randomVector, QAngle(0,270,0), self.beam_end_point_1 ) )

        self.tBeams = {self.beam_point_1, self.beam_point_2, self.beam_point_3, self.beam_point_4}

        self.particle_indicator_1 = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( self.particle_indicator_1, 0, self:GetCaster():GetAbsOrigin() )
        ParticleManager:SetParticleControl( self.particle_indicator_1, 1, self.beam_point_1)
        ParticleManager:SetParticleControl( self.particle_indicator_1, 2, self:GetCaster():GetAbsOrigin() );
        ParticleManager:SetParticleControl( self.particle_indicator_1, 3, Vector( 150, 150, 0 ) );
        ParticleManager:SetParticleControl( self.particle_indicator_1, 4, Vector( 255, 0, 0 ) );
        ParticleManager:SetParticleControl( self.particle_indicator_1, 6, Vector( 1, 0, 0 ) );

        self.particle_indicator_2 = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( self.particle_indicator_2, 0, self:GetCaster():GetAbsOrigin() )
        ParticleManager:SetParticleControl( self.particle_indicator_2, 1, self.beam_point_2)
        ParticleManager:SetParticleControl( self.particle_indicator_2, 2, self:GetCaster():GetAbsOrigin() );
        ParticleManager:SetParticleControl( self.particle_indicator_2, 3, Vector( 150, 150, 0 ) );
        ParticleManager:SetParticleControl( self.particle_indicator_2, 4, Vector( 255, 0, 0 ) );
        ParticleManager:SetParticleControl( self.particle_indicator_2, 6, Vector( 1, 0, 0 ) );

        self.particle_indicator_3 = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( self.particle_indicator_3, 0, self:GetCaster():GetAbsOrigin() )
        ParticleManager:SetParticleControl( self.particle_indicator_3, 1, self.beam_point_3)
        ParticleManager:SetParticleControl( self.particle_indicator_3, 2, self:GetCaster():GetAbsOrigin() );
        ParticleManager:SetParticleControl( self.particle_indicator_3, 3, Vector( 150, 150, 0 ) );
        ParticleManager:SetParticleControl( self.particle_indicator_3, 4, Vector( 255, 0, 0 ) );
        ParticleManager:SetParticleControl( self.particle_indicator_3, 6, Vector( 1, 0, 0 ) );

        self.particle_indicator_4 = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( self.particle_indicator_4, 0, self:GetCaster():GetAbsOrigin() )
        ParticleManager:SetParticleControl( self.particle_indicator_4, 1, self.beam_point_4)
        ParticleManager:SetParticleControl( self.particle_indicator_4, 2, self:GetCaster():GetAbsOrigin() );
        ParticleManager:SetParticleControl( self.particle_indicator_4, 3, Vector( 150, 150, 0 ) );
        ParticleManager:SetParticleControl( self.particle_indicator_4, 4, Vector( 255, 0, 0 ) );
        ParticleManager:SetParticleControl( self.particle_indicator_4, 6, Vector( 1, 0, 0 ) );

        -- play voice line
        EmitSoundOn("Hero_Phoenix.SunRay.Cast", self:GetCaster())

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function green_beam:OnSpellStart()
    if IsServer() then
        ParticleManager:DestroyParticle(self.particle_indicator_1,true)
        ParticleManager:DestroyParticle(self.particle_indicator_2,true)
        ParticleManager:DestroyParticle(self.particle_indicator_3,true)
        ParticleManager:DestroyParticle(self.particle_indicator_4,true)

        self:CreateBeam( )
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

function green_beam:CreateBeam( )
    if IsServer() then

        local caster = self:GetCaster()
        local radius = self:GetSpecialValueFor( "radius" ) --30
        local dmg = self:GetSpecialValueFor( "damage" ) --10
        local angleIncrement = 0.15--self:GetSpecialValueFor( "beam_speed_angle_increment" ) -- 0.6
        local currentAngle = 1
        local particleName = "particles/tinker/green_phoenix_sunray.vpcf"
        local max_beams = #self.tBeams
        local tParticleBeams = {}
        self.end_beams = false
        self.hold_beams = false
        self.tTimers = {}

        for j = 1, max_beams, 1 do
            self.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, self:GetCaster() )
            table.insert(tParticleBeams,self.pfx)
        end

        for i = 1, max_beams, 1 do
            self.tTimers[i] = Timers:CreateTimer(function()
            --self:GetCaster():SetContextThink( DoUniqueString( "updateSunRay" ), function ( )

                if self:GetCaster():IsAlive() == false or self.end_beams == true then
                    --return -1
                    return false
                end

                ParticleManager:SetParticleControl( tParticleBeams[i], 0, Vector( self:GetCaster():GetAbsOrigin().x,self:GetCaster():GetAbsOrigin().y, self:GetCaster():GetAbsOrigin().z + 100 ))

                local tEndPos = {}
                self.end_pos = ( RotatePosition(caster:GetAbsOrigin(), QAngle(0,currentAngle,0), self.tBeams[i] ) )
                self.end_pos = GetGroundPosition( self.end_pos, nil )
                self.end_pos.z = self:GetCaster():GetAbsOrigin().z + 100
                table.insert(tEndPos,self.end_pos)

                if self.hold_beams ~= true then
                    ParticleManager:SetParticleControl( tParticleBeams[i], 1, self.end_pos )

                    local units = FindUnitsInLine(
                        self:GetCaster():GetTeamNumber(),
                        self:GetCaster():GetAbsOrigin(),
                        self.end_pos,
                        nil,
                        radius,
                        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_INVULNERABLE)

                    if units ~= nil and #units ~= 0 then
                        for _,unit in pairs(units) do
                            if unit:GetUnitName() == "npc_tinker" then

                                self.hold_beams = true

                                for _, end_pos in pairs(tEndPos) do
                                    print("hello? loop?")
                                    print("distance ",(end_pos - unit:GetAbsOrigin() ):Length2D())
                                    if (end_pos - unit:GetAbsOrigin() ):Length2D() < 200 then
                                        print("hello? loop? <???")
                                        ParticleManager:SetParticleControl( tParticleBeams[i], 1, Vector( unit:GetAbsOrigin().x,unit:GetAbsOrigin().y, unit:GetAbsOrigin().z + 100 ))
                                    end
                                end

                                -- just need this to run once, doesn't matter which beam does it so doing it on beam1
                                if self.end_beams == false then

                                    EmitSoundOn("tinker_tink_death_03", self:GetCaster())

                                    Timers:CreateTimer(5, function()

                                        -- remove beam phase modifier
                                        if unit:HasModifier("beam_phase") then
                                            unit:RemoveModifierByName("beam_phase")
                                        end

                                        self.end_beams = true
                                        for _, particle in pairs(tParticleBeams) do
                                            ParticleManager:DestroyParticle(particle, false)
                                        end

                                        -- clean up remaining rocks
                                        self:CleanUpRemainingRocks()

                                        -- everytime tinker is hit by the beam inc the stack on the modifier
                                        self.hBuff = unit:AddNewModifier( self:GetCaster(), self, "beam_counter", { duration = -1 } )
                                        if unit:HasModifier("beam_counter") == true and self.hBuff:GetStackCount() < 5 then
                                            self.hBuff:IncrementStackCount()
                                        end
                                    end)

                                    return false
                                end
                            end
                        end
                    end

                    -- handles dmging players
                    local units_2 = FindUnitsInLine(
                        self:GetCaster():GetTeamNumber(),
                        self:GetCaster():GetAbsOrigin(),
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
                end

                if currentAngle == 360 then
                    currentAngle = 0
                end

                currentAngle = currentAngle + angleIncrement
                return 0.01
            --end, 0.0 )
            end)
        end
    end
end