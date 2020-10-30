
bird_puddle_thinker = class({})

function bird_puddle_thinker:IsHidden()
	return false
end

function bird_puddle_thinker:IsDebuff()
	return true
end

function bird_puddle_thinker:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function bird_puddle_thinker:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.radius = 150
        self.dmg_dot = 20
        self.stopDamageLoop = false
        self.damage_interval = 1

        -- ref from spell 
        self.currentTarget = Vector( kv.target_x, kv.target_y, kv.target_z )

        -- particle effect lava puddle
        local particle_cast2 = "particles/clock/tinker_hero_snapfire_ultimate_linger.vpcf"
        self.effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_WORLDORIGIN, self.parent )
        ParticleManager:SetParticleControl( self.effect_cast, 0, self.parent:GetAbsOrigin() )
        ParticleManager:SetParticleControl( self.effect_cast, 2, Vector(-1,0,0) )
        ParticleManager:SetParticleControl( self.effect_cast, 1, self.parent:GetAbsOrigin() )
        --ParticleManager:ReleaseParticleIndex( effect_cast )

        self:StartApplyDamageLoop()
	end
end
---------------------------------------------------------------------------

function bird_puddle_thinker:StartApplyDamageLoop()

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

        local friendlies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            self.currentTarget,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        for _, friend in pairs(friendlies) do
            if friend:GetUnitName("npc_ice_ele") == true then
                self.dmgTable = {
                    victim = friend,
                    attacker = self.caster,
                    damage = self.dmg_dot + 500,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    ability = self,
                }

                ApplyDamage(self.dmgTable)

            elseif friend:GetUnitName("npc_fire_ele") then
                friend:Heal(50, nil)

            elseif friend:GetUnitName("npc_elec_ele") then
                self:Destroy()
            end
        end

        for _, enemy in pairs(enemies) do

            self.dmgTable = {
                victim = enemy,
                attacker = self.caster,
                damage = self.dmg_dot,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability = self,
            }

            if enemy:HasModifier("biting_frost_modifier_debuff") then
                -- little steam particle effect here?
                local particle = "particles/units/heroes/hero_phoenix/phoenix_supernova_death_steam.vpcf"
                local effect_cast = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, self.parent )
                ParticleManager:SetParticleControl( effect_cast, 1, self.parent:GetAbsOrigin() )
                ParticleManager:ReleaseParticleIndex( effect_cast )

                enemy:RemoveModifier("biting_frost_modifier_debuff")
                self:Destroy()
            end

            ApplyDamage(self.dmgTable)
        end

		return self.damage_interval
	end)
end
--------------------------------------------------------------------------------

function bird_puddle_thinker:OnDestroy( kv )
    if IsServer() then
        ParticleManager:DestroyParticle(self.effect_cast,true)
        self.stopDamageLoop = true
        self:StartIntervalThink( -1 )
        UTIL_Remove( self.parent )
	end
end
---------------------------------------------------------------------------