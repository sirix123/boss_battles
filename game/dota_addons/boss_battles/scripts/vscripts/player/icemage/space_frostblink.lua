space_frostblink = class({})
LinkLuaModifier( "chill_modifier", "player/icemage/modifiers/chill_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_target_indicator", "player/generic/modifier_target_indicator", LUA_MODIFIER_MOTION_NONE )

function space_frostblink:OnAbilityPhaseStart()
    if IsServer() then

        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4, 1.5)

        -- add casting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "casting_modifier_thinker",
        {
            duration = self:GetCastPoint(),
            pMovespeedReduction = -80,
        })

        -- add targeting modifier
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_target_indicator",
        {
            duration = -1,
            cast_range = self:GetCastRange(Vector(0,0,0), nil),
        })

        return true
    end
end
----------------------------------------------------------------------------------------------------------

function space_frostblink:OnAbilityPhaseInterrupted()
    if IsServer() then
        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_4)

        if self:GetCaster():HasModifier("modifier_target_indicator") == true then
            self:GetCaster():RemoveModifierByName("modifier_target_indicator")
        end

        self:GetCaster():RemoveModifierByName("casting_modifier_thinker")

    end
end
----------------------------------------------------------------------------------------------------------

function space_frostblink:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local origin = caster:GetOrigin()
        local point = nil

        if caster:HasModifier("modifier_target_indicator") == true then
            caster:RemoveModifierByName("modifier_target_indicator")
        end

        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_4)

        self.radius = self:GetSpecialValueFor("radius")
        point = Clamp(caster:GetOrigin(), PlayerManager.mouse_positions[caster:GetPlayerID()], self:GetCastRange(Vector(0,0,0), nil), 0)

        -- apply chill and play effect
        -- apply chill to enemies around in a radius
        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            caster:GetAbsOrigin(),	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            0,	-- int, flag filter
            0,	-- int, order filter
            false	-- bool, can grow cache
            )

        for _, enemy in pairs(enemies) do
            if CheckRaidTableForBossName(enemy) ~= true then
                enemy:AddNewModifier(caster, self, "chill_modifier", { duration = self:GetSpecialValueFor( "chill_duration") })
                caster:ManaOnHit(self:GetSpecialValueFor( "mana_gain_percent"))
            end
        end
        -- chill effect
        self:PlayChillEffects(caster)

        -- blink
        self:PlayEffects(0)
        FindClearSpaceForUnit(caster, point , true)
        self:PlayEffects(1)
    end
end
---------------------------------------------------------------------------

function space_frostblink:PlayEffects(mode)
    if mode == 0 then
        local sound_cast = "DOTA_Item.BlinkDagger.Activate"
        EmitSoundOn(sound_cast, self:GetCaster())

	    local particle_cast = "particles/items_fx/blink_dagger_start.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(effect_cast, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end

	local particle_cast = "particles/items_fx/blink_dagger_end.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:ReleaseParticleIndex(effect_cast)
end
---------------------------------------------------------------------------

function space_frostblink:PlayChillEffects(caster)

    -- Get Resources
    local particle_cast = "particles/icemage/shatter_maxstacks_explode_maiden_crystal_nova.vpcf"
    local sound_cast = "Hero_Crystal.CrystalNova"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( effect_cast, 0, caster:GetAbsOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 2, self.radius ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    -- Create Sound
    EmitSoundOnLocationWithCaster( caster:GetAbsOrigin(), sound_cast, self:GetCaster() )
end
---------------------------------------------------------------------------