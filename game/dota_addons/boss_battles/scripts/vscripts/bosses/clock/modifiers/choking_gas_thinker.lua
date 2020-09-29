choking_gas_thinker = class({})

function choking_gas_thinker:IsHidden()
	return false
end

function choking_gas_thinker:IsDebuff()
	return true
end

function choking_gas_thinker:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function choking_gas_thinker:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.radius = kv.radius
        self.dmg = kv.dmg
        self.stopDamageLoop = false
        self.damage_interval = kv.damage_interval
        self.dmgType = kv.damage_type

        -- ref from spell 
        self.currentTarget = Vector( kv.target_x, kv.target_y, kv.target_z )

        -- create particle
        self.nfx = ParticleManager:CreateParticle("particles/clock/clock_gas_riki_smokebomb.vpcf", PATTACH_POINT, self:GetCaster())
        ParticleManager:SetParticleControl(self.nfx, 0, self.currentTarget)
        ParticleManager:SetParticleControl(self.nfx, 1, Vector(self.radius, self.radius, self.radius))
        --ParticleManager:ReleaseParticleIndex(self.nfx)

        self:StartApplyDamageLoop()
	end
end
---------------------------------------------------------------------------

function choking_gas_thinker:OnIntervalThink()
    if IsServer() then

    end
end
---------------------------------------------------------------------------

function choking_gas_thinker:StartApplyDamageLoop()

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
			local dmgTable = {
                victim = enemy,
                attacker = self:GetCaster(),
                damage = self.dmg,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability = self,
            }

            ApplyDamage(dmgTable)
        end
		return self.damage_interval
	end)
end
--------------------------------------------------------------------------------


function choking_gas_thinker:OnDestroy( kv )
    if IsServer() then
        self.stopDamageLoop = true
        ParticleManager:DestroyParticle(self.nfx,false)
        UTIL_Remove( self.parent )
	end
end
---------------------------------------------------------------------------