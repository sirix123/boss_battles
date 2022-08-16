primal_beast_shaper_balls = class({})
LinkLuaModifier( "modifier_primal_beast_shaper_balls", "bosses/primalbeast/modifiers/modifier_primal_beast_shaper_balls", LUA_MODIFIER_MOTION_NONE )

function primal_beast_shaper_balls:OnAbilityPhaseStart()
    if IsServer() then
        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            5000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY, -- DOTA_UNIT_TARGET_TEAM_ENEMY
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if units == nil or #units == 0 then
            return false
        else
            local random_index = RandomInt(1, #units)
            self.target = units[random_index]
        end

        return true
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function primal_beast_shaper_balls:OnSpellStart()
    if IsServer() then

        self.caster = self:GetCaster()
        local origin = self.caster:GetAbsOrigin()

        self.dummys = {}

        self.speed = 250

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

        self.random_unit = self.dummys[RandomInt(1,#self.dummys)]

        local particle = "particles/tinker/tinker_earthshaker_totem_ti6_buff_longer.vpcf"
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

            local info = {
                EffectName = "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_arcane_orb.vpcf",
                Ability = self,
                iMoveSpeed = self.speed,
                Source = self.random_unit,
                Target = self.target,
                bDodgeable = false,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                bProvidesVision = true,
                iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
                iVisionRadius = 300,
            }
    
            ProjectileManager:CreateTrackingProjectile( info )

            return false
        end)



        -- self.dummy:RemoveSelf()

    end
end

function primal_beast_shaper_balls:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        if hTarget then

            CreateModifierThinker(
                self.caster,
                self,
                "modifier_primal_beast_shaper_balls",
                {
                    duration = self:GetSpecialValueFor( "duration" ),
                    radius = self:GetSpecialValueFor( "radius" ),
                    damage = self:GetSpecialValueFor( "damage" ),
                    delay = self:GetSpecialValueFor( "delay" ),
                    tick_rate = self:GetSpecialValueFor( "tick_rate" ),
                    target_x = hTarget:GetAbsOrigin().x,
                    target_y = hTarget:GetAbsOrigin().y,
                    target_z = hTarget:GetAbsOrigin().z,
                },
                hTarget:GetAbsOrigin(),
                self.caster:GetTeamNumber(),
                false
            )

            return true
        end

    end
end