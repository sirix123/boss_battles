missile_salvo = class({})
LinkLuaModifier( "clock_thinker_missile_salvo", "bosses/clock/modifiers/clock_thinker_missile_salvo", LUA_MODIFIER_MOTION_NONE )

function missile_salvo:OnSpellStart()
    if IsServer() then

        -- point 1 top left, point 2 top right, point 3 bot left, point 4 bot right
        local point_1 = Vector(6617,8497,256)
        local point_2 = Vector(10028,8497,256)
        local point_3 = Vector(6617,5575,256)
        local point_4 = Vector(10028,5575,256)

        --de bug for corner check
        --DebugDrawCircle(point_1,Vector(255,255,255),128,100,true,60)
        --DebugDrawCircle(point_2,Vector(255,255,255),128,100,true,60)
        --DebugDrawCircle(point_3,Vector(255,255,255),128,100,true,60)
        --DebugDrawCircle(point_4,Vector(255,255,255),128,100,true,60)

        local missile_radius = self:GetSpecialValueFor( "missile_radius" )

        local length =          math.abs( point_2.y - point_4.y )
        local width =           math.abs( point_3.x - point_4.x )
        local missile_size =    Vector(missile_radius,missile_radius,256)

        local nColumns =        math.floor( width / missile_size.x )
        local nRows =           math.floor( length / missile_size.y )

        -- create a table full of positions according for row|column
        local tGrid = {}
        local x_start = point_3.x
        local y_start = point_3.y
        local vGridLocation = Vector(0, 0, 0)
        local vPrevCalcPos = Vector(0, 0, 0)
        for i = 0, nColumns, 1 do
            for j = 0, nRows, 1 do

            vPrevCalcPos = Vector(x_start + missile_size.x * i, y_start + missile_size.y * j, missile_size.z)

            vGridLocation = Vector(vPrevCalcPos.x, vPrevCalcPos.y, missile_size.z)

            table.insert(tGrid, vGridLocation)
            end
        end

        -- clock should only do this once on spawn then pass the table to the spell that casts slavo TODO!
        -----------------------------
        -----------------------------
        -----------------------------
        ----------------------------------------------------------
        ----------------------------------------------------------
        -------------------------------------------------------------------
        ---------------------------------------------------------------------------

        -- init
        self.caster = self:GetCaster()
        self.speed = 1000
        local flTimeBetweenWaves = self:GetSpecialValueFor( "flTimeBetweenWaves" )
        local nMaxWaves = self:GetSpecialValueFor( "nMaxWaves" )
        self.dmg_hit = self:GetSpecialValueFor( "dmg_hit" )
        self.duration = self:GetSpecialValueFor( "duration" )
        self.damage_type = self:GetAbilityDamageType()

        local nWaves = 0
        local projPerWave = math.floor( #tGrid / 3.5)
        self.tProj = {}
        self.missile_radius = missile_size.x

        Timers:CreateTimer(1, function()

            if nWaves == nMaxWaves then
				return false
            end

            nWaves = nWaves + 1
            self.tProj = {}

            -- grab projPerWave randomly from the table of grids
            for i = 1, projPerWave, 1 do
                local randomIndex = RandomInt(1,#tGrid)
                local proj = tGrid[randomIndex]
                table.insert(self.tProj, proj)

                -- should we remove the previous used locations? makes it really easy to dodge to be honest...
                --table.remove(tGrid, randomIndex)

                --add marker to the ground for these random positions to warn the players where the rocket will land
                local particle = "particles/aoe_marker.vpcf"
                local p1Index = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self.caster)
                ParticleManager:SetParticleControl(p1Index, 0, proj)
                ParticleManager:SetParticleControl(p1Index, 1, Vector(missile_size.x, 1, 1))
                ParticleManager:SetParticleControl(p1Index, 2, Vector(255, 1, 1))
                ParticleManager:SetParticleControl(p1Index, 3, Vector(3, 0, 0))
                ParticleManager:ReleaseParticleIndex( p1Index )
            end

            local j = 1
            Timers:CreateTimer(0.01, function()
                
                -- if we have run out of proj in the batch end this timer
                if j == #self.tProj then
                    return false
                end

                -- for some reason .. volvo... needs a unit for this proj...
                local dummy = CreateUnitByName("npc_dummy_unit", self.tProj[j], false, self.caster, self.caster, self.caster:GetTeamNumber())

                -- create projectile
                local info = {
                    EffectName = "particles/ranger/ranger_clockwerk_para_rocket_flare.vpcf",
                    Ability = self,
                    iMoveSpeed = self.speed,
                    Source = self.caster,
                    Target = dummy,
                    bDodgeable = false,
                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                    bProvidesVision = true,
                    iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                    iVisionRadius = 300,
                }

                -- only run sound every 5th rocket or if the first
                if j % 5 == 0 or j == 1 then
                    EmitSoundOn( "Hero_Rattletrap.Rocket_Flare.Fire", self:GetCaster() )
                end

                -- shoot proj
                ProjectileManager:CreateTrackingProjectile( info )

                -- kill dummy unit asap
                dummy:ForceKill(false)

                -- loop it up and renew timer
                j = 1 + j
                return 0.01

            end)

            return flTimeBetweenWaves

        end)
    end
end
--------------------------------------------------------------------------------

function missile_salvo:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        -- find units in vlocation and apply damage
        local targets = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            vLocation,
            nil,
            self.missile_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0,
            0,
            false
        )

        -- initial hit 
        for _, target in pairs(targets) do
            local dmgTable =
            {
                victim = target,
                attacker = self.caster,
                damage = self.dmg_hit,
                damage_type = self.damage_type,
            }

            ApplyDamage(dmgTable)
        end

        -- leave puddle of lava on the ground for x duration
        self.modifier = CreateModifierThinker(
            self.caster,
            self,
            "clock_thinker_missile_salvo",
            {
                duration = self.duration,
                target_x = vLocation.x,
                target_y = vLocation.y,
                target_z = vLocation.z,
            },
            self.caster:GetOrigin(),
            self.caster:GetTeamNumber(),
            false
        )

        --play sound
        EmitSoundOnLocationWithCaster(vLocation, "Hero_Rattletrap.Rocket_Flare.Explode", self.caster )

        -- leave particle effect on the ground
        local particle_cast2 = "particles/clock/clock_hero_snapfire_ultimate_linger.vpcf"
        local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_WORLDORIGIN, self.caster )
        ParticleManager:SetParticleControl( effect_cast, 0, vLocation )
        ParticleManager:SetParticleControl( effect_cast, 2, Vector(duration,0,0) )
        ParticleManager:SetParticleControl( effect_cast, 1, vLocation )
        ParticleManager:ReleaseParticleIndex( effect_cast )
    end
end
---------------------------------------------------------------------------