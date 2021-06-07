cogs = class({})
LinkLuaModifier( "cog_modifier", "bosses/clock/modifiers/cog_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_disable_auto_attack", "core/modifier_generic_disable_auto_attack", LUA_MODIFIER_MOTION_NONE )

function cogs:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_RATTLETRAP_POWERCOGS, 1.0)

        local sound_random = math.random(1,17)
        if sound_random <= 9 then
            self:GetCaster():EmitSound("rattletrap_ratt_ability_cogs_0"..sound_random)
        else
            self:GetCaster():EmitSound("rattletrap_ratt_ability_cogs_"..sound_random)
        end

        local radius = 900
        self.nPreviewFXIndex = ParticleManager:CreateParticle( "particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 0, self:GetCaster():GetAbsOrigin() )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 1, Vector( radius, -radius, -radius ) )
        ParticleManager:SetParticleControl( self.nPreviewFXIndex, 2, Vector( self:GetCastPoint(), 0, 0 ) );
        ParticleManager:ReleaseParticleIndex( self.nPreviewFXIndex )

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function cogs:OnAbilityPhaseInterrupted()
    if IsServer() then

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function cogs:OnSpellStart()
    if IsServer() then
        self:GetCaster():RemoveGesture(ACT_DOTA_RATTLETRAP_POWERCOGS)

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_GENERIC_CHANNEL_1, 2.0)

        self:GetCaster():AddNewModifier( self:GetCaster(), nil, "modifier_generic_disable_auto_attack", { duration = -1 })

        local caster = self:GetCaster()
        local vCaster = caster:GetAbsOrigin()

        local nCogs = self:GetSpecialValueFor( "nCogs" )
        local nCogRadius = 900
        local vCogSpawn = GetGroundPosition(vCaster + Vector(0, nCogRadius, 0), nil)
        local tCogs = {}

        self.sound_cast = "Hero_StormSpirit.BallLightning.Loop"
        EmitGlobalSound( self.sound_cast )

        -- apply rooted modifier to boss
        caster:AddNewModifier(caster, nil, "modifier_rooted", {duration = -1})

        for i = 1, nCogs do

            -- create cog
            local cog = CreateUnitByName("npc_cog", vCogSpawn, true, caster, caster, caster:GetTeamNumber())

            -- set cog hull radius
            cog:SetHullRadius(150)

            -- make them invul
            cog:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )

            -- start cogs idle animation
            cog:StartGestureWithPlaybackRate(ACT_DOTA_IDLE, 1.0)

            -- emit sound
            cog:EmitSound("Hero_Rattletrap.Power_Cogs")

            local units = FindEnemyUnitsInRing(vCaster, nCogRadius + 120, nCogRadius - 120, caster:GetTeamNumber(), DOTA_UNIT_TARGET_FLAG_INVULNERABLE)
            if units ~= nil and #units ~= 0 then
                for _, unit in pairs(units) do
                    print("unit found ",unit:GetUnitName())
                    local direction = ( unit:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized()
                    FindClearSpaceForUnit(unit, unit:GetAbsOrigin() + direction * 200, true)
                end
            end

            -- rotate cog vector to spawn next one
            vCogSpawn = RotatePosition(vCaster, QAngle(0, 360 / nCogs, 0), vCogSpawn)

            -- insert cogs into a table to use them later
            table.insert(tCogs,cog)

        end

        --[[ find people near the cog and move them
        for _, cog in pairs(tCogs) do

        end]]

        -- play particle effect (around clock centrally cause getting close to him is death)
        self.particle_shell = ParticleManager:CreateParticle("particles/clock/clock_dark_seer_ion_shell.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControlEnt(self.particle_shell, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(self.particle_shell, 1, Vector(200, 200, 200))


        -- link boss to a cog, then rotate through the cogs every 1 second
        local loopTick = 1 -- total spell duration
        local cogIndex = 1 -- index for cog table
        local randomDirectionCount = 1 -- when this iterates to t number we switch directions
        local randomNumber = RandomInt(5, 10) -- t is set and used by r to change directions
        local changedDirections = false -- flag for reverse, false == clockwise, true = anti clockwise
        local totalTicks = self:GetSpecialValueFor( "totalTicks" ) --30
        local timerInterval = self:GetSpecialValueFor( "timerInterval" ) --1
        Timers:CreateTimer( function()
            if self:GetCaster():IsAlive() == false then
                StopGlobalSound(self.sound_cast)
                return false
            end

            if loopTick >= totalTicks then

                ParticleManager:DestroyParticle(self.particle_shell, true)

                self:GetCaster():RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)

                if changedDirections == false then
                    if tCogs[cogIndex-1]:HasModifier("cog_modifier") then
                        tCogs[cogIndex-1]:RemoveModifierByName("cog_modifier")
                    end
                elseif changedDirections == true then
                    if tCogs[cogIndex+1]:HasModifier("cog_modifier") then
                        tCogs[cogIndex+1]:RemoveModifierByName("cog_modifier")
                    end
                end

                -- loop through cog table and destroy them all
                for _, cog in pairs(tCogs) do
                    cog:ForceKill(false)
                end

                -- remove rooted modifier
                caster:RemoveModifierByName("modifier_rooted")

                caster:RemoveModifierByName("modifier_generic_disable_auto_attack")

                StopGlobalSound(self.sound_cast)

                return false
            end

            -- remove previous link
            if cogIndex > 1 and changedDirections == false then
                if tCogs[cogIndex-1]:HasModifier("cog_modifier") then
                    --print("removing previous link")
                    tCogs[cogIndex-1]:RemoveModifierByName("cog_modifier")
                end
            elseif cogIndex >= 0 and changedDirections == true then
                if tCogs[cogIndex+1]:HasModifier("cog_modifier") then
                    --print("removing previous link")
                    tCogs[cogIndex+1]:RemoveModifierByName("cog_modifier")
                end
            end

            -- reset handler
            if cogIndex == 0 then
                cogIndex = #tCogs
            elseif cogIndex > #tCogs then
                cogIndex = 1
            end

            -- add link
            tCogs[cogIndex]:AddNewModifier(self, self, "cog_modifier", {duration = -1})
            --print("cogIndex ",cogIndex)
            --print("randomDirectionCount ",randomDirectionCount,"randomNumber ",randomNumber)
            --print("loopTick ", loopTick)
            --print("--------------------")

            -- loopin / reserver handler
            if randomDirectionCount == randomNumber then

                if changedDirections == false then
                    changedDirections = true
                elseif  changedDirections == true then
                    changedDirections = false
                end

                randomNumber = RandomInt(self:GetSpecialValueFor( "min_rand" ), self:GetSpecialValueFor( "max_rand" ))
                --randomNumber = RandomInt(8, 19)
                randomDirectionCount = 0
            end

            if changedDirections == false then
                cogIndex = cogIndex + 1
            elseif changedDirections == true then
                cogIndex = cogIndex - 1
            end

            randomDirectionCount = randomDirectionCount + 1
            loopTick = loopTick + timerInterval

            return timerInterval
        end)

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

