march = class({})

function march:OnAbilityPhaseStart()
	if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1.0)

        local sound_random = math.random(1,11)
        if sound_random <= 9 then
            self:GetCaster():EmitSound("tinker_tink_ability_marchofthemachines_0"..sound_random)
        else
            self:GetCaster():EmitSound("tinker_tink_ability_marchofthemachines_"..sound_random)
        end

        local particle_cast = "particles/units/heroes/hero_tinker/tinker_motm.vpcf"

        local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
        ParticleManager:SetParticleControlEnt(
            effect_cast,
            0,
            self:GetCaster(),
            PATTACH_POINT_FOLLOW,
            "attach_attack1",
            Vector(0,0,0), -- unknown
            true -- unknown, true
        )
        ParticleManager:ReleaseParticleIndex( effect_cast )

        return true
    end
end
---------------------------------------------------------------------------

function march:OnSpellStart()
    if IsServer() then
        -- when spell starts fade gesture
        self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)

        local sound_cast = "Hero_Tinker.March_of_the_Machines"
		EmitSoundOn( sound_cast, self:GetCaster() )

        -- init
        self.caster = self:GetCaster()

        -- there are 4 lines around the map (off screen)
        local top_start = Vector(-13286,14643,130)
        local top_fill_direction = Vector(1,0,0)
        local top_proj_direction = Vector(0,-1,0)

        local right_start = Vector(-7964,14673,130)
        local right_fill_direction = Vector(0,-1,0)
        local right_proj_direction = Vector(-1,0,0)

        local bot_start = Vector(-8145,8927,130)
        local bot_fill_direction = Vector(-1,0,0)
        local bot_proj_direction = Vector(0,1,0)

        local left_start = Vector(-13224,8981,130)
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

        self.proj_radius = 80
        local length = 4400
        local nProj = length / self.proj_radius
        local maxWaves = 4
        local numWaves = 0

        Timers:CreateTimer(0.5, function()
            if IsValidEntity(self:GetCaster()) == false then
                return false
            end

            if numWaves == maxWaves then
                return false
            end

            for _, start_spawn in pairs(tStartSpawns) do
                for i = 1, nProj, 1 do
                    local offset = self.proj_radius * i
                    local vSpawnOrigin = start_spawn.vSpawn + ( start_spawn.vFillDirection * offset )
                    local randomSpeed = RandomInt(300, 500)
                    self:CreateProjectile(vSpawnOrigin, start_spawn.vProjDirection, randomSpeed)
                    --print("vSpawnOrigin ", vSpawnOrigin)
                    --DebugDrawCircle(vSpawnOrigin, Vector(0,0,255), 128, 10, true, 60)
                end
            end

            numWaves = numWaves + 1
            return 7.0
        end)
	end
end
---------------------------------------------------------------------------

function march:CreateProjectile(vOrigin, vDirection, speed)
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
            fDistance = 5000,
            fStartRadius = self.proj_radius,
            fEndRadius = self.proj_radius,
            vVelocity = vDirection * speed,
            bHasFrontalCone = false,
            bReplaceExisting = false,
            fExpireTime = GameRules:GetGameTime() + 25,
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
            if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then

                local particle = "particles/econ/items/wisp/wisp_relocate_marker_ti7_end.vpcf"
                local nfx = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
                ParticleManager:SetParticleControl(nfx, 1, vLocation)
                ParticleManager:ReleaseParticleIndex(nfx)

                --[[local enemies = FindUnitsInRadius(
                    self:GetCaster():GetTeamNumber(),	-- int, your team number
                    vLocation,	-- point, center point
                    nil,	-- handle, cacheUnit. (not known)
                    100,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                    DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
                    0,	-- int, flag filter
                    0,	-- int, order filter
                    false	-- bool, can grow cache
                )

                local damageTable = {
                    attacker = self:GetCaster(),
                    damage = 150,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    ability = self,
                }

                for _,enemy in pairs(enemies) do
                    damageTable.victim = enemy
                    ApplyDamage(damageTable)
                end]]

                local damageTable = {
                    victim = hTarget,
                    attacker = self:GetCaster(),
                    damage = 100,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    ability = self,
                }

                ApplyDamage(damageTable)

                return true
            else
                return true
            end
        end
	end
end
---------------------------------------------------------------------------