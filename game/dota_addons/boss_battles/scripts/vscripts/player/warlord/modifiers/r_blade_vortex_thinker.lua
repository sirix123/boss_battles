r_blade_vortex_thinker = class({})

function r_blade_vortex_thinker:IsHidden()
	return true
end

function r_blade_vortex_thinker:IsDebuff()
	return false
end

function r_blade_vortex_thinker:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function r_blade_vortex_thinker:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()

        -- kv ref
        self.radius = self:GetAbility():GetSpecialValueFor("radius")
        self.dmg = self:GetAbility():GetSpecialValueFor( "base_dmg" )
        self.interval = self:GetAbility():GetSpecialValueFor( "tick_rate" )
        self.base_mana = self:GetAbility():GetSpecialValueFor( "mana_gain_percent_bonus" )

        -- ref from spell
        self.currentTarget = Vector( kv.target_x, kv.target_y, kv.target_z )
        self.previous_location = nil

        -- do on create stuff
        self:PlayEffectsOnCreated()

        --DebugDrawCircle(self.currentTarget,Vector(255,0,0),128,self.radius,true,60)

        --EmitSoundOn("Hero_Juggernaut.BladeFuryStart", self.parent)

        self:StartIntervalThink( self.interval )
	end
end
---------------------------------------------------------------------------

function r_blade_vortex_thinker:OnIntervalThink()
    if IsServer() then


        -- play effects
        if self.previous_location ~= self.currentTarget or self.previous_location == nil then
            if self.nfx ~= nil then
                ParticleManager:DestroyParticle(self.nfx,true)
            end
            self:PlayEffectsOnCreated()
        end

        -- find friendlies
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

        if enemies ~= nil and #enemies ~= 0  then

            self:GetCaster():ManaOnHit( self.base_mana )

            for _, enemy in pairs(enemies) do
                --EmitSoundOn("Hero_Juggernaut.BladeFury.Impact", enemy)

                self.dmgTable = {
                    victim = enemy,
                    attacker = self.parent,
                    damage = self.dmg,
                    damage_type = self:GetAbility():GetAbilityDamageType(),
                    ability = self:GetAbility(),
                }

                ApplyDamage(self.dmgTable)

            end
        end

        self.previous_location = self.currentTarget

    end
end
---------------------------------------------------------------------------

function r_blade_vortex_thinker:OnDestroy( kv )
    if IsServer() then

        -- stop looping sound
        --self.parent:StopSound("Hero_Juggernaut.BladeFuryStart")

        -- play end sound
        --EmitSoundOn("Hero_Juggernaut.BladeFuryStop", self.parent)

        ParticleManager:DestroyParticle(self.nfx,false)

        self:StartIntervalThink( -1 )
        UTIL_Remove( self.parent )
	end
end
---------------------------------------------------------------------------

function r_blade_vortex_thinker:PlayEffectsOnCreated()
    if IsServer() then

        local particle = "particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_crimson_blade_fury_abyssal.vpcf"
        self.nfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self.parent)
        ParticleManager:SetParticleControl(self.nfx , 0, self.currentTarget)
        ParticleManager:SetParticleControl(self.nfx , 2, Vector(self.radius,1,1))

	end
end
---------------------------------------------------------------------------
