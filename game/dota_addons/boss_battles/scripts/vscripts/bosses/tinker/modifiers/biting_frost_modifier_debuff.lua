biting_frost_modifier_debuff = class({})

function biting_frost_modifier_debuff:IsHidden()
	return false
end

function biting_frost_modifier_debuff:IsDebuff()
	return true
end

function biting_frost_modifier_debuff:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function biting_frost_modifier_debuff:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.radius = kv.radius
        self.dmg = kv.dmg
        self.stopDamageLoop = false
        self.damage_interval = kv.interval
        self:IncrementStackCount()

        

        self:StartApplyDamageLoop()

	end

    self.ms_slow = -2

end
---------------------------------------------------------------------------

function biting_frost_modifier_debuff:OnRefresh(table)
    if IsServer() then
        self:IncrementStackCount()
	end
end
---------------------------------------------------------------------------

function biting_frost_modifier_debuff:OnIntervalThink()
    if IsServer() then

    end
end
---------------------------------------------------------------------------

function biting_frost_modifier_debuff:StartApplyDamageLoop()

    Timers:CreateTimer(self.damage_interval, function()
	    if self.stopDamageLoop == true then
		    return false
        end

        local particle_cast = "particles/icemage/shatter_maxstacks_explode_maiden_crystal_nova.vpcf"

        -- Create Particle
        self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( self.effect_cast, 0, self.parent:GetAbsOrigin() )
        ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( self.radius, 2, self.radius ) )
        ParticleManager:ReleaseParticleIndex( self.effect_cast )

        local friendly = FindUnitsInRadius(
            self.parent:GetTeamNumber(),	-- int, your team number
            self.parent:GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        --print("self:GetStackCount() ",self:GetStackCount())

        for _, friend in pairs(friendly) do
			local dmgTable = {
                victim = friend,
                attacker = self:GetCaster(),
                damage = self.dmg * self:GetStackCount(),
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability = self:GetAbility(),
            }

            ApplyDamage(dmgTable)
        end
		return self.damage_interval
	end)
end
--------------------------------------------------------------------------------


function biting_frost_modifier_debuff:OnDestroy( kv )
    if IsServer() then
        self.stopDamageLoop = true

        if self.effect_cast ~= nil then
            ParticleManager:DestroyParticle(self.effect_cast,false)
        end
	end
end
---------------------------------------------------------------------------

function biting_frost_modifier_debuff:DeclareFunctions()
	local funcs =
	{
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
-----------------------------------------------------------------------------

function biting_frost_modifier_debuff:GetModifierMoveSpeedBonus_Percentage( params )
    if self.ms_slow ~= nil then
		return self.ms_slow * self:GetStackCount()
	end
end
--------------------------------------------------------------------------------