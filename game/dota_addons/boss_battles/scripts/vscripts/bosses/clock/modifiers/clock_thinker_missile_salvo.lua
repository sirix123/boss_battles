
clock_thinker_missile_salvo = class({})

function clock_thinker_missile_salvo:IsHidden()
	return false
end

function clock_thinker_missile_salvo:IsDebuff()
	return true
end

function clock_thinker_missile_salvo:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function clock_thinker_missile_salvo:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.radius = self:GetAbility():GetSpecialValueFor("missile_radius")
        self.dmg_dot = self:GetAbility():GetSpecialValueFor( "dmg_dot" )
        self.stopDamageLoop = false
        self.damage_interval = self:GetAbility():GetSpecialValueFor( "dmg_interval" )

        -- ref from spell 
        self.currentTarget = Vector( kv.target_x, kv.target_y, kv.target_z )

        self:StartApplyDamageLoop()
	end
end
---------------------------------------------------------------------------

function clock_thinker_missile_salvo:StartApplyDamageLoop()

    Timers:CreateTimer(self.damage_interval, function()
	    if self.stopDamageLoop == true then
		    return false
        end

        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self.currentTarget,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        for _, enemy in pairs(enemies) do

            self.dmgTable = {
                victim = enemy,
                attacker = self.caster,
                damage = self.dmg_dot,
                damage_type = self:GetAbility():GetAbilityDamageType(),
                ability = self,
            }

            ApplyDamage(self.dmgTable)
        end

		return self.damage_interval
	end)
end
--------------------------------------------------------------------------------

function clock_thinker_missile_salvo:OnDestroy( kv )
    if IsServer() then
        self.stopDamageLoop = true
        self:StartIntervalThink( -1 )
        UTIL_Remove( self.parent )
	end
end
---------------------------------------------------------------------------