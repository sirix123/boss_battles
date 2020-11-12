march = class({})

function march:OnAbilityPhaseStart()
	if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1.0)

        return true
    end
end
---------------------------------------------------------------------------

function march:OnSpellStart()
    if IsServer() then
        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)

        local sound_cast = "Hero_Tinker.March_of_the_Machines"
		--EmitSoundOn( sound_cast, self:GetCaster() )

        -- init
        self.caster = self:GetCaster()

        -- there are 4 lines around the map (off screen)
        local top_start = Vector(-12588,13678,130)
        local top_fill_direction = Vector(1,0,0)
        local top_proj_direction = Vector(0,-1,0)

        local right_start = Vector(-8850,13853,130)
        local right_fill_direction = Vector(0,-1,0)
        local right_proj_direction = Vector(-1,0,0)

        local bot_start = Vector(-8850,10574,130)
        local bot_fill_direction = Vector(-1,0,0)
        local bot_proj_direction = Vector(0,1,0)

        local left_start = Vector(-11141,8850,130)
        local left_fill_direction = Vector(0,1,0)
        local left_proj_direction = Vector(1,0,0)

        local num_lines = 2
        local previous_index = 0
        local tStartSpawns = { }
        local spawnInfo = { }

        -- insert 2 from start spawns from table
        for i = 1, num_lines, 1 do
            local random_index = RandomInt(1, 4)

            while previous_index == random_index do
                random_index = RandomInt(1, 4)
            end

            if random_index == 1 then
                spawnInfo = {
                    vSpawn = top_start,
                    vFillDirection = top_fill_direction,
                    vProjDirection = top_proj_direction,
                }

                table.insert(tStartSpawns,spawnInfo)
            elseif random_index == 2 then
                spawnInfo = {
                    vSpawn = right_start,
                    vFillDirection = right_fill_direction,
                    vProjDirection = right_proj_direction,
                }

                table.insert(tStartSpawns,spawnInfo)
            elseif random_index == 3 then
                spawnInfo = {
                    vSpawn = bot_start,
                    vFillDirection = bot_fill_direction,
                    vProjDirection = bot_proj_direction,
                }

                table.insert(tStartSpawns,spawnInfo)
            elseif random_index == 4 then
                spawnInfo = {
                    vSpawn = left_start,
                    vFillDirection = left_fill_direction,
                    vProjDirection = left_proj_direction,
                }

                table.insert(tStartSpawns,spawnInfo)
            end

            previous_index = random_index
        end

        self.proj_radius = 100
        local length = 3500
        local nProj = length / self.proj_radius
        local maxWaves = 4
        local numWaves = 0

        Timers:CreateTimer(0.5, function()
            if numWaves == maxWaves then
                return false
            end

            for _, start_spawn in pairs(tStartSpawns) do
                for i = 1, nProj, 1 do
                    local offset = self.proj_radius  * i
                    local vSpawnOrigin = start_spawn.vSpawn + ( start_spawn.vFillDirection * offset )
                    local randomVelocity = RandomInt(300, 500)
                    self:CreateProjectile(vSpawnOrigin, start_spawn.vProjDirection, randomVelocity)
                    --DebugDrawCircle(vSpawnOrigin, Vector(0,0,255), 128, 10, true, 60)
                end
            end

            numWaves = numWaves + 1
            return 4.0
        end)
	end
end
---------------------------------------------------------------------------

function march:CreateProjectile(vOrigin, vDirection, velocity)
    if IsServer() then

        local hProjectile = {
            Source = self:GetCaster(),
            Ability = self,
            vSpawnOrigin = vOrigin,
            bDeleteOnHit = true,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            EffectName = "particles/tinker/tinker_rollermaw_larger_tinker.vpcf",
            fDistance = 4000,
            fStartRadius = 200,
            fEndRadius = 200,
            vVelocity = vDirection * velocity,
            bHasFrontalCone = false,
            bReplaceExisting = false,
            fExpireTime = GameRules:GetGameTime() + 30.0,
            bProvidesVision = true,
            iVisionRadius = 200,
            iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
        }

        ProjectileManager:CreateLinearProjectile( hProjectile )

	end
end
---------------------------------------------------------------------------

function march:OnProjectileHit(hTarget, vLocation)
    if IsServer() then
        if hTarget ~= nil then

            print("target name ",hTarget:GetUnitName())

        end
	end
end
---------------------------------------------------------------------------