e_magic_circle_modifier = class({})

function e_magic_circle_modifier:IsHidden()
	return false
end

function e_magic_circle_modifier:IsDebuff()
	return false
end

function e_magic_circle_modifier:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function e_magic_circle_modifier:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.radius = self:GetAbility():GetSpecialValueFor("radius")
        self.dmg = self:GetAbility():GetSpecialValueFor( "dmg" )
        self.thinker_tick_rate = self:GetAbility():GetSpecialValueFor( "thinker_tick_rate" )
        self.stopDamageLoop = false
        self.track_dmg = 0

        -- ref from spell
        self.currentTarget = Vector( kv.target_x, kv.target_y, kv.target_z )

        local particle = "particles/custom/magic_circle/pugna_magic_circle.vpcf"
        self.bloodriteFX = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self.parent)
        ParticleManager:SetParticleControl( self.bloodriteFX, 0, self.currentTarget )
        ParticleManager:SetParticleControl( self.bloodriteFX, 2, Vector(self.radius, 0, 0) )

        self:StartApplyDamageLoop()
	end
end
---------------------------------------------------------------------------

function e_magic_circle_modifier:StartApplyDamageLoop()

    Timers:CreateTimer(function()
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

        if enemies ~= nil and #enemies ~= 0 then
            self.track_dmg = self.track_dmg + self:GetAbility():GetSpecialValueFor( "dmg_for_dot_per_tick" )

            for _, enemy in pairs(enemies) do
                local particle = "particles/units/heroes/hero_pugna/pugna_netherblast.vpcf"
                self.explode_particle = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, enemy)
                ParticleManager:SetParticleControl( self.explode_particle, 0, Vector(enemy:GetAbsOrigin().x,enemy:GetAbsOrigin().y, 200 ))
                ParticleManager:SetParticleControl( self.explode_particle, 1, Vector(50, 1, 1) )
                ParticleManager:ReleaseParticleIndex(self.explode_particle)

                self.dmgTable = {
                    victim = enemy,
                    attacker = self:GetCaster(),
                    damage = self.dmg,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    ability = self:GetAbility(),
                }

                ApplyDamage(self.dmgTable)
            end
        end

		return self.thinker_tick_rate
	end)
end
--------------------------------------------------------------------------------

function e_magic_circle_modifier:OnDestroy( kv )
    if IsServer() then
        self.stopDamageLoop = true

        -- pop the thing
        ParticleManager:DestroyParticle(self.bloodriteFX,false)

        EmitSoundOnLocationWithCaster(self.currentTarget, "Hero_Pugna.NetherBlast", self.caster)

	end
end
---------------------------------------------------------------------------