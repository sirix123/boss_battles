primal_rock_prison = class({})
LinkLuaModifier( "primal_rock_prison_breaker_modifier", "bosses/primalbeast/modifiers/primal_rock_prison_breaker_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "primal_rock_prison_modifier", "bosses/primalbeast/modifiers/primal_rock_prison_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_disable_movement_abilities", "player/generic/modifier_generic_disable_movement_abilities", LUA_MODIFIER_MOTION_NONE )

function primal_rock_prison:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_rooted", { duration = self:GetCastPoint() + self:GetSpecialValueFor( "duration_rock_fall" ) + 2 } )

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            4000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY, -- DOTA_UNIT_TARGET_TEAM_ENEMY
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return false
        else

            -- prison target 1
            local random_index = RandomInt(1, #units)
            self.target_prison = units[random_index]
            table.remove(units,random_index)

            -- prison breaker 1
            -- random_index = RandomInt(1, #units)
            -- self.target_breaker = units[random_index]
            -- table.remove(units,random_index)

            -- prison target 2
            local random_index = RandomInt(1, #units)
            self.target_prison_2 = units[random_index]
            table.remove(units,random_index)

            -- prison breaker 2
            -- random_index = RandomInt(1, #units)
            -- self.target_breaker_2 = units[random_index]
            -- table.remove(units,random_index)

            -- print("self.target_prison ", self.target_prison:GetUnitName())
            -- print("self.target_prison2 ", self.target_prison_2:GetUnitName())


            return true
        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function primal_rock_prison:OnSpellStart()
    if IsServer() then

        -- unit identifier
        self.caster = self:GetCaster()
        self.duration = self:GetSpecialValueFor( "duration" )
        self.speed = 900
        self.dummys = {}

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY, -- DOTA_UNIT_TARGET_TEAM_ENEMY
            DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        for _, unit in pairs(units) do
            if unit:GetUnitName() == "npc_primalbeast_baby" then
                table.insert(self.dummys,unit)
            end
        end

        local particle = "particles/primalbeast/primaltinker_earthshaker_totem_ti6_buff_longer.vpcf"
        self.effect_cast_10 = ParticleManager:CreateParticle( particle, PATTACH_POINT_FOLLOW, self.random_unit )
        local attach = "select_low"
        ParticleManager:SetParticleControlEnt(
            self.effect_cast_10,
            0,
            self.random_unit,
            PATTACH_POINT_FOLLOW,
            attach,
            Vector(0,0,200), -- unknown
            true -- unknown, true
        )

        Timers:CreateTimer(3, function()
            if self.effect_cast_10 then
                ParticleManager:DestroyParticle(self.effect_cast_10,false)
            end

            self.random_unit = self.dummys[RandomInt(1,#self.dummys)]

            local info = {
                EffectName = "particles/primalbeast/primlabest_orck_pris_wd_ti8_immortal_bonkers_cask.vpcf",
                Ability = self,
                iMoveSpeed = self.speed,
                Source = self.random_unit,
                Target = self.target_prison,
                bDodgeable = false,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                bProvidesVision = true,
                iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                iVisionRadius = 300,
            }

            ProjectileManager:CreateTrackingProjectile( info )

            if self.target_prison_2 == nil then return end

            self.random_unit = self.dummys[RandomInt(1,#self.dummys)]

            local info = {
                EffectName = "particles/primalbeast/primlabest_orck_pris_wd_ti8_immortal_bonkers_cask.vpcf",
                Ability = self,
                iMoveSpeed = self.speed,
                Source = self.random_unit,
                Target = self.target_prison_2,
                bDodgeable = false,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                bProvidesVision = true,
                iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                iVisionRadius = 300,
            }

            ProjectileManager:CreateTrackingProjectile( info )

            return false
        end)

    end
end

function primal_rock_prison:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        if hTarget then

            hTarget:AddNewModifier(
                self.caster, -- player source
                self, -- ability source
                "modifier_generic_disable_movement_abilities", -- modifier name
                {
                    duration = self:GetSpecialValueFor( "duration_rock_fall" ) + 0.2,
                    radius = self:GetSpecialValueFor( "radius" ),
                } -- kv
            )

            -- hTarget:AddNewModifier(
            --     hTarget, -- player source
            --     self, -- ability source
            --     "modifier_rooted", -- modifier name
            --     {
            --         duration = 1,
            --     } -- kv
            -- )

            hTarget:AddNewModifier(
                self.caster, -- player source
                self, -- ability source
                "primal_rock_prison_modifier", -- modifier name
                {
                    duration = self:GetSpecialValueFor( "duration_rock_fall" ) + 0.2,
                    radius = self:GetSpecialValueFor( "radius" ),
                } -- kv
            )

            CreateModifierThinker(
                self.caster,
                self,
                "cone_smash_rocks_modifier",
                {
                    duration = self:GetSpecialValueFor( "duration_rock_fall" ),
                    radius = self:GetSpecialValueFor( "radius" ),
                    damage = self:GetSpecialValueFor( "dmg" ),
                },
                vLocation,
                self.caster:GetTeamNumber(),
                false
            )

            return true

        end

        -- self:PrisonBreaker()

    end
end

-- function primal_rock_prison:PrisonBreaker( )
--     if IsServer() then

--         self.target_breaker:AddNewModifier(
--             self.caster, -- player source
--             self, -- ability source
--             "primal_rock_prison_breaker_modifier", -- modifier name
--             {
--                 duration = self.duration,
--             } -- kv
--         )

--         if self.target_breaker_2 == nil then return end

--         self.target_breaker_2:AddNewModifier(
--             self.caster, -- player source
--             self, -- ability source
--             "primal_rock_prison_breaker_modifier", -- modifier name
--             {
--                 duration = self.duration,
--             } -- kv
--         )

--     end
-- end