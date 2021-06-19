sticky_bomb = class({})
LinkLuaModifier( "modifier_sticky_bomb", "bosses/techies/modifiers/modifier_sticky_bomb", LUA_MODIFIER_MOTION_NONE )

function sticky_bomb:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.0)

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self:GetCaster():GetAbsOrigin(),	-- point, center point
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

            self.target = units[RandomInt(1, #units)]

            local count = 0
            while (self.target:GetUnitName() == "npc_rock_techies") and count < 50 do
                self.target = units[RandomInt(1, #units)]

                count = count + 1
            end

            self:GetCaster():SetForwardVector(self.target:GetAbsOrigin())
            self:GetCaster():FaceTowards(self.target:GetAbsOrigin())

            return true
        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------

function sticky_bomb:OnSpellStart()
    if IsServer() then

        self:GetCaster():SetForwardVector(self.target:GetAbsOrigin())
        self:GetCaster():FaceTowards(self.target:GetAbsOrigin())

        -- unit identifier
        self.caster = self:GetCaster()
        self.duration = self:GetSpecialValueFor( "duration" )

        self.speed = 900

        local info = {
            EffectName = "particles/techies/techies_wd_ti8_immortal_bonkers_cask.vpcf",
            Ability = self,
            iMoveSpeed = self.speed,
            Source = self.caster,
            Target = self.target,
            bDodgeable = false,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bProvidesVision = true,
            iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
            iVisionRadius = 300,
        }

        ProjectileManager:CreateTrackingProjectile( info )
    end
end

function sticky_bomb:OnProjectileHit( hTarget, vLocation)
    if IsServer() then

        hTarget:AddNewModifier(
            self.caster, -- player source
            self, -- ability source
            "modifier_sticky_bomb", -- modifier name
            {
                duration = self.duration,
            } -- kv
        )

    end
end