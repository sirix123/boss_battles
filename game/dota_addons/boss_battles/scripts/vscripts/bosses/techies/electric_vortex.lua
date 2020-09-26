electric_vortex = class({})
LinkLuaModifier( "modifier_electric_vortex", "bosses/techies/modifiers/modifier_electric_vortex", LUA_MODIFIER_MOTION_HORIZONTAL )

function electric_vortex:OnAbilityPhaseStart()
    if IsServer() then

        -- find targets
        self.targets = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            4000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if self.targets == nil or self.targets == 0 then
            return false
        else
            return true
        end

    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function electric_vortex:OnSpellStart()
    if IsServer() then
        -- unit identifier
        local caster = self:GetCaster()

        -- load data
        local duration = self:GetSpecialValueFor( "duration" )

        -- play sound
        EmitSoundOn("techies_tech_trapgoesoff_01", self:GetCaster())

        if self.targets ~= nil and self.targets ~= 0 then
            --print("num targets ", #self.targets)
            local randomTarget = self.targets[RandomInt(1, #self.targets)]

            if randomTarget ~= nil and randomTarget:IsAlive() then
                randomTarget:AddNewModifier(
                    caster, -- player source
                    self, -- ability source
                    "modifier_electric_vortex", -- modifier name
                    {
                        duration = duration,
                        x = caster:GetAbsOrigin().x,
                        y = caster:GetAbsOrigin().y,
                    } -- kv
                )
            end
        end
        -- play effects
        local sound_cast = "Hero_StormSpirit.ElectricVortexCast"
        EmitGlobalSound( sound_cast )
    end
end