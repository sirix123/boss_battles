explode_proxy_mines = class({})

function explode_proxy_mines:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        -- play sound
        EmitGlobalSound("techies_tech_cast_02")

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function explode_proxy_mines:OnSpellStart()
    if IsServer() then
        -- unit identifier
        self.caster = self:GetCaster()

        self:GetCaster():RemoveGesture(ACT_DOTA_ATTACK)

        -- find targets
        local targets = FindUnitsInRadius(
            self.caster:GetTeamNumber(),	-- int, your team number
            self.caster:GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        local delay = 0.1
        local tMines = {}

        for _, target in pairs(targets) do
            if target:GetUnitName() == "npc_imba_techies_land_mines" then
                table.insert(tMines,target)
            end
        end

        local j = 1
        Timers:CreateTimer(delay, function()

            -- if we have run out of proj in the batch end this timer
            if j == #tMines then
                return false
            end

            tMines[j]:ForceKill(false)

            j = j + 1
            return delay

        end)
    end
end
