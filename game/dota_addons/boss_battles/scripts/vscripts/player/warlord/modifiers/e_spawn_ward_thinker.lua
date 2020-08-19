e_spawn_ward_thinker = class({})

function e_spawn_ward_thinker:IsHidden()
	return false
end

function e_spawn_ward_thinker:IsDebuff()
	return false
end

function e_spawn_ward_thinker:IsPurgable()
	return false
end
---------------------------------------------------------------------------

function e_spawn_ward_thinker:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.stopLoop = false

        -- kv ref
        self.radius = self:GetAbility():GetSpecialValueFor("radius")
        self.dmg = self:GetAbility():GetSpecialValueFor( "dmg" )
        self.interval = self:GetAbility():GetSpecialValueFor( "interval" )

        -- ref from spell
        self.currentTarget = Vector( kv.target_x, kv.target_y, kv.target_z )

        -- do on create stuff
        self:PlayEffectsOnCreated()

        self:StartIntervalThink( self.interval )
	end
end
---------------------------------------------------------------------------

function e_spawn_ward_thinker:OnIntervalThink()
    if IsServer() then

        -- find friendlies
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

        for _, friendly in pairs(friendlies) do

            -- apply buff to each friendly and heal
            friendly:AddNewModifier(self.caster, self, "e_spawn_ward_buff",
            {
                duration = self:GetAbility():GetSpecialValueFor( "buff_duration" ),
                dmg_reduction = self:GetAbility():GetSpecialValueFor( "dmg_reduction" ),
                heal_amount_per_tick = self:GetAbility():GetSpecialValueFor( "heal_amount_per_tick" )
            })

        end
    end
end
---------------------------------------------------------------------------

function e_spawn_ward_thinker:OnDestroy( kv )
    if IsServer() then
        self:StartIntervalThink( -1 )
        self.ward:ForceKill(false)
        UTIL_Remove( self.parent )
	end
end
---------------------------------------------------------------------------

function e_spawn_ward_thinker:PlayEffectsOnCreated()
    if IsServer() then

        -- spawn ward model
        self.ward = CreateUnitByName( "npc_ward", self.currentTarget, true, self.caster, self.caster, self.caster:GetTeamNumber())

    	-- Play spawn particle
		local eruption_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_healing_ward_eruption.vpcf", PATTACH_CUSTOMORIGIN, self.ward)
		ParticleManager:SetParticleControl(eruption_pfx, 0, self.ward:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(eruption_pfx)

		-- Attach ambient particle
		self.ward.healing_ward_ambient_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_healing_ward.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.ward)
		ParticleManager:SetParticleControl(self.ward.healing_ward_ambient_pfx, 0, self.ward:GetAbsOrigin() + Vector(0, 0, 100))
		ParticleManager:SetParticleControl(self.ward.healing_ward_ambient_pfx, 1, Vector(self.radius, 1, 1))
		ParticleManager:SetParticleControlEnt(self.ward.healing_ward_ambient_pfx, 2, self.ward, PATTACH_POINT_FOLLOW, "attach_hitloc", self.ward:GetAbsOrigin(), true)

        -- spawn bubble
        local nFXIndex1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_arc_warden/arc_warden_magnetic.vpcf", PATTACH_ABSORIGIN, self.ward )
        ParticleManager:SetParticleControl( nFXIndex1, 0, self.ward:GetAbsOrigin() )
        ParticleManager:SetParticleControl( nFXIndex1, 1, Vector( self.radius, self.radius, self.radius ) )

		EmitSoundOn("Hero_Juggernaut.HealingWard.Loop", self.ward)

	end
end
---------------------------------------------------------------------------
