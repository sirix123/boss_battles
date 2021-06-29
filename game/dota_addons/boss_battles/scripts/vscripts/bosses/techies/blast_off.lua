blast_off = class({})

--LinkLuaModifier( "blast_off_modifier", "bosses/techies/modifiers/blast_off_modifier", LUA_MODIFIER_MOTION_BOTH  )
LinkLuaModifier( "modifier_generic_arc_lua", "player/generic/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "blast_off_fog_modifier", "bosses/techies/modifiers/blast_off_fog_modifier", LUA_MODIFIER_MOTION_NONE )

function blast_off:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1.0)

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return false
        else

            local randomEnemy = units[RandomInt(1, #units)]

            local count = 0
            while (randomEnemy:GetUnitName() == "npc_rock_techies") and count < 50 do
                randomEnemy = units[RandomInt(1, #units)]
                count = count + 1
            end

            self.vTargetPos = randomEnemy:GetAbsOrigin()

            self:GetCaster():SetForwardVector(self.vTargetPos)
            self:GetCaster():FaceTowards(self.vTargetPos)

            local radius = 500
            self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self.vTargetPos )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, Vector( radius, -radius, -radius ) )
            ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, Vector( self:GetCastPoint(), 0, 0 ) );
            ParticleManager:ReleaseParticleIndex( self.nPreviewFXIndex )

            -- play voice line
            EmitSoundOn("techies_tech_suicidesquad_01", self:GetCaster())

            return true
        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function blast_off:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()

        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_3)

        -- find a random point inside the map arena
        --local vTargetPos = Vector(caster.mouse.x, caster.mouse.y, caster.mouse.z) -- for testing
        --local vTargetPos = Vector(Rand)

        --local vTargetPos = units[RandomInt(1, #units)]:GetAbsOrigin()

        -- references
        local distance = (caster:GetAbsOrigin() - self.vTargetPos):Length2D()
        local speed = 1500 -- special value
        local height = 300
        self.fog_duration = 5
        self.radius_fog = 9000
        self.radius_dmg = 500
        self.damage = 400

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_techies/techies_blast_off_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControlEnt( nFXIndex, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
		--caster:AddParticle( nFXIndex, false, false, -1, false, false )

        -- leap
        local arc = caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_generic_arc_lua", -- modifier name
            {
                target_x = self.vTargetPos.x,
                target_y = self.vTargetPos.y,
                distance = distance,
                speed = speed,
                height = height,
                fix_end = true,
                fix_height = false,
                isStun = true,
                activity = ACT_DOTA_FLAIL,
            } -- kv
        )

        arc:SetEndCallback( function()
            self:GetCaster():RemoveGesture(ACT_DOTA_FLAIL)
            ParticleManager:DestroyParticle(nFXIndex,false)

            -- blowup
            --print("call back arc")
            self:BlowUp()
            self:SpawnCubes()

        end)

        Timers:CreateTimer(1.0, function()
            -- fog of war
            local unitsFog = FindUnitsInRadius(
                self:GetCaster():GetTeamNumber(),	-- int, your team number
                Vector(10126,1776,130),	-- point, center point self:GetCaster():GetAbsOrigin()
                nil,	-- handle, cacheUnit. (not known)
                self.radius_fog,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_DEAD,	-- int, flag filter
                0,	-- int, order filter
                false	-- bool, can grow cache
            )

            if unitsFog ~= nil and #unitsFog ~= 0 then
                for _, unitFog in pairs(unitsFog) do
                    if unitFog:GetUnitName() ~= "npc_rock_techies" then
                        unitFog:AddNewModifier(
                            self:GetCaster(), -- player source
                            self, -- ability source
                            "blast_off_fog_modifier", -- modifier name
                            {
                                duration = self.fog_duration,
                            } -- kv
                        )
                    end
                end
            end

            return false
        end)

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function blast_off:BlowUp()
    if IsServer() then

        --print("blowup")

        -- dmg
        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius_dmg,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units ~= nil and #units ~= 0 then
            for _, unit in pairs(units) do
                if unit:GetUnitName() ~= "npc_rock_techies" then
                    self.damageTable = {
                        victim = unit,
                        attacker = self:GetCaster(),
                        damage = self.damage,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                        ability = self,
                    }

                    ApplyDamage(self.damageTable)
                end
            end
        end

        -- particle effect
        local radius = 200
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetAbsOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( radius, 0.0, 1.0 ) )
		ParticleManager:SetParticleControl( nFXIndex, 2, Vector( radius, 0.0, 1.0 ) )
        ParticleManager:ReleaseParticleIndex( nFXIndex )

        -- play sound
        EmitSoundOn( "Hero_Techies.Suicide", self:GetCaster() )

        --[[ fog of war
        local unitsFog = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            Vector(10126,1776,130),	-- point, center point self:GetCaster():GetAbsOrigin()
            nil,	-- handle, cacheUnit. (not known)
            self.radius_fog,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_DEAD,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if unitsFog ~= nil and #unitsFog ~= 0 then
            for _, unitFog in pairs(unitsFog) do
                if unitFog:GetUnitName() ~= "npc_rock_techies" then
                    unitFog:AddNewModifier(
                        self:GetCaster(), -- player source
                        self, -- ability source
                        "blast_off_fog_modifier", -- modifier name
                        {
                            duration = self.fog_duration,
                            reduceFog = self.reduceFog
                        } -- kv
                    )
                end
            end
        end]]


    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function blast_off:SpawnCubes()
    if IsServer() then

        -- cubes and decide how many and where
        local tCubes = {}
        local nCubesToSpawn = 3

        for i = 1, nCubesToSpawn, 1 do
            local mid_point = Vector(10126,1776,131)
            local radius = 600
            local randomX = RandomInt(mid_point.x - radius, mid_point.x + radius)
            local randomY = RandomInt(mid_point.y - radius, mid_point.y + radius)
            table.insert(tCubes, Vector(randomX,randomY,131))
        end

        -- spawn the dust columns and swirls
        for _, vCube in pairs(tCubes) do
            -- swirls
            local particle_rock_spawn = "particles/custom/swirl/dota_swirl.vpcf"
            local particle_effect_rock_spawn = ParticleManager:CreateParticle( particle_rock_spawn, PATTACH_WORLDORIGIN, self:GetCaster() )
            ParticleManager:SetParticleControl(particle_effect_rock_spawn, 0, vCube )
            ParticleManager:SetParticleControl(particle_effect_rock_spawn, 1, Vector(5,0,0) )
            ParticleManager:ReleaseParticleIndex(particle_effect_rock_spawn)
        end

        -- timer for x seconds return false first and spawn rocks
        Timers:CreateTimer(5.0, function()

            -- spawn rocks 
            for _, vCube in pairs(tCubes) do

                -- ground thing
                self.nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_visage/visage_summon_familiars.vpcf", PATTACH_WORLDORIGIN, nil )
                ParticleManager:SetParticleControl(self.nFXIndex, 0, vCube)
                ParticleManager:ReleaseParticleIndex( self.nFXIndex )

                -- spawn cube
                local newItem = CreateItem("item_rock", nil, nil)
                local obj = CreateItemOnPositionForLaunch( vCube, newItem )
                obj:SetModelScale(0.4)

                -- add that item particle glow
                local particle = "particles/techies/etherial_targetglow_repeat.vpcf"
                local nfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, obj)
                ParticleManager:SetParticleControl(nfx, 1, obj:GetAbsOrigin())

                --- add direction to it
                obj:SetForwardVector( Vector( RandomFloat(-1, 1) , RandomFloat(-1, 1), RandomFloat(-1, 1) ) )

            end

            return false
        end)

    end
end