missile_salvo = class({})

function missile_salvo:OnSpellStart()
    if IsServer() then

        -- point 1 top left, point 2 top right, point 3 bot left, point 4 bot right
        local point_1 = Vector(6617,8497,256)
        local point_2 = Vector(10028,8497,256)
        local point_3 = Vector(6617,5575,256)
        local point_4 = Vector(10028,5575,256)

        --de bug for corner check
        DebugDrawCircle(point_1,Vector(255,255,255),128,100,true,60)
        DebugDrawCircle(point_2,Vector(255,255,255),128,100,true,60)
        DebugDrawCircle(point_3,Vector(255,255,255),128,100,true,60)
        DebugDrawCircle(point_4,Vector(255,255,255),128,100,true,60)

        local length =          math.abs( point_2.y - point_4.y )
        local width =           math.abs( point_3.x - point_4.x )
        local missile_size =    Vector(200,200,0)

        local nColumns =        math.floor( width / missile_size.x )
        local nRows =           math.floor( length / missile_size.y )

        -- debug math checks
        --print("length ",length)
        --print("width ",width)
        --print("ncolumns ",nColumns)
        --print("nRows ",nRows)

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

        --[[ debug and pos check
        for i = 1, #tGrid, 1 do
            print("index ", i, "pos ", tGrid[i])
            DebugDrawCircle(tGrid[i],Vector(255,0,0),128,10,true,60)
        end]]

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

        -- i think need to pool some fo the rockets and launch in batches
        --print("total possible proj = ",#tGrid)
        local flTimeBetweenWaves = 6
        local nWaves = 0
        local nMaxWaves = 6
        local projPerWave = math.floor( #tGrid / 4)
        self.tProj = {}
        local missile_radius = missile_size.x

        --print("projPerWave =",projPerWave)

        Timers:CreateTimer(1, function()

            --print("is timer loppping running?",nWaves )

            if nWaves == nMaxWaves then
				return false
            end

            --print("elements in tGrid", #tGrid)

            nWaves = nWaves + 1
            self.tProj = {}

            -- grab projPerWave randomly from the table of grids
            for i = 1, projPerWave, 1 do
                --print("i",i, "#self.tProj ", #self.tProj)
                local randomIndex = RandomInt(1,#tGrid)
                local proj = tGrid[randomIndex]

                table.insert(self.tProj, proj)

                -- should we remove the previous used locations? makes it really easy to dodge to be honest...
                --table.remove(tGrid, randomIndex)

                --add marker to the ground for these random positions to warn the players where the rocket will land
                local particle = "particles/clock/clock_gyro_calldown_marker.vpcf"
                local p1Index = ParticleManager:CreateParticle(particle, PATTACH_POINT, self.caster)
                ParticleManager:SetParticleControl(p1Index, 0, proj)
                ParticleManager:SetParticleControl(p1Index, 1, Vector(missile_size.x,0,0))
                ParticleManager:ReleaseParticleIndex( p1Index )
            end

            --print("elements in #tProj", #tProj)

            --for j = 1, #tProj, 1 do
            local j = 1
            Timers:CreateTimer(0.01, function()
                --print("j = ",j, "#self.tProj ", #self.tProj)
                if j == #self.tProj then
                    --print("are we ending the loop early?", j)
                    return false
                end

                --print("is tProj loppping running?",j )
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

                ProjectileManager:CreateTrackingProjectile( info )

                dummy:ForceKill(false)

                j = 1 + j
                return 0.01

            end)
            --end

            return flTimeBetweenWaves

        end)
    end
end
--------------------------------------------------------------------------------

function missile_salvo:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        --leave particle effect on the ground
        local particle = "particles/clock/clock_earthshaker_arcana_totem_marker_model.vpcf"
        local p2Index = ParticleManager:CreateParticle(particle, PATTACH_POINT, self.caster)
        ParticleManager:SetParticleControl(p2Index, 0, vLocation)
        ParticleManager:ReleaseParticleIndex( p2Index )
    end
end
---------------------------------------------------------------------------