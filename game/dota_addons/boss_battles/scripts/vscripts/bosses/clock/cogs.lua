cogs = class({})
LinkLuaModifier( "cog_modifier", "bosses/clock/modifiers/cog_modifier", LUA_MODIFIER_MOTION_NONE )

function cogs:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_RATTLETRAP_POWERCOGS, 1.0)

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

        local caster = self:GetCaster()
        local vCaster = caster:GetAbsOrigin()

        local nCogs = 8
        local nCogRadius = 500
        local vCogSpawn = GetGroundPosition(vCaster + Vector(0, nCogRadius, 0), nil)
        local tCogs = {}

        -- apply rooted modifier to boss
        caster:AddNewModifier(caster, nil, "modifier_rooted", {duration = -1})

        -- if boss has armor buff, remove it, but remember the stacks first
        if caster:HasModifier("armor_buff_modifier") then
            self.hBuff_nStackCount = caster:GetModifierStackCount("armor_buff_modifier", nil)
            --print("stackcount ",self.hBuff_nStackCount)
            caster:RemoveModifierByName("armor_buff_modifier")
        end

        for i = 1, nCogs do

            -- play particle effect


            -- create cog
            local cog = CreateUnitByName("npc_cog", vCogSpawn, false, caster, caster, caster:GetTeamNumber())

            -- set cog hull radius
            cog:SetHullRadius(150)

            -- make them invul
            cog:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )

            -- start cogs idle animation
            cog:StartGestureWithPlaybackRate(ACT_DOTA_IDLE, 1.0)

            -- emit sound
            cog:EmitSound("Hero_Rattletrap.Power_Cogs")

            -- rotate cog vector to spawn next one
            vCogSpawn = RotatePosition(vCaster, QAngle(0, 360 / nCogs, 0), vCogSpawn)

            -- insert cogs into a table to use them later
            table.insert(tCogs,cog)

        end

        -- find everyone within or on the cogs radius and pull them into the centre
        local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, nCogRadius + 100, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
        for _, unit in pairs(units) do
            if (unit:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() <= nCogRadius then
                if unit:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
                    FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), false)
                else
                    FindClearSpaceForUnit(unit, self:GetCaster():GetAbsOrigin() + RandomVector(80), false)
                end
            else
                FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), false)
            end
        end

        -- apply link, create a box, link one cog to another
        -- not sure if we need this tbh... cause the player want to be inside and fragging boss
        for _, hCog in pairs(tCogs) do

        end

        -- link boss to a cog, then rotate through the cogs every 1 second
        local loopTick = 1 -- total spell duration
        local cogIndex = 1 -- index for cog table
        local randomDirectionCount = 1 -- when this iterates to t number we switch directions
        local randomNumber = RandomInt(5, 10) -- t is set and used by r to change directions
        local changedDirections = false -- flag for reverse, false == clockwise, true = anti clockwise
        local totalTicks = self:GetSpecialValueFor( "totalTicks" ) --30
        local timerInterval = self:GetSpecialValueFor( "timerInterval" ) --1
        Timers:CreateTimer( function()
            if loopTick >= totalTicks then

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

                -- add armor buff back with the correct stack count
                local hBuff = self:GetCaster():AddNewModifier( nil, nil, "armor_buff_modifier", { duration = -1 } )
                hBuff:SetStackCount(self.hBuff_nStackCount)

                return false
            end

            -- remove previous link
            if cogIndex > 1 and changedDirections == false then
                if tCogs[cogIndex-1]:HasModifier("cog_modifier") then
                   tCogs[cogIndex-1]:RemoveModifierByName("cog_modifier")
                end
            elseif cogIndex >= 0 and changedDirections == true then
                if tCogs[cogIndex+1]:HasModifier("cog_modifier") then
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

                randomNumber = RandomInt(5, 15)
                randomDirectionCount = 0
            end

            if changedDirections == false then
                cogIndex = cogIndex + 1
            elseif changedDirections == true then
                cogIndex = cogIndex - 1
            end

            randomDirectionCount = randomDirectionCount + timerInterval
            loopTick = loopTick + timerInterval

            return timerInterval
        end)

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

