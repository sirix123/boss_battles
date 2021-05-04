r_delayed_aoe_heal_modifier = class({})

function r_delayed_aoe_heal_modifier:IsHidden()
	return false
end

function r_delayed_aoe_heal_modifier:IsDebuff()
	return false
end

function r_delayed_aoe_heal_modifier:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function r_delayed_aoe_heal_modifier:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.radius = self:GetAbility():GetSpecialValueFor("radius")
        self.dmg = self:GetAbility():GetSpecialValueFor( "dmg" )
        self.damage_interval = self:GetAbility():GetSpecialValueFor( "damage_interval" )
        self.stopDamageLoop = false

        -- ref from spell
        self.currentTarget = Vector( kv.target_x, kv.target_y, kv.target_z )

        local particle = "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_ring.vpcf"
        self.bloodriteFX = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl( self.bloodriteFX, 0, self.currentTarget )
        ParticleManager:SetParticleControl( self.bloodriteFX, 1, Vector(self.radius, self.radius, self.radius) )
        ParticleManager:SetParticleControl( self.bloodriteFX, 3, self.currentTarget )

        self:StartApplyDamageLoop()
	end
end
---------------------------------------------------------------------------

function r_delayed_aoe_heal_modifier:StartApplyDamageLoop()

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
                damage = self.dmg,
                damage_type = self:GetAbility():GetAbilityDamageType(),
                ability = self:GetAbility(),
            }

            ApplyDamage(self.dmgTable)

            -- particle effect
            local particle = "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok.vpcf"
            self.explode_particle = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, enemy)
            ParticleManager:SetParticleControl( self.explode_particle, 0, enemy:GetAbsOrigin() )
            ParticleManager:SetParticleControl( self.explode_particle, 1, enemy:GetAbsOrigin() )
            ParticleManager:ReleaseParticleIndex(self.explode_particle)

        end

		return self.damage_interval
	end)
end
--------------------------------------------------------------------------------

function r_delayed_aoe_heal_modifier:OnDestroy( kv )
    if IsServer() then
        self.stopDamageLoop = true

        -- pop the thing
        ParticleManager:DestroyParticle(self.bloodriteFX,false)

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

        if enemies ~= nil and #enemies ~= 0 then
            self.caster:ManaOnHit(self:GetAbility():GetSpecialValueFor( "mana" ))
        end

        EmitSoundOnLocationWithCaster(self.currentTarget, "hero_bloodseeker.rupture", self.caster)

	end
end
---------------------------------------------------------------------------