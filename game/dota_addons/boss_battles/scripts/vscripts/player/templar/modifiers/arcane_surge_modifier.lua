arcane_surge_modifier = class({})

function arcane_surge_modifier:IsHidden()
	return false
end

function arcane_surge_modifier:IsDebuff()
	return false
end

function arcane_surge_modifier:IsPurgable()
	return false
end

function arcane_surge_modifier:GetEffectName()
	return "particles/templar/templarrazor_rain_storm.vpcf"
end
---------------------------------------------------------------------------

function arcane_surge_modifier:OnCreated( kv )
    if IsServer() then

        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.damage = self:GetAbility():GetSpecialValueFor("damage")
        self.interval = self:GetAbility():GetSpecialValueFor("interval")
        self.radius = self:GetAbility():GetSpecialValueFor("radius")

        if self:GetStackCount() < self:GetAbility():GetSpecialValueFor("max_stacks") then
            self:IncrementStackCount()
        end

        self.interval = self.interval - ( self.interval * ( ( self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stack_bonus_interval") ) / 100 ) )

        self:StartIntervalThink( self.interval )

        --print("self.interval ",self.interval)
        --print("self.damage ",self.damage)
        --print("-------------------------")


	end
end
---------------------------------------------------------------------------

function arcane_surge_modifier:OnRefresh( kv )
    if IsServer() then

        self:OnCreated()

	end
end
---------------------------------------------------------------------------

function arcane_surge_modifier:OnIntervalThink()
    if IsServer() then

        self.damage = self:GetAbility():GetSpecialValueFor("damage")

        local stacks = 0
        if self:GetCaster():HasModifier("templar_power_charge") then
            stacks = self:GetCaster():GetModifierStackCount("templar_power_charge", self:GetCaster())
        end

        if stacks > 0 then
            self.damage = self.damage + ( self:GetAbility():GetSpecialValueFor("stack_bonus_damage") * stacks )
        else
            self.damage = self:GetAbility():GetSpecialValueFor("damage")
        end

        local enemies = FindUnitsInRadius(
            self.parent:GetTeamNumber(),	-- int, your team number
            self.parent:GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
        )

        if enemies ~= nil and #enemies ~= 0 then

            --self.parent:GiveMana(self:GetAbility():GetSpecialValueFor("mana_on_hit"))

            self.dmgTable = {
                victim = enemies[1],
                attacker = self.parent,
                damage = self.damage,
                damage_type = self:GetAbility():GetAbilityDamageType(),
                ability = self:GetAbility(),
            }

            ApplyDamage(self.dmgTable)

            local particleName = "particles/units/heroes/hero_razor/razor_storm_lightning_strike.vpcf"
            local particle = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, self.parent)
            ParticleManager:SetParticleControl(particle, 0, Vector(self.parent:GetAbsOrigin().x,self.parent:GetAbsOrigin().y,800)) -- height of the bolt
            ParticleManager:SetParticleControl(particle, 1, enemies[1]:GetAbsOrigin()) -- point landing
            ParticleManager:SetParticleControl(particle, 2, Vector(self.parent:GetAbsOrigin().x,self.parent:GetAbsOrigin().y,800)) -- point origin
            ParticleManager:ReleaseParticleIndex(particle)

            --EmitSoundOn( "Ability.static.start", self:GetCaster() )

        end

    end
end
---------------------------------------------------------------------------


function arcane_surge_modifier:OnDestroy( kv )
    if IsServer() then

        if self.nfx then
            ParticleManager:DestroyParticle(self.nfx,false)
        end

        if self:GetStackCount() > 1 then
            local modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "arcane_surge_modifier", { duration = self:GetAbility():GetSpecialValueFor( "duration" ) } )
            if modifier then
                modifier:SetStackCount( self:GetStackCount() - 1 )
            end
        end

        self:StartIntervalThink( -1 )

	end
end
---------------------------------------------------------------------------